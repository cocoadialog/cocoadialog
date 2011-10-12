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
	unsigned long result;
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	NSString *file = nil;
	NSString *dir = nil;
	
	[self setOptions:options];
	[self setMisc:openPanel];
	NSArray *extensions = [self extensionsFromOptionKey:@"with-extensions"];

	// set select-multiple
	if ([options hasOpt:@"select-multiple"]) {
		[openPanel setAllowsMultipleSelection:YES];
	} else {
		[openPanel setAllowsMultipleSelection:NO];
	}

	// set select-directories
	if ([options hasOpt:@"select-directories"]) {
		[openPanel setCanChooseDirectories:YES];
	} else {
		[openPanel setCanChooseDirectories:NO];
	}
	if ([options hasOpt:@"select-only-directories"]) {
		[openPanel setCanChooseDirectories:YES];
		[openPanel setCanChooseFiles:NO];
	}
	
	if ([options hasOpt:@"packages-as-directories"]) {
		[openPanel setTreatsFilePackagesAsDirectories:YES];
	} else {
		[openPanel setTreatsFilePackagesAsDirectories:NO];
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
	if ([self windowNeedsResize:openPanel]) {
		[openPanel setContentSize:[self findNewSizeForWindow:openPanel]];
	}
	
    // Reposition Panel
    [self findPositionForWindow:openPanel];
    
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber10_6) {
        result = [openPanel runModalForDirectory:dir file:file types:extensions];
    }
    else {
        if (dir != nil) {
            NSURL * url = [[[NSURL alloc] initFileURLWithPath:dir] autorelease];
            [openPanel setDirectoryURL:url];
        }
        [openPanel setAllowedFileTypes:extensions];
        [openPanel setNameFieldStringValue:file];
        [openPanel runModal];
    }


	if (result == NSOKButton) {
		return [openPanel filenames];
	} else {
		return [NSArray array];
	}
}


@end
