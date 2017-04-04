/*
	CDFileSaveControl.m
	cocoaDialog
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

- (NSMutableDictionary *) availableOptions {
    NSMutableDictionary *availableOptions = [super availableOptions];
    [availableOptions addEntriesFromDictionary:@{
                                     @"no-create-directories": @CDOptionsNoValues,
                                     }];
    return availableOptions;
}

- (void) createControl {
	savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:nil];
    
	NSString *file = @"";
	NSString *dir = nil;
	
    self.options = options;
	[self setMisc];

	if ([options hasOpt:@"packages-as-directories"]) {
		[savePanel setTreatsFilePackagesAsDirectories:YES];
	} else {
		[savePanel setTreatsFilePackagesAsDirectories:NO];
	}

	if ([options hasOpt:@"no-create-directories"]) {
		[savePanel setCanCreateDirectories:NO];
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
    
    // Only check for dir or file path existance if debug is enabled.
    if ([options hasOpt:@"debug"]) {
        NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
        // Directory
        if (dir != nil && ![fm fileExistsAtPath:dir]) {
            [self debug:[NSString stringWithFormat:@"Option --with-directory specifies a directory that does not exist: %@", dir]];
        }
    }
    
    panel.panel = savePanel;

	// resize window if user specified alternate width/height
    if ([panel needsResize]) {
		[savePanel setContentSize:[panel findNewSize]];
	}
	
    // Reposition Panel
    [panel setPosition];
    
    [self setTimeout];
	
    NSInteger result;
    if (dir != nil) {
        NSURL * url = [[[NSURL alloc] initFileURLWithPath:dir] autorelease];
        savePanel.directoryURL = url;
    }
    savePanel.nameFieldStringValue = file;
    result = [savePanel runModal];

    if (result == NSFileHandlingPanelOKButton) {
        controlExitStatus = -1;
        [controlReturnValues addObject:savePanel.URL.path];
    }
    else {
        controlExitStatus = -2;
        controlReturnValues = [NSMutableArray array];
    }
    [super stopControl];
}

@end
