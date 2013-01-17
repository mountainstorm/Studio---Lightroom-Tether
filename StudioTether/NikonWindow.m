//
//  NikonWindow.m
//  StudioTether
//
//  Created by drake on 04/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import "NikonWindow.h"
#import "ICANikonCamera.h"



#define SHUTTERSPEED_DENOMINATOR( x )	( [x unsignedLongValue] & 0x0000FFFF )
#define SHUTTERSPEED_NUMERATOR( x )		( ( [x unsignedLongValue] & 0xFFFF0000 ) >> 16 )



static NSInteger sortShutterSpeeds( id num1, id num2, void *context );



@implementation NikonWindow



+ (unsigned long)vendorID
{
	return( 1200 ); 
	
} // vendorID



- (void)awakeFromNib
{
	[self->disclosureBox addSubview: self->disclosureView];
	[self toggleLiveView: self]; // make sure its in the right state
	[self slewToOrientation];

} // awakeFromNib



- (NSString *)getNibName
{
	return( @"NikonWindow" );
	
} // getNibName



- (ICACamera *)allocICAObject
{
	return( [ICANikonCamera alloc] );
	
} // allocaICAObject



- (id)init:(ICAObject)dev withDict:(NSDictionary *)dict andPreferences:(PreferencePanel *)pref
{
	id retVal = nil;
	if( [super init: dev withDict: dict andPreferences: pref] )
	{
		// shutter speeds
		NSDictionary *prop = [self->camera getDevicePropDesc: kCameraProperty_NikonShutterSpeed];
		NSArray *orig = [prop objectForKey: @"enum"];
		self->shutterSpeeds = [[orig sortedArrayUsingFunction: sortShutterSpeeds context: NULL] retain];
		
		NSNumber *item = nil;
		NSEnumerator *it = [self->shutterSpeeds objectEnumerator];
		while( item = [it nextObject] )
		{
			[self->shutterSpeed addItemWithTitle: [self shutterSpeedTitle: item]];
			
		} // while
		[self->shutterSpeed selectItemWithTitle: [self shutterSpeedTitle: [prop objectForKey: @"currentValue"]]];
		
		// f stops
		prop = [self->camera getDevicePropDesc: kCameraProperty_NikonFNumber];
		self->fStops = [[prop objectForKey: @"enum"] retain];
		
		item = nil;
		it = [self->fStops objectEnumerator];
		while( item = [it nextObject] )
		{
			[self->fStop addItemWithTitle: [self fStopTitle: item]];
			
		} // while
		[self->fStop selectItemWithTitle: [self fStopTitle: [prop objectForKey: @"currentValue"]]];
		
		// ios values
		prop = [self->camera getDevicePropDesc: kCameraProperty_NikonExposureIndex];
		self->isos = [[prop objectForKey: @"enum"] retain];

		item = nil;
		it = [self->isos objectEnumerator];
		while( item = [it nextObject] )
		{
			[self->iso addItemWithTitle: [self isoTitle: item]];
			
		} // while
		[self->iso selectItemWithTitle: [self isoTitle: [prop objectForKey: @"currentValue"]]];
		
		// zoom values
		prop = [self->camera getDevicePropDesc: kCameraProperty_NikonLiveViewImageZoomRatio];
		if( prop != nil )
		{
			self->zooms = [[prop objectForKey: @"range"] retain];
			unsigned long i = 0;
			unsigned long min = [[self->zooms objectForKey: @"min"] unsignedLongValue];
			unsigned long max = [[self->zooms objectForKey: @"max"] unsignedLongValue];
			unsigned long step = [[self->zooms objectForKey: @"step"] unsignedLongValue];
			for( i = min; i <= max; i += step )
			{
				[self->zoom addItemWithTitle: [self zoomTitle: [NSNumber numberWithUnsignedLong: i]]];
				
			} // while
			[self->zoom selectItemWithTitle: [self zoomTitle: [prop objectForKey: @"currentValue"]]];
			
			// give the list of modes
			prop = [self->camera getDevicePropDesc: kCameraProperty_NikonLiveViewImageZoomRatio];
			self->modes = [[prop objectForKey: @"range"] retain];
			min = [[self->modes objectForKey: @"min"] unsignedLongValue];
			max = 1; // NOTE: for some reason it gives us 6 mode! [[self->modes objectForKey: @"max"] unsignedLongValue];
			step = [[self->modes objectForKey: @"step"] unsignedLongValue];
			for( i = min; i <= max; i += step )
			{
				[self->mode addItemWithTitle: [self modeTitle: [NSNumber numberWithUnsignedLong: i]]];
				
			} // while
			[self->mode selectItemWithTitle: [self modeTitle: [prop objectForKey: @"currentValue"]]];
			[self changeOrientation: [[prop objectForKey: @"currentValue"] intValue]];
			
		}
		else
		{
			[self->liveViewToggle setEnabled: FALSE];
			
		} // if
		retVal = self;

	} // if
	return( retVal );
	
} // init:withDict:andPreferences



