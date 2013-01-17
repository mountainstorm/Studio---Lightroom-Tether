//
//  PreferencePanel.m
//  PreferencePanel
//
//  Created by drake on 02/10/2008.
//  Copyright 2008 Mountainstorm. All rights reserved.
//

#import "PreferencePanel.h"


@interface PreferencePanel( Private )
- (BOOL)savePreferences;
- (void)loadPreferences;
@end



@implementation PreferencePanel


- (void)awakeFromNib
{
	// set the default color to disabled
	[self->applicationPath setURL: [NSURL URLWithString: @""]]; // set the url to something so we dont get a nil when we serialize
	[self updateApplicationEnabled: nil];
	
	// load default settings
	[self loadPreferences];
	
} // awakeFromNib



// called when the preferences window tries to close.  This validates that there are valid paths
- (BOOL)windowShouldClose:(id)window
{
	BOOL retVal = TRUE;
	BOOL valid = TRUE;
	
	NSLog( @"Preferences window wants to close, validating" );
	if( self->lock == FALSE )
	{
		retVal = FALSE;
		
		// validate preferences
		if( ( valid == TRUE ) &&
			( [self->applicationEnable state] == NSOnState ) )
		{
			// application must not be a folder
			valid = FALSE;
			if(    ( [[[[self->applicationPath URL] absoluteString] pathExtension] caseInsensitiveCompare: @""] != NSOrderedSame )
				&& ( [[[[self->applicationPath URL] absoluteString] pathExtension] caseInsensitiveCompare: @"app"] != NSOrderedSame ) )
			{
				NSBeginCriticalAlertSheet( @"Invalid application",
										   @"Disable app", 
										   @"Select new app", 
										   nil,
										   self,
										   self,
										   @selector(validateSheetDidEnd:returnCode:contextInfo:),
										   NULL,
										   self,
										   @"The selected application is invalid",
										   nil );

			}
			else
			{
				valid = TRUE;
				
			} // if
		} // if
		
		if( valid == TRUE )
		{
			retVal = [self savePreferences];

		} // if
	} // if
	return( retVal );
	
} // windowShouldClose:



// updates the enabled status on the application download selector
- (IBAction)updateApplicationEnabled:(id)sender
{
	if( [self->applicationEnable state] == NSOffState )
	{
		[self->applicationPath setEnabled: FALSE];
		[self->applicationLabel setTextColor: [NSColor disabledControlTextColor]];
		
	}
	else
	{
		[self->applicationPath setEnabled: TRUE];
		[self->applicationLabel setTextColor: [NSColor controlTextColor]];
		
	} // if	
} // updateApplicationEnabled:


			
// show the "invalid application" warning sheet
- (void)validateSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	NSLog( @"Preference validate sheet run: %x", returnCode );
	if( returnCode == 1 ) 
	{
		[self->applicationEnable setState: NSOffState];
		[self updateApplicationEnabled: nil];
		[self savePreferences];
		    
    } // if
} // validateSheetDidEnd:returnCode:contextInfo:



// save preferences to user defaults
- (BOOL)savePreferences
{
	BOOL retVal = FALSE;
	
	// store the preferences
	NSArray *keys = [NSArray arrayWithObjects: @"customExtensions", 
											   @"downloadPath", 
											   @"application", 
											   @"applicationEnable", 
											   nil];
	NSArray *objects = [NSArray arrayWithObjects: [NSNumber numberWithInteger: [self->customExtensions state]], 
												  [[self->downloadPath URL] absoluteString],
												  [[self->applicationPath URL] absoluteString],
												  [NSNumber numberWithInteger: [self->applicationEnable state]], 
												  nil];
	NSDictionary *prefs = [NSDictionary dictionaryWithObjects: objects forKeys: keys];
	if( prefs != nil )
	{
		[[NSUserDefaults standardUserDefaults] setObject: prefs forKey: @"preferences"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		retVal = TRUE;
		
	} // if
	return( retVal );
	
} // savePreferences



- (void)loadPreferences
{
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] objectForKey: @"preferences"];
	if(    ( prefs != nil )  
	   && ( [prefs isKindOfClass: [NSDictionary class]] ) )
	{
		[self->customExtensions setState: [[prefs objectForKey: @"customExtensions"] integerValue]];
		[self->downloadPath setURL: [NSURL URLWithString: [prefs objectForKey: @"downloadPath"]]];
		[self->applicationPath setURL: [NSURL URLWithString: [prefs objectForKey: @"application"]]];
		
		[self->applicationEnable setState: [[prefs objectForKey: @"applicationEnable"] integerValue]];
		[self updateApplicationEnabled: nil];
		
	}
	else
	{
		// no defaults, set the download path to pictures
		FSRef picturesFolderRef = {0};
		OSErr err = FSFindFolder( kUserDomain, kPictureDocumentsFolderType, kDontCreateFolder, &picturesFolderRef );
		if( err == noErr )
		{
			[self->downloadPath setURL: (NSURL *)CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &picturesFolderRef )];

		}
		else
		{
			NSBeginCriticalAlertSheet( @"Unable to find Pictures",
									   @"OK", 
									   nil, 
									   nil,
									   self,
									   self,
									   nil,
									   NULL,
									   self,
									   @"Unable to location Pictures directory, please select a download location",
									   nil );
			[self deminiaturize: self];
			
		} // if
	} // if
} // loadPreferences



- (void)readOnlySettings:(BOOL)on
{
	if(    ( self->lock == FALSE )
		|| ( on == TRUE ) )
	{
		on = !on;
		[self->customExtensions setEnabled: on];
		[self->downloadPath setEnabled: on];
		
		[self->applicationEnable setEnabled: on];
		[self->applicationLabel setEnabled: on];
		[self->applicationPath setEnabled: on];

	} // if
} // readOnlySettings



- (BOOL)isLocked
{
	return( self->lock );
	
} // isLocked



- (void)setRuntimePreferences:(NSString *)path customExtensions:(BOOL)extensions application:(NSString *)appPath
{
	if( [path compare: @""] != NSOrderedSame )
	{
		[self readOnlySettings: TRUE];
		self->lock = TRUE;
		[self->downloadPath setURL: [NSURL URLWithString: path]];
		[self->customExtensions setState: extensions ? NSOnState: NSOffState];
		[self->applicationEnable setState: ( applicationPath != nil ? NSOnState: NSOffState )];
		if( applicationPath != nil )
		{
			[self->applicationPath setURL: [NSURL URLWithString: appPath]];
			
		} // if	
	}
	else
	{
		self->lock = FALSE;
		[self readOnlySettings: FALSE];
		[self loadPreferences]; // reload the user selected settings
		
	} // if	
} // setRuntimePreferences:customExtensions:application:



// get custom extension value
- (BOOL)customExtensions
{
	return( [self->customExtensions state] == NSOnState );
	
} // customExtensions



- (NSString *)downloadPath
{
	return( [[self->downloadPath URL] path] );
	
} // downloadFolder



- (BOOL)applicationEnable
{
	return( [self->applicationEnable state] == NSOnState );
	
} // applicationEnable



- (NSString *)applicationPath
{
	return( [[self->applicationPath URL] path] );
	
} // applicationPath



@end
