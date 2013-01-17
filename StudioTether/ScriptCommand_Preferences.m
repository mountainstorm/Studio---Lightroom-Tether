//
//  ScriptCommand_Preferences.m
//  StudioTether
//
//  Created by drake on 05/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ScriptCommand_Preferences.h"
#import "CameraController.h"



@implementation ScriptCommand_Preferences


-(id)performDefaultImplementation
{
	NSMutableArray *retVal = [NSMutableArray array];

	NSString *downloadPath = [self directParameter];
	NSNumber *customExtensions = [[self evaluatedArguments] objectForKey: @"customExtensions"];
	NSString *applicationPath = [[self evaluatedArguments] objectForKey: @"applicationPath"];
	NSLog( @"ScriptCommand_Preferences performDefaultImplementation: %@, %@, %@", downloadPath, customExtensions, applicationPath );
	
	[(( CameraController *)[[NSApplication sharedApplication] delegate] )->preferences setRuntimePreferences: downloadPath 
																							customExtensions: customExtensions != nil ? TRUE: FALSE  
																								 application: applicationPath];
	
	// fullscreen mode if were being controlled
	SetSystemUIMode( ( downloadPath != nil ? TRUE: FALSE ) ? kUIModeAllSuppressed: kUIModeNormal, 0 );
	return( retVal );
	
} // performDefaultImplementation


@end
