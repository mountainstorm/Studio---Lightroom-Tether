//
//  CameraPanel.h
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CameraPanel : NSPanel 
{
	BOOL allowClose;
}


- (void)initWindow:(NSString *)name;
- (BOOL)isExcludedFromWindowsMenu;
- (BOOL)canBecomeMainWindow;
- (void)close;
- (void)closeForExit;


@end
