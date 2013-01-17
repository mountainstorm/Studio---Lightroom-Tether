//
//  ScriptCommand_Locked.m
//  StudioTether
//
//  Created by drake on 05/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ScriptCommand_Locked.h"
#import "CameraController.h"


@implementation ScriptCommand_Locked

-(id)performDefaultImplementation
{
	NSNumber *retVal = [NSNumber numberWithBool: [(( CameraController *)[[NSApplication sharedApplication] delegate] )->preferences isLocked]];
	NSLog( @"ScriptCommand_Locked performDefaultImplementation: %@", retVal );
	return( retVal );
	
} // performDefaultImplementation

@end
