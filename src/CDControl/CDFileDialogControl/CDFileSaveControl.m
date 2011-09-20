/*
	CDFileSaveControl.m
	CocoaDialog
	Copyright (C) 2004-2006 Mark A. Stratman <mark@sporkstorms.org>
 
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

#import "CDFileSaveControl.h"


@implementation CDFileSaveControl

- (NSDictionary *) availableKeys
{
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];

	return [NSDictionary dictionaryWithObjectsAndKeys:
		vOne,  @"text",
		vMul,  @"with-extensions",
		vOne,  @"with-directory",
		vOne,  @"with-file",
		vNone, @"packages-as-directories",
		vNone, @"no-create-directories",
		nil];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	int result;
	NSSavePanel *panel = [NSSavePanel savePanel];
	NSString *file = @"";
	NSString *dir = nil;
	
	[self setOptions:options];
	[self setMisc:panel];

	NSArray *extensions = [self extensionsFromOptionKey:@"with-extensions"];
	[panel setAllowedFileTypes:extensions];

	if ([options hasOpt:@"packages-as-directories"]) {
		[panel setTreatsFilePackagesAsDirectories:YES];
	} else {
		[panel setTreatsFilePackagesAsDirectories:NO];
	}

	if ([options hasOpt:@"no-create-directories"]) {
		[panel setCanCreateDirectories:NO];
	} else {
		[panel setCanCreateDirectories:YES];
	}

	// set starting file (to be used later with 
	// runModal...) - doesn't work.
	if ([options optValue:@"with-file"] != nil) {
		file = [options optValue:@"with-file"];
	}
	// set starting directory (to be used later with runModal...)
	if ([options optValue:@"with-directory"] != nil) {
		dir = [options optValue:@"with-directory"];
	}

	// resize window if user specified alternate width/height
	if ([self windowNeedsResize:panel]) {
		[panel setContentSize:[self findNewSizeForWindow:panel]];
	}
	
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber10_6) {
        result = [panel runModalForDirectory:dir file:file];
    }
    else {
        if (dir != nil) {
            NSURL * url = [[[NSURL alloc] initFileURLWithPath:dir] autorelease];
            [panel setDirectoryURL:url];
        }
        [panel setNameFieldStringValue:file];
        [panel runModal];
    }

	if (result == NSFileHandlingPanelOKButton) {
		return [NSArray arrayWithObject:[panel filename]];
	} else {
		return [NSArray array];
	}
}

@end
