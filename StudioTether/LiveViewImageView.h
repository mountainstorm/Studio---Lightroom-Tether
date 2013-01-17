//
//  LiveViewImageView.h
//  StudioTether
//
//  Created by drake on 07/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LiveViewImageView : NSImageView 
{
	float borderWidth;
	float borderHeight;
}

- (void)awakeFromNib;
- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;

@end
