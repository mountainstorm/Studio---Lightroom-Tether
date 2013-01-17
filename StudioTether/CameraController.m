//
//  ICACameraController.m
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import "CameraController.h"
#import "NikonWindow.h"



@implementation CameraController


- (void)applicationDidFinishLaunching:( NSNotification * )notification
{
	NSLog( @"applicationDidFinishLaunching:" );
	
	self->cameras = [[NSMutableArray arrayWithCapacity: 1] retain];
	self->icaController = [[ICACameraController alloc] init: self];
	if(    ( self == nil ) 
		|| ( self->icaController == nil ) )
	{	
		NSRunCriticalAlertPanel( @"Unable to register for notifications", 
								 @"An error occurred whilst registering for camera attach/detach notifications.  The application must exit", 
								 @"Exit Application", nil, nil );
		[[NSApplication sharedApplication] terminate: self];
		
	} // if
//	[[NikonWindow alloc] init: 0 withDict: nil andPreferences: self->preferences];
} // applicationDidFinishLaunching:



- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self->icaController release];
	[self->cameras release];
	NSLog( @"applicationShouldTerminate:" );
	
} // applicationShouldTerminate:



- (void)cameraAdded:(ICAObject)dev withDict:(NSDictionary *)dict
{
	NSLog( @"cameraAdded: %x, ifil: %@, dict: %@", dev, [dict objectForKey: @"ifil"], dict );
	CameraWindow *camera = nil;
	
	if(    ( [self->preferences customExtensions] == TRUE ) 
	    && ( [[dict objectForKey: @"idVendor"] intValue] == [NikonWindow vendorID] ) )
	{
		// create the camera window
		camera = [NikonWindow alloc];

	}
	else
	{
		// create the camera window
		camera = [CameraWindow alloc];

	} // if

	if( [camera init: dev withDict: dict andPreferences: self->preferences] == FALSE )
	{
		NSRunAlertPanel( @"Failed to initialize device", 
						@"There was a problem trying to initialize the camera which was just attached.  Try turning the camera off and on again.", 
						@"Ok", 
						nil, 
						nil );	
		
	}
	else
	{
		[self->preferences readOnlySettings: TRUE];
		[self->cameras addObject: camera];
		NSLog( @"cameraAdded Device added: %x", camera );
		NSBeep();
	
	} // if
	[camera release]; // addObject takes a ref
	
} // cameraAdded:withName:andDict:



- (void)cameraRemoved:(ICAObject)dev
{
	NSLog( @"cameraRemoved" );

	NSEnumerator* it = [self->cameras objectEnumerator];
	CameraWindow *camera = nil;
	while( camera = [it nextObject] )
	{		
		NSLog( @"camera: %x", camera );
		if( [camera compare: dev] == YES )
		{
			[camera shutdown];
			[self->cameras removeObject: camera];
			NSLog( @"Device removed" );
			NSBeep();
			break;
			
		} // if
	} // while

	if( [self->cameras count] == 0 )
	{
		[self->preferences readOnlySettings: FALSE];
		
	} // if	
 } // cameraRemoved:



- (IBAction)toggleFullScreen:(id)sender
{
	SystemUIMode mode = 0;
	GetSystemUIMode( &mode, NULL );
	SetSystemUIMode( ( mode == kUIModeAllSuppressed ) ? kUIModeNormal: kUIModeAllSuppressed, 0 );

} // toggleFullScreen



- (IBAction)showHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.mountainstorm.co.uk"]];
	
} // showHelp:


@end
