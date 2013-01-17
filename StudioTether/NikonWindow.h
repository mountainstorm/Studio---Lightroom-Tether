//
//  NikonWindow.h
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CameraWindow.h"



@interface NikonWindow : CameraWindow 
{
	IBOutlet id disclosureBox;
	IBOutlet id disclosureView;
	
	IBOutlet id shutterSpeed;
	IBOutlet id fStop;
	IBOutlet id iso;
	IBOutlet id storage;
	
	IBOutlet id liveViewToggle;
	IBOutlet id image;
	IBOutlet id zoom;
	IBOutlet id mode;
	
	NSArray *shutterSpeeds;
	NSArray *fStops;
	NSArray *isos;
	NSDictionary *zooms;
	NSDictionary *modes;
	
	int orientationDegrees;
}


+ (unsigned long)vendorID;


- (void)awakeFromNib;
- (NSString *)getNibName;
- (ICACamera *)allocICAObject;

- (id)init:(ICAObject)dev withDict:(NSDictionary *)dict andPreferences:(PreferencePanel *)preferences;
- (void)dealloc;

- (IBAction)shutterSpeedChanged:(id)sender;
- (IBAction)fStopChanged:(id)sender;
- (IBAction)isoChanged:(id)sender;
- (IBAction)storageChanged:(id)sender;
- (IBAction)toggleLiveView:(id)sender;
- (IBAction)zoomChanged:(id)sender;
- (IBAction)modeChanged:(id)sender;

- (void)imageLiveViewImageData:(NSData *)data;

- (void)cameraPropertyChanged:(uint32_t)property;
- (void)changeOrientation:(long)orientation;
- (void)slewToOrientation;

- (NSString *)shutterSpeedTitle:(NSNumber *)val;
- (NSString *)fStopTitle:(NSNumber *)val;
- (NSString *)isoTitle:(NSNumber *)val;
- (NSString *)zoomTitle:(NSNumber *)val;
- (NSString *)modeTitle:(NSNumber *)val;

@end