- (void)dealloc
{
	[self->shutterSpeeds release];
	[self->fStops release];
	[self->isos release];
	[self->zooms release];
	[self->modes release];
	[super dealloc];
	
} // dealloc





- (IBAction)shutterSpeedChanged:(id)sender
{
	NSLog( @"shutterSpeedChanged" );
	uint32_t val = [[self->shutterSpeeds objectAtIndex: [self->shutterSpeed indexOfSelectedItem]] unsignedLongValue];
	[self->camera setDeviceProp: kCameraProperty_NikonShutterSpeed withData: &val length: sizeof( uint32_t )];

} // shutterSpeedChanged



- (IBAction)fStopChanged:(id)sender
{
	NSLog( @"fStopChanged" );
	uint32_t val = [[self->fStops objectAtIndex: [self->fStop indexOfSelectedItem]] unsignedLongValue];
	[self->camera setDeviceProp: kCameraProperty_NikonFNumber withData: &val length: sizeof( uint16_t )];
	
} // fStopChanged



- (IBAction)isoChanged:(id)sender
{
	NSLog( @"isoChanged" );
	uint32_t val = [[self->isos objectAtIndex: [self->iso indexOfSelectedItem]] unsignedLongValue];
	[self->camera setDeviceProp: kCameraProperty_NikonExposureIndex withData: &val length: sizeof( uint16_t )];
	
} // isoChanged



- (IBAction)storageChanged:(id)sender
{
	NSLog( @"storageChanged" );
	[self->camera setSDRAMCapture: [[self->storage titleOfSelectedItem] compare: @"PC"] == NSOrderedSame ? TRUE: FALSE];

} // storageChanged



- (IBAction)zoomChanged:(id)sender
{
	NSLog( @"zoomChanged" );
	unsigned long min = [[self->zooms objectForKey: @"min"] unsignedLongValue];
	unsigned long step = [[self->zooms objectForKey: @"step"] unsignedLongValue];
	
	uint8_t val = ( [self->zoom indexOfSelectedItem] * step ) + min;
	[self->camera setDeviceProp: kCameraProperty_NikonLiveViewImageZoomRatio withData: &val length: sizeof( uint8_t )];
	
} // zoomChanged



- (IBAction)modeChanged:(id)sender
{
	NSLog( @"modeChanged" );
	unsigned long min = [[self->modes objectForKey: @"min"] unsignedLongValue];
	unsigned long step = [[self->modes objectForKey: @"step"] unsignedLongValue];
	
	uint8_t val = ( [self->mode indexOfSelectedItem] * step ) + min;
	
	// we can't change the mode without stopping liveview first
	[self->camera setLiveViewMode: FALSE];
	[self->camera setDeviceProp: kCameraProperty_NikonLiveViewMode withData: &val length: sizeof( uint8_t )];
	[self->camera setLiveViewMode: TRUE];
	
} // modeChanged



// toggle nikon into liveview (if its supported)
- (IBAction)toggleLiveView:(id)sender
{
	NSLog( @"toggleLiveview:" );
	if( [self->liveViewToggle state] == NSOnState )
	{
		// put camera into PC mode
		[self->storage selectItemWithTitle: @"PC"];
		[self->camera setSDRAMCapture: TRUE];
		[self slewToOrientation];
		
	}
	else
	{
		// closed
		NSLog( @"stop liveview" );

		NSSize small = { 250, 68 };
		NSRect newFrame = [self->window frame];
		newFrame.size = small;
		newFrame.origin.y += [self->window frame].size.height - small.height;
		[self->window setMinSize: small];
		[self->window setMaxSize: small];
		[self->window setShowsResizeIndicator: FALSE];
		[self->window setFrame: newFrame display: YES animate: YES];
		
	} // if
	
	if(     ( [self->camera setLiveViewMode: [self->liveViewToggle state] == NSOnState ? TRUE: FALSE] == FALSE ) 
		 && ( [self->liveViewToggle state] == NSOnState ) )
	{
		NSBeginCriticalAlertSheet( @"Unable to set LiveView mode",
								  @"Continue", 
								  nil,
								  nil,
								  self->window,
								  nil,
								  NULL,
								  NULL,
								  self,
								  @"Perhaps your camera doesn't support liveview",
								  nil );

	} // if
} // toggleLiveView:



