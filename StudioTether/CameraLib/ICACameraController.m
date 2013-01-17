//
//  ICACameraController.m
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import "ICACameraController.h"
#import <Carbon/Carbon.h>



static void icaAddRemove( CFStringRef notificationType, CFDictionaryRef notificationDictionary );



@interface ICACameraController( Private )
- (BOOL)registerForAddRemoveNotifications:(ICANotification) func;
@end



@implementation ICACameraController


- (id)init:(id)d
{
	self = [super init];
	if( self != nil )
	{
		self->delegate = d;
		self = [self registerForAddRemoveNotifications: icaAddRemove] == TRUE ? self: nil;		
	
	} // if
	return( self );
	
} // init:



- (void)dealloc
{
	[self registerForAddRemoveNotifications: nil];
	self->delegate = nil;
	[super dealloc];
	
} // dealloc



- (BOOL)registerForAddRemoveNotifications:(ICANotification)func
{
	BOOL							   retVal = TRUE;
    OSErr                              err = noErr;
    ICARegisterForEventNotificationPB  pb = {};
    pb.header.refcon    = ( unsigned long ) self;
    pb.objectOfInterest = 0;
    pb.eventsOfInterest = ( CFArrayRef ) [NSArray arrayWithObjects: ( NSString * ) kICANotificationTypeDeviceAdded, 
																	( NSString * ) kICANotificationTypeDeviceRemoved, 
																	nil];
    pb.notificationProc = func;
    pb.options          = NULL;
    err = ICARegisterForEventNotification( &pb, NULL );
	if( err != noErr )
	{
		NSLog( @"Unable to register for device insertion/removal events" );
		retVal = FALSE;
		
	} // if
    return( retVal );
	
} // registerForAddRemoveNotifications:

@end



static void icaAddRemove( CFStringRef notificationType, CFDictionaryRef notificationDictionary )
{
	ICAObject devObj = ( ICAObject ) [[( NSDictionary * ) notificationDictionary objectForKey: ( NSString * ) kICANotificationDeviceICAObjectKey] intValue];
	ICACameraController *self = ( ICACameraController * ) [[( NSDictionary * ) notificationDictionary objectForKey: ( NSString * ) kICARefconKey] intValue];
	if(    ( devObj != 0 )
	    && ( self != nil ) )
	{
		if( CFStringCompare( notificationType, kICANotificationTypeDeviceAdded, 0 ) == kCFCompareEqualTo )
		{
			// get the property dictionary as it can take a few seconds
			ICACopyObjectPropertyDictionaryPB pb = {};
			NSDictionary *dict = nil;
			pb.object = devObj; // device object ID
			pb.theDict = ( CFDictionaryRef * ) &dict;
			OSErr err = ICACopyObjectPropertyDictionary( &pb, NULL );
			if( err == noErr )
			{
				[self->delegate cameraAdded: devObj withDict: dict];
				[dict release];
			}
			else
			{
				NSLog( @"unable to get device property dictionary" );
				
			} // if
		}
		else if( CFStringCompare( notificationType, kICANotificationTypeDeviceRemoved, 0 ) == kCFCompareEqualTo )
		{
			[self->delegate cameraRemoved: devObj];
			
		}
		else
		{
			NSLog( @"unexpected ica event: %@", notificationType );
			
		} // if
	}
	else
	{
		NSLog( @"unable to get ica device object" );
		
	} // if
} // icaAddRemove

