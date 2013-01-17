//
//  GreenPopupButton.m
//  StudioTether
//
//  Created by drake on 24/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GreenPopupButton.h"


@implementation GreenPopupButton


- (void)drawRect:(NSRect)cellFrame
{
	if (![[self title] isEqualToString:@""])
	{
		NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];
		[attributes addEntriesFromDictionary: [[self attributedTitle] attributesAtIndex: 0 effectiveRange: NULL]];
		[attributes setObject: [NSColor colorWithDeviceCyan: 0.41 magenta: 0.0 yellow: 0.91 black: 0.0 alpha: 1.0] forKey: NSForegroundColorAttributeName];
		
		NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString: [self title] attributes:attributes] autorelease];
		[string drawAtPoint: NSMakePoint( 12, 4 )];
		
	} // if	
} // drawRect


@end
