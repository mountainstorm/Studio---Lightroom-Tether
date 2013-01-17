//
//  CameraWindow.m
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import "CameraWindow.h"
#import "CameraPanel.h"


@implementation CameraWindow


- (id)init:(ICAObject)dev withDict:(NSDictionary *)dict andPreferences:(PreferencePanel *)pref
{	
	id retVal = nil;
	self->preferences = pref;

	NSLog( @"CameraWindow created, window: %x, name: %@", self->window, [self->camera getCameraName] );

	if( [NSBundle loadNibNamed:[self getNibName] owner: self] == TRUE )
	{
		self->camera = [[self allocICAObject] init: dev withDict: dict notify: self];
		if( self->camera != nil )
		{
			[(CameraPanel *)self->window initWindow: [self->camera getCameraName]];		
			retVal = self;
			
		} // if
	} // if
	return( retVal );
	
} // init:withDict:andPreferences:



- (void)shutdown
{
	[self->activityFlash invalidate];
	self->activityFlash = nil;
	[self->camera shutdown];
	
} // shutdown


- (void)dealloc
{
	NSLog( @"dealloc window object" );
	[self->camera release];
	[self->window closeForExit];
	
	[super dealloc];
	
} // dealloc



- (ICACamera *)allocICAObject
{
	return( [ICACamera alloc] );

} // allocICAObject



- (BOOL)compare:(ICAObject)dev
{
	return( [self->camera compare: dev] );
		   
} // compare:



- (NSString *)getNibName
{
	return( @"CameraWindow" );

} // getNibName



- (IBAction)shutterRelease:(id)sender
{
	if( [self->camera shutterRelease] == FALSE )
	{
		NSBeginCriticalAlertSheet( @"The capture image command failed",
								   @"Continue", 
								   nil,
								   nil,
								   self->window,
								   nil,
								   NULL,
								   NULL,
								   self,
								   @"The camera failed to successfully capture and image",
								   nil );		
		
	} // if	
} // shutterRelease:



- (void)imageDownloadBegin:(NSDictionary *)notificationDictionary
{	
	NSLog( @"CameraWindow:imageDownloadBegin: %@, requesting download to: %@", notificationDictionary, [self->preferences downloadPath] );
	if( [self->camera downloadObject: notificationDictionary
							toFolder: [self->preferences downloadPath]] == FALSE )
	{
		NSBeginCriticalAlertSheet( @"Unable to download image",
								   @"Continue", 
								   nil,
								   nil,
								   self->window,
								   nil,
								   NULL,
								   NULL,
								   self,
								   @"Failure whilst attempting to download image",
								   nil );		
	
	}
	else
	{
		// we dont get progress so lets just flash the activity light to indicate its downloading
		[self fakeActivityFlash: NULL];
		self->activityFlash = [NSTimer scheduledTimerWithTimeInterval: 0.1
															   target: self
															 selector: @selector( fakeActivityFlash: )
															 userInfo: NULL
															  repeats: YES];
		
	} // if
} // imageDownloadBegin



- (void)imageDownloadComplete:(NSString *)file
{
	[self->activityFlash invalidate];
	self->activityFlash = nil;
	[self->activity setState: FALSE];

	// send the application and open message for this file
	NSLog( @"imageDownloadComplete: %@", file );
	if( [self->preferences applicationEnable] == YES )
	{
		if( [[[self->preferences applicationPath] pathExtension] caseInsensitiveCompare: @"app"] == NSOrderedSame )
		{
			NSLog( @"launching target application: %@", [self->preferences applicationPath] );
			[NSTask launchedTaskWithLaunchPath: @"/usr/bin/open"
					arguments: [NSArray arrayWithObjects: @"-a", 
														  [self->preferences applicationPath], 
														  file,
														  nil]];
		}
		else
		{
			NSLog( @"launching target script: %@", [self->preferences applicationPath] );
			[NSTask launchedTaskWithLaunchPath: [self->preferences applicationPath]
									 arguments: [NSArray arrayWithObject: file]];			

			NSLog( @"script complete" );
		} // if
	} // if
} // imageDownloadComplete



- (void)imageDownloadFailed
{
	NSBeginCriticalAlertSheet( @"Download of capture image failed",
							   @"Continue", 
							   nil,
							   nil,
							   self->window,
							   nil,
							   NULL,
							   NULL,
							   self,
							   @"The download of the captured image failed; turn the camera off and retry",
							   nil );
	
} // imageDownloadFailed



- (void)fakeActivityFlash:(NSTimer *)t
{
	static unsigned char count = 0;
	unsigned char gaps[] = { 1, 2, 0, 1, 0, 2, 1, 2, 1, 0, 2 }; // think of 1 as on, 2 as off - 0 as ignore this cycle
	if( t == NULL )
	{
		count = 0;
		
	} // if
	
	if( gaps[ count ] > 0 )
	{
		[self->activity setState: [self->activity state] ? FALSE: TRUE];
	
	} // if
	count++;
	if( count > sizeof( gaps ) )
	{
		count = 0;
		
	} // if	
} // fakeActivityFlash


@end
