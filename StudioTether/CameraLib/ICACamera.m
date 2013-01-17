//
//  ICACamera.m
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import "ICACamera.h"


static void icaAddObject( CFStringRef notificationType, CFDictionaryRef notificationDictionary );
static void icaDownloadComplete( ICAHeader* pb );


@interface ICACamera( Private )
- (BOOL)registerForAddObjectNotification:(ICANotification)func;
@end



@implementation ICACamera



- (id)init:(ICAObject)dev withDict:(NSDictionary *)dict notify:(id)del
{
	self->camera = dev;
	self->cameraDict = [dict retain];
	self->delegate = del;
	self->downloads = [[NSMutableSet setWithCapacity: 1] retain];
	self = [self registerForAddObjectNotification: icaAddObject] == TRUE ? self: nil;
	return( self );

} // init:withDict:notify:



- (void)shutdown
{
} // shutdown



- (void)dealloc
{
	[self registerForAddObjectNotification: NULL];
	[self->downloads release];
	[self->cameraDict release];
	[super dealloc];
	
} // dealloc



- (BOOL)compare:(ICAObject)dev
{
	return( dev == self->camera );

} // compare



- (NSString *)getCameraName
{
	return( [self->cameraDict objectForKey: @"ifil"] );

} // getCameraName



- (BOOL)shutterRelease
{
	ICAObjectSendMessagePB pb = {0};
	pb.object = self->camera;
	pb.message.messageType = kICAMessageCameraCaptureNewImage;
	return( ICAObjectSendMessage( &pb, NULL ) == noErr );

} // shutterRelease



- (BOOL)registerForAddObjectNotification:(ICANotification)func
{
	BOOL							   retVal = TRUE;
    OSErr                              err = noErr;
    ICARegisterForEventNotificationPB  pb = {};
    
	pb.header.refcon    = ( unsigned long ) self;
    pb.objectOfInterest = 0;
    pb.eventsOfInterest = ( CFArrayRef ) [NSArray arrayWithObjects: ( NSString * ) kICANotificationTypeObjectAdded,
																	nil];
    pb.notificationProc = func;
    pb.options          = NULL;
    err = ICARegisterForEventNotification( &pb, NULL );
	if( err != noErr )
	{
		NSLog( @"unable to register for add object notifications" );
		retVal = FALSE;
		
	} // if
    return( retVal );
	
} // registerForAddObjectNotification:



- (BOOL)downloadObject:(NSDictionary *)obj toFolder:(NSString *)folder
{
	BOOL retVal = FALSE;
	FSRef fsRef = {0};
	
	OSStatus err = FSPathMakeRef( (const UInt8 *) [folder fileSystemRepresentation], &fsRef, NULL);
	if( err == noErr )
	{
		ICACopyObjectPropertyDictionaryPB pb = {};
		CFDictionaryRef dict = NULL;
		
		// get the filename of the image
		pb.object = [[obj objectForKey: (NSString *)kICANotificationICAObjectKey] longLongValue]; 
		pb.theDict = (CFDictionaryRef *) &dict;
		OSErr err = ICACopyObjectPropertyDictionary( &pb, NULL );
		if( err == noErr )
		{
			CFStringRef imgName = CFDictionaryGetValue( dict, CFSTR( "ifil" ) );
			if( imgName != NULL )
			{
				ICADownloadFilePB pbd = {0};
				
				// store the filename against the object for when it completes
				NSString *fullfilename = [folder stringByAppendingPathComponent: (NSString *)imgName];
				NSDictionary *download = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithUnsignedLong: (unsigned long) self], 
																					 @"self", 
																					 fullfilename, 
																					 @"file", 
																					 nil ];
				[self->downloads addObject: download];
				NSLog( @"downloadObject: fullfilename: %@, download: %x", fullfilename, download );
				
				// download the actual file
				pbd.header.refcon = ( unsigned long ) download;
				pbd.object = [[obj objectForKey: (NSString *)kICANotificationICAObjectKey] longLongValue];
				pbd.dirFSRef = &fsRef;
				if( ICADownloadFile( &pbd, icaDownloadComplete ) == noErr )
				{
					retVal = TRUE;
					
				}
				else
				{
					NSLog( @"ICADownloadFile failed" );
					
				} // if
			}
			else
			{
				NSLog( @"Failed to get filename of object" );
					  
			} // if
			CFRelease( dict );
		}
		else
		{
			NSLog( @"Failed to retrieve dictionary for object" );
				  
		} // if				
	}
	else
	{
		NSLog( @"Unable to convert url: %@ to a FSRef", folder );
		
	} // if
	return( retVal );
	
} // downloadObject:toFolder:



- (BOOL)passthrough:(PTPPassThroughPB *)passThroughPB size:(unsigned long)length
{
	OSErr err = noErr;
	ICAObjectSendMessagePB msgPB = {0};
	msgPB.object				= self->camera;
	msgPB.message.messageType	= kICAMessageCameraPassThrough;
	msgPB.message.startByte		= 0;
	msgPB.message.dataPtr		= passThroughPB;
	msgPB.message.dataSize		= length;
	msgPB.message.dataType		= 0;
	err = ICAObjectSendMessage( &msgPB, NULL );
	return( err == noErr );
	
} // passthrough


@end



static void icaAddObject( CFStringRef notificationType, CFDictionaryRef notificationDictionary )
{
	// note we want the object key not deviceobject here!
	ICAObject devObj = ( ICAObject ) [[( NSDictionary * ) notificationDictionary objectForKey: ( NSString * ) kICANotificationICAObjectKey] intValue];
	ICACamera *self = ( ICACamera * ) [[( NSDictionary * ) notificationDictionary objectForKey: ( NSString * ) kICARefconKey] intValue];
	
	NSLog( @"Type: %@\nDictionary: %@", notificationType, notificationDictionary );
	
	if(   ( devObj != 0 )
	   && ( self != nil ) )
	{
		if( CFStringCompare( notificationType, kICANotificationTypeObjectAdded, 0 ) == kCFCompareEqualTo )
		{
			// download file to location
			NSLog( @"item added" );
			[self->delegate imageDownloadBegin: (NSDictionary *)notificationDictionary];
			
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
} // icaAddObject


static void icaDownloadComplete( ICAHeader* pb )
{
	NSDictionary *download = (NSDictionary *) pb->refcon;
	ICACamera *self = (ICACamera *) [[download objectForKey: @"self"] unsignedLongValue];
	[self->delegate imageDownloadComplete: [download objectForKey: @"file"]];
	[self->downloads removeObject: download];
	 
} // icaDownloadComplete