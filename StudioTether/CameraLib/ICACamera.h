//
//  ICACamera.h
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "PTP.h"


@interface ICACamera : NSObject 
{
	ICAObject camera;
	NSDictionary *cameraDict;
	
@public
	// these should only be accessed by the internals
	id	delegate;
	NSMutableSet *downloads;
}


- (id)init:(ICAObject)dev withDict:(NSDictionary *)dict notify:(id)delegate;
- (void)shutdown;
- (void)dealloc;

- (BOOL)compare:(ICAObject)dev;
- (NSString *)getCameraName;

- (BOOL)shutterRelease;
- (BOOL)downloadObject:(NSDictionary *)obj toFolder:(NSString *)folder;
- (BOOL)passthrough:(PTPPassThroughPB *)passThroughPB size:(unsigned long)length;


@end
