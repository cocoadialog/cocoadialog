/*
	CDFileSelectControl.m
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

#import "CDFileSelectControl.h"

@implementation CDFileSelectControl

- (NSDictionary *) availableKeys
{
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];

	return [NSDictionary dictionaryWithObjectsAndKeys:
		vOne,  @"text",
		vNone, @"select-directories",
		vNone, @"select-only-directories",
		vNone, @"no-select-directories",
		vNone, @"select-multiple",
		vNone, @"no-select-multiple",
		vMul,  @"with-extensions",
		vOne,  @"with-directory",
		vOne,  @"with-file",
		vNone, @"packages-as-directories",
		nil];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	int result;
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSString *file = nil;
	NSString *dir = nil;
	
	[self setOptions:options];
	[self setMisc:panel];
	NSArray *extensions = [self extensionsFromOptionKey:@"with-extensions"];

	// set select-multiple
	if ([options hasOpt:@"select-multiple"]) {
		[panel setAllowsMultipleSelection:YES];
	} else {
		[panel setAllowsMultipleSelection:NO];
	}

	// set select-directories
	if ([options hasOpt:@"select-directories"]) {
		[panel setCanChooseDirectories:YES];
	} else {
		[panel setCanChooseDirectories:NO];
	}
	if ([options hasOpt:@"select-only-directories"]) {
		[panel setCanChooseDirectories:YES];
		[panel setCanChooseFiles:NO];
	}
	
	if ([options hasOpt:@"packages-as-directories"]) {
		[panel setTreatsFilePackagesAsDirectories:YES];
	} else {
		[panel setTreatsFilePackagesAsDirectories:NO];
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
        result = [panel runModalForDirectory:dir file:file types:extensions];
    }
    else {
        if (dir != nil) {
            NSURL * url = [[[NSURL alloc] initFileURLWithPath:dir] autorelease];
            [panel setDirectoryURL:url];
        }
        [panel setAllowedFileTypes:extensions];
        [panel setNameFieldStringValue:file];
        [panel runModal];
    }


	if (result == NSOKButton) {
		return [panel filenames];
	} else {
		return [NSArray array];
	}
}


@end
