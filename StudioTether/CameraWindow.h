//
//  CameraWindow.h
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "PreferencePanel.h"
#import "ICACamera.h"



@interface CameraWindow : NSObject 
{
	PreferencePanel *preferences;
	ICACamera *camera;
	
	IBOutlet id window;
	IBOutlet id activity;
	
	NSTimer *activityFlash;
}


- (id)init:(ICAObject)dev withDict:(NSDictionary *)dict andPreferences:(PreferencePanel *)preferences;
- (void)shutdown;
- (void)dealloc;

- (ICACamera *)allocICAObject;
- (BOOL)compare:(ICAObject)dev;
- (NSString *)getNibName;

- (IBAction)shutterRelease:(id)sender;

- (void)imageDownloadBegin:(NSDictionary *)notificationDictionary;
- (void)imageDownloadComplete:(NSString *)file;
- (void)imageDownloadFailed;

- (void)fakeActivityFlash:(NSTimer *)t;

@end
