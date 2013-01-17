//
//  ICACameraController.h
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ICACameraController : NSObject 
{
@public
	id delegate;
}


- (id)init:(id)delegate;
- (void)dealloc;

@end
