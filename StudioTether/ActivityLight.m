//
//  ActivityLight.m
//  StudioTether
//
//  Created by drake on 24/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ActivityLight.h"


@implementation ActivityLight



- (BOOL)state
{
	return( self->state );
	
} // state



- (void)setState:(BOOL)on
{
	if( self->state != on )
	{
		self->state = on;
		[self setNeedsDisplay: YES];
		
	} // if
} // setState



- (void)drawRect:(NSRect)cellFrame
{
	if( self->state == TRUE )
	{
		NSBezierPath *thePath = [NSBezierPath bezierPath];
		[[NSColor colorWithDeviceCyan: 0.41 magenta: 0.0 yellow: 0.91 black: 0.0 alpha: 1.0] set];
		[thePath appendBezierPathWithOvalInRect: cellFrame];
		[thePath fill];
		
	} // if
} // drawRect


@end