- (void)imageLiveViewImageData:(NSData *)data
{
	NSImage *i = [[[NSImage alloc] initWithData: data] autorelease];
	if( self->orientationDegrees != 0 )
	{
		NSSize beforeSize = [i size];
		NSSize afterSize = self->orientationDegrees == 90 || self->orientationDegrees == -90 ? NSMakeSize( beforeSize.height, beforeSize.width ): beforeSize;
		NSImage *newImage = [[[NSImage alloc] initWithSize: afterSize] autorelease];
		NSAffineTransform *trans = [NSAffineTransform transform];
		
		[newImage lockFocus];
		[trans translateXBy: afterSize.width * 0.5 yBy: afterSize.height * 0.5];
		[trans rotateByDegrees: self->orientationDegrees];
		[trans translateXBy: -beforeSize.width * 0.5 yBy: -beforeSize.height * 0.5];
		[trans set];
		[i drawAtPoint: NSZeroPoint
			  fromRect: NSMakeRect( 0, 0, beforeSize.width, beforeSize.height )
			 operation: NSCompositeCopy
			  fraction: 1.0];
		[newImage unlockFocus];
		i = newImage;
		
	} // if	
	[self->image setImage: i];
	
} // imageLiveViewImageData



- (void)cameraPropertyChanged:(uint32_t)property
{
	NSLog( @"property changed: %x", property );
	if( property == kCameraProperty_NikonShutterSpeed )
	{
		NSDictionary *prop = [self->camera getDevicePropDesc: property];
		[self->shutterSpeed selectItemAtIndex: [self->shutterSpeeds indexOfObject: [prop objectForKey: @"currentValue"]]];
		
	}
	else if( property == kCameraProperty_NikonFNumber )
	{
		NSDictionary *prop = [self->camera getDevicePropDesc: property];
		[self->fStop selectItemAtIndex: [self->fStops indexOfObject: [prop objectForKey: @"currentValue"]]];
		
	}
	else if( property == kCameraProperty_NikonExposureIndex )
	{
		NSDictionary *prop = [self->camera getDevicePropDesc: property];
		[self->iso selectItemAtIndex: [self->isos indexOfObject: [prop objectForKey: @"currentValue"]]];
		
	}
	else if( property == kCameraProperty_NikonOrientation )
	{
		NSDictionary *prop = [self->camera getDevicePropDesc: property];		
		[self changeOrientation: [[prop objectForKey: @"currentValue"] intValue]];

	} // if	
} // cameraPropertyChanged



- (void)changeOrientation:(long)orientation
{
	switch( orientation )
	{
		case( kCameraProperty_NikonOrientation_WidthwiseUpsidedown ):
			self->orientationDegrees = 180;
			break;
			
		case( kCameraProperty_NikonOrientation_LengthwiseGripup ):
			self->orientationDegrees = 90;
			break;
			
		case( kCameraProperty_NikonOrientation_LengthwiseGripdown ):
			self->orientationDegrees = -90;
			break;
			
		case( kCameraProperty_NikonOrientation_Widthwise ):
		default:
			self->orientationDegrees = 0;
			break;
			
	} // switch
	NSLog( @"Orientation changed: %x", self->orientationDegrees );
	[self slewToOrientation]; 

} // changeOrientation



- (void)slewToOrientation
{
	if( [self->liveViewToggle state] == NSOnState )
	{
		NSRect newFrame = [self->window frame];
		if( self->orientationDegrees == 0 || self->orientationDegrees == 180 )
		{
			newFrame.size.width = 680; // = 640 image width
			newFrame.size.height = 568;  // = 480 image height
			newFrame.origin.y += [self->window frame].size.height - newFrame.size.height;
			
		}
		else
		{
			newFrame.size.width = 520; // = 480 image width
			newFrame.size.height = 728; // = 640 image height
			newFrame.origin.y += [self->window frame].size.height - newFrame.size.height;

		} // if
		 
		NSSize defaultMaxSize = {FLT_MAX, FLT_MAX}; 
		[self->window setMaxSize: defaultMaxSize ];
		[self->window setMinSize: NSMakeSize( 300, 300 * ( newFrame.size.height / newFrame.size.width ) )];
		[self->window setAspectRatio: newFrame.size];
		[self->window setShowsResizeIndicator: TRUE];
		[self->window setFrame: newFrame display: YES animate: YES];
		NSLog( @"ImageWidth: %f, %f", [self->image frame].size.width, [self->image frame].size.height );
	
	} // if
} // slewToOrientation



