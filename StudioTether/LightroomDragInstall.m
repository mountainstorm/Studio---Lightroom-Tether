//
//  LightroomDragInstall.m
//  StudioTether
//
//  Created by drake on 04/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LightroomDragInstall.h"


@implementation LightroomDragInstall


- (id)initWithCoder:(NSCoder *)coder
{
    if( self = [super initWithCoder:coder] )
	{
		[self setImage: [[NSWorkspace sharedWorkspace] iconForFileType: @"lrplugin"]];
		
    } // if
    return( self );
	
} // initWithCode



- (void)mouseDown:(NSEvent *)event
{
	NSBundle *bundle = [NSBundle bundleForClass: [self class]];
	NSString *plugin = [[bundle resourcePath] stringByAppendingPathComponent: @"LightroomTether/LightroomTether.lrplugin"];

	// add the image types we can send the data as(we'll send the actual data when it's requested)
    NSPasteboard *dragPasteboard = [NSPasteboard pasteboardWithName: NSDragPboard];
    [dragPasteboard declareTypes: [NSArray arrayWithObject: NSFilenamesPboardType] owner: nil];
    [dragPasteboard setPropertyList: [NSArray arrayWithObject: plugin] forType: NSFilenamesPboardType];
	
	FSRef fs;
	OSErr err = FSPathMakeRef( (const UInt8 *)[plugin fileSystemRepresentation], &fs, NULL );
	NSLog( @"%@, %s,%s", plugin, GetMacOSStatusErrorString(err),GetMacOSStatusCommentString(err));
	//[[NSURL URLWithString: plugin] writeToPasteboard: dragPasteboard];

    // draw our original image as 50% transparent
    NSImage *dragImage = [[NSImage alloc] initWithSize: [[self image] size]]; 
	[dragImage lockFocus];
	[[self image] dissolveToPoint: NSZeroPoint fraction: .5];
    [dragImage unlockFocus];
	
    [dragImage setScalesWhenResized: YES];
    [dragImage setSize: [self bounds].size];
	
    // execute the drag
    [self dragImage: dragImage				// image to be displayed under the mouse
				 at: [self bounds].origin	// point to start drawing drag image
			 offset: NSZeroSize				// no offset, drag starts at mousedown location
			  event: event					// mousedown event
		 pasteboard: dragPasteboard			// pasteboard to pass to receiver
			 source: self					// object where the image is coming from
		  slideBack: YES];					// if the drag fails slide the icon back
    [dragImage release];	

} // mouseDown



- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return( NSDragOperationCopy );//send data as copy operation
	
} // draggingSourceOperationMaskForLocal



- (BOOL)acceptsFirstMouse:(NSEvent *)event 
{
    return( YES );
	
} // acceptsFirstMouse


@end
