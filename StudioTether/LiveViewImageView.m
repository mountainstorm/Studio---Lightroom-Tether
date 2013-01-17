//
//  LiveViewImageView.m
//  StudioTether
//
//  Created by drake on 07/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LiveViewImageView.h"


@implementation LiveViewImageView


- (void)awakeFromNib
{
	self->borderWidth = [[self superview] frame].size.width - [self frame].size.width;
	self->borderHeight = [[self superview] frame].size.height - [self frame].size.height;
	
} // awakeFromNib



- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
	if(    ( [[self superview] frame].size.height > 100 ) 
	    && ( [[self superview] frame].size.width > 100 ) )
	{
		NSRect frame = [self frame];
		frame.size.width = [[self superview] frame].size.width - self->borderWidth;
		frame.size.height = [[self superview] frame].size.height - self->borderHeight;
		[self setFrame: frame];
		
	} // if	
} // resizeWithOldSuperviewSize


@end
