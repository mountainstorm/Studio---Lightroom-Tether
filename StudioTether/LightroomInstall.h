//
//  LightroomInstall.h
//  StudioTether
//
//  Created by drake on 04/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LightroomInstall : NSObject 
{
	IBOutlet id installLightroomTetherWindow;
}

- (IBAction)installLightroomTether_openUIAccess:(id)sender;
- (IBAction)installLightroomTether_openLightroom:(id)sender;

@end
