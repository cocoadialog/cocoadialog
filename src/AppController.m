/*
	AppController.m
	CocoaDialog
	Copyright (C) 2004 Mark A. Stratman <mark@sporkstorms.org>
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#import "AppController.h"

#import "CDBubbleControl.h"
#import "CDFileSelectControl.h"
#import "CDFileSaveControl.h"
#import "CDProgressbarControl.h"

#import "CDMsgboxControl.h"
#import "CDYesNoMsgboxControl.h"
#import "CDOkMsgboxControl.h"

#import "CDTextboxControl.h"

#import "CDInputboxControl.h"
#import "CDStandardInputboxControl.h"

#import "CDPopUpButtonControl.h"
#import "CDStandardPopUpButtonControl.h"

#import "CDCheckboxControl.h"
#import "CDRadioControl.h"

@implementation AppController

- (void) awakeFromNib
{
	CDControl *control;
	CDOptions *options = nil;
	NSArray *rv;
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:10];
	NSString *runMode = nil;
	NSMutableDictionary *extraOptions = [NSMutableDictionary dictionary];

	NSDictionary *globalKeys;
	
	globalKeys = [CDControl globalAvailableKeys];

	[arguments addObjectsFromArray:[[NSProcessInfo processInfo] arguments]];
	if ([arguments count] >= 2) {
		[arguments removeObjectAtIndex:0]; // Remove program name.
		runMode = [arguments objectAtIndex:0];
		[arguments removeObjectAtIndex:0]; // Remove the run-mode
	}

	options = [CDOptions getOpts:arguments availableKeys:globalKeys];
		
	// Bring application into focus.
	// Because this application isn't going to be double-clicked, or
	// launched with the "open" command-line tool, it won't necessarily
	// come to the front automatically.
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

	control = [[[self chooseControl:runMode useOptions:options addExtraOptionsTo:extraOptions] init] autorelease];

	if (control != nil) {
		int i;

		// Now that we have the control, we can re-get the options to
		// include the local options for that control.
		options = [control controlOptionsFromArgs:arguments
			withGlobalKeys:globalKeys];
		// Add any extras chooseControl came up with
		NSEnumerator *en = [extraOptions keyEnumerator];
		NSString *key;
		while (key = [en nextObject]) {
			[options setOption:[extraOptions objectForKey:key] forKey:key];
		}
        
		// Run the control (a modal window)
		rv = [control runControlFromOptions:options];
		
		// print all the returned lines
		if (rv != nil) {
			NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
			for (i = 0; i < [rv count]; i++) {
				if (fh) {
					[fh writeData:[[rv objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
				}
				if (![options hasOpt:@"no-newline"] || i+1 < [rv count]) 
				{
					if (fh) {
						[fh writeData:[[NSString stringWithString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
					}
				}
			}
		} else if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Control returned nil."];
		}
	} else if ([options hasOpt:@"debug"]
		   || [runMode isEqualToString:@"--debug"]) 
	{
		[CDControl debug:@"No run-mode, or invalid runmode provided as first argument."];
	}
	[NSApp terminate:self];
}

- (CDControl *) chooseControl:(NSString *)runMode useOptions:options addExtraOptionsTo:(NSMutableDictionary *)extraOptions
{
	if (runMode == nil) {
		[CDControl printHelpTo:[NSFileHandle fileHandleWithStandardError]];
		return nil;
	}
    else if ([runMode isEqualToString:@"--help"]) {
		[CDControl printHelpTo:[NSFileHandle fileHandleWithStandardOutput]];
		return nil;
	}
    else if ([runMode isEqualToString:@"fileselect"]) {
		return [[(CDControl *)[CDFileSelectControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"filesave"]) {
		return [[(CDControl *)[CDFileSaveControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"checkbox"]) {
		return [[(CDControl *)[CDCheckboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"radio"]) {
		return [[(CDControl *)[CDRadioControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"msgbox"]) {
		return [[(CDControl *)[CDMsgboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"yesno-msgbox"]) {
		return [[(CDControl *)[CDYesNoMsgboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"ok-msgbox"]) {
		return [[(CDControl *)[CDOkMsgboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"textbox"]) {
		return [[(CDControl *)[CDTextboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"progressbar"]) {
		return [[(CDControl *)[CDProgressbarControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"inputbox"]) {
		return [[(CDControl *)[CDInputboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"standard-inputbox"]) {
		return [[(CDControl *)[CDStandardInputboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"secure-standard-inputbox"]) {
		[extraOptions setObject:[NSNumber numberWithBool:NO] forKey:@"no-show"];
		return [[(CDControl *)[CDStandardInputboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"secure-inputbox"]) {
		[extraOptions setObject:[NSNumber numberWithBool:NO] forKey:@"no-show"];
		return [[(CDControl *)[CDInputboxControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"dropdown"]) {
		return [[(CDControl *)[CDPopUpButtonControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"standard-dropdown"]) {
		return [[(CDControl *)[CDStandardPopUpButtonControl alloc] initWithOptions:options] autorelease];
	}
    else if ([runMode isEqualToString:@"bubble"]) {
		return [[(CDControl *)[CDBubbleControl alloc] initWithOptions:options] autorelease];
	}
    else {
		NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
		NSString *output = [NSString stringWithFormat:@"Unknown dialog type: %@\n", runMode]; 
		if (fh) {
			[fh writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
		}
		[CDControl printHelpTo:fh];
		return nil;
	}
}

@end
