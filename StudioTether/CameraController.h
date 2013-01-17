//
//  ICACameraController.h
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "ICACameraController.h"
#import "PreferencePanel.h"



@interface CameraController : NSObject 
{
	ICACameraController *icaController;
	NSMutableArray *cameras;
@public
	IBOutlet id preferences;
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)applicationWillTerminate:(NSNotification *)notification;

- (void)cameraAdded:(ICAObject)camera withDict:(NSDictionary *)dict;
- (void)cameraRemoved:(ICAObject)camera;

- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)showHelp:(id)sender;

@end
