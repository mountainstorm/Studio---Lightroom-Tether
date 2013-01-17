//
//  LightroomInstall.m
//  StudioTether
//
//  Created by drake on 04/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LightroomInstall.h"
#import "System Preferences.h"
#import "Adobe Lightroom 2.h"
#import "System Events.h"


@implementation LightroomInstall



- (IBAction)installLightroomTether_openUIAccess:(id)sender
{	
    SystemPreferencesApplication *systemPreferences = [SBApplication applicationWithBundleIdentifier: @"com.apple.systempreferences"];
	[systemPreferences activate];
	systemPreferences.currentPane = ( SystemPreferencesPane * ) [[systemPreferences panes] objectWithID: @"com.apple.preference.universalaccess"];

} // installLightroomTether_openUIAccess:



- (IBAction)installLightroomTether_openLightroom:(id)sender
{	
    AdobeLightroom2Application *lightroom = [SBApplication applicationWithBundleIdentifier: @"com.adobe.Lightroom2"];
	[lightroom activate];
	//SystemEventsApplication *sysEvents = [SBApplication applicationWithBundleIdentifier: @"com.apple.systemevents"];
	//[sysEvents keystroke: @"," using: SystemEventsEMdsCommandDown | SystemEventsEMdsOptionDown | SystemEventsEMdsShiftDown];
	
} // installLightroomTether_openLightroom:


@end
