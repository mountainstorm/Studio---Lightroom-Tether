//
//  ShutterReleaseCell.m
//  StudioTether
//
//  Created by drake on 24/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShutterReleaseCell.h"


@implementation ShutterReleaseCell


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame.origin.x += 1;
	cellFrame.origin.y += 1;
	cellFrame.size.width -= 2;
	cellFrame.size.height -= 2;
	
	if( [self controlSize] == NSSmallControlSize )
	{
		cellFrame.size.width *= 0.75;
		cellFrame.size.height *= 0.75;
		
	} // if
	
	NSBezierPath *thePath = [NSBezierPath bezierPath];
	[thePath appendBezierPathWithOvalInRect: cellFrame];
    NSGradient *aGradient = nil;
	if( [self isHighlighted] == FALSE )
	{
		aGradient = [[[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.5], (CGFloat) 0.0,
																	 [NSColor colorWithDeviceRed: 0.6 green: 0.6 blue: 0.6 alpha: 0.5], (CGFloat) 1.0,
																	 nil] autorelease];
	
	}
	else
	{
		aGradient = [[[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceRed: 0.5 green: 0.5 blue: 0.5 alpha: 0.5], (CGFloat) 0.0,
																	 [NSColor colorWithDeviceRed: 0.8 green: 0.8 blue: 0.8 alpha: 0.5], (CGFloat) 1.0,
																	 nil] autorelease];
		
	} // if
	[aGradient drawInBezierPath: thePath angle: -90.0];	

	// draw border
	[[NSColor lightGrayColor] set];
	[thePath stroke];	

} // drawRect


@end
