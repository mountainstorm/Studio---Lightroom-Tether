//
//  PreferencePanel.h
//  PreferencePanel
//
//  Created by drake on 02/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencePanel : NSPanel
{	
	IBOutlet id customExtensions;
	IBOutlet id downloadPath;
	
	IBOutlet id applicationEnable;
	IBOutlet id applicationLabel;
	IBOutlet id applicationPath;
	
	BOOL lock;
}


- (void)awakeFromNib;
- (BOOL)windowShouldClose:(id)window;
- (IBAction)updateApplicationEnabled:(id)sender;
- (void)validateSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (void)readOnlySettings:(BOOL)on;

- (BOOL)isLocked;
- (void)setRuntimePreferences:(NSString *)downloadPath customExtensions:(BOOL)extensions application:(NSString *)applicationPath;

- (BOOL)customExtensions;
- (NSString *)downloadPath;
- (BOOL)applicationEnable;
- (NSString *)applicationPath;

@end
