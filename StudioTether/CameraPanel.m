//
//  CameraPanel.m
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import "CameraPanel.h"


@implementation CameraPanel



- (void)awakeFromNib
{
	[self setExcludedFromWindowsMenu: NO];
}



- (void)initWindow:(NSString *)name
{	
	self->allowClose = NO;
	[self setTitle: name];
	[[NSApplication sharedApplication] addWindowsItem: self title: name filename: NO];
	
} // init



- (BOOL)isExcludedFromWindowsMenu
{
	NSLog( @"showPanel:isExcludedFromWindowsMenu" );
	return( NO );
	
} // isExcludedFromWindowsMenu



- (BOOL)canBecomeMainWindow
{
	NSLog( @"showPanel:canBecomeMainWindow" );
	return( YES );
	
} // canBecomeMainWindow



- (void)close
{
	if( self->allowClose == NO )
	{
		[self miniaturize: self];
	}
	else
	{
		[super close];
		
	} // if
} // close


- (void)closeForExit
{
	self->allowClose = YES;
	[self close];
	
} // closeForExit


@end