- (NSString *)shutterSpeedTitle:(NSNumber *)val
{
	NSString *retVal = nil;
	if( [val unsignedLongValue] == 0xFFFFFFFF )
	{
		retVal = [[NSString alloc] initWithFormat: @"bulb" ];
	
	}
	else if( [val unsignedLongValue] == 0xFFFFFFFE )
	{
		retVal = [[NSString alloc] initWithFormat: @"x speed" ];

	}
	else
	{
		double value = ( ( double ) SHUTTERSPEED_NUMERATOR( val ) ) / SHUTTERSPEED_DENOMINATOR( val );
		if( value > 1.0 )
		{
			if( ( value - ( ( unsigned long ) value ) ) > 0.0 )
			{
				retVal = [[NSString alloc] initWithFormat: @"%.1f\"", value ];
			
			}
			else
			{
				retVal = [[NSString alloc] initWithFormat: @"%.0f\"", value ];
				
			} // if			
		}
		else
		{
			value = ( ( double ) SHUTTERSPEED_DENOMINATOR( val ) ) / SHUTTERSPEED_NUMERATOR( val );
			if( ( value - ( ( unsigned long) value ) ) > 0.0 )
			{
				retVal = [[NSString alloc] initWithFormat: @"%.1f", value ];
				
			}
			else
			{
				retVal = [[NSString alloc] initWithFormat: @"%.0f", value ];
				
			} // if						
		} // if
	} // if
	return( retVal );

} // shutterSpeedTitle



- (NSString *)fStopTitle:(NSNumber *)val
{
	NSString *retVal = nil;
	double value = ( ( double ) [val unsignedLongValue] ) / 100;
	if( ( value - ( ( unsigned long ) value ) ) > 0.0 )
	{
		retVal = [[NSString alloc] initWithFormat: @"%.1f", value ];
		
	}
	else
	{
		retVal = [[NSString alloc] initWithFormat: @"%.0f", value ];
		
	} // if			
	[retVal autorelease];
	return( retVal );
	
} // fStopTitle



- (NSString *)isoTitle:(NSNumber *)val
{
	return( [[[NSString alloc] initWithFormat: @"%u", [val unsignedLongValue]] autorelease] );
	
} // isoTitle



- (NSString *)zoomTitle:(NSNumber *)val
{
	NSString *retVal = nil;
	unsigned long min = [[self->zooms objectForKey: @"min"] unsignedLongValue];
	
	switch( [val unsignedLongValue] - min )
	{
		case( 0 ):	retVal = @"0%";		break;
		case( 1 ):	retVal = @"25%";	break;
		case( 2 ):	retVal = @"33%";	break;
		case( 3 ):	retVal = @"50%";	break;
		case( 4 ):	retVal = @"66%";	break;
		case( 5 ):	retVal = @"100%";	break;
		case( 6 ):	retVal = @"200%";	break;
		default:	retVal = @"Err";	break;
			
	} // switch
	return( retVal );
	
} // zoomTitle



- (NSString *)modeTitle:(NSNumber *)val
{
	NSString *retVal = nil;
	unsigned long min = [[self->modes objectForKey: @"min"] unsignedLongValue];
	
	switch( [val unsignedLongValue] - min )
	{
		case( 0 ):	retVal = @"Hand-held";	break;
		case( 1 ):	retVal = @"Tripod";		break;
		default:	retVal = @"Err";		break;
			
	} // switch
	return( retVal );
	
} // modeTitle



@end



static NSInteger sortShutterSpeeds( id num1, id num2, void *context )
{
	NSInteger retVal = NSOrderedSame;
	double val1 = ( ( double ) SHUTTERSPEED_DENOMINATOR( num1 ) ) / SHUTTERSPEED_NUMERATOR( num1 );
	double val2 = ( ( double ) SHUTTERSPEED_DENOMINATOR( num2 ) ) / SHUTTERSPEED_NUMERATOR( num2 );
	if( val1 < val2 )
	{
		retVal = NSOrderedAscending;
		
	}
	else if( val1 > val2 )
	{
		retVal = NSOrderedDescending;
		
	} // if
	
	if(    ( [num1 unsignedLongValue] == 0xFFFFFFFF )
	    || ( [num1 unsignedLongValue] == 0xFFFFFFFE )
		|| ( [num2 unsignedLongValue] == 0xFFFFFFFF ) 
		|| ( [num2 unsignedLongValue] == 0xFFFFFFFE ) )
	{
		retVal = ( [num1 unsignedLongValue] < [num2 unsignedLongValue] ) ?
						NSOrderedAscending:
						NSOrderedDescending;

	} // if
	return( retVal );
	
} // sortShutterSpeeds
