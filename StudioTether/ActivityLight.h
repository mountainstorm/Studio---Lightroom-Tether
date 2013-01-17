//
//  ActivityLight.h
//  StudioTether
//
//  Created by drake on 24/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ActivityLight : NSView 
{
	BOOL state;
}


- (BOOL)state;
- (void)setState:(BOOL)on;
- (void)drawRect:(NSRect)cellFrame;


@end
