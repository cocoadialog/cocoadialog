/*
	CDFileSelectControl.m
	cocoaDialog
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

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionMultipleStrings name:@"allowed-files"]];
    [options addOption:[CDOptionFlag            name:@"select-directories"]];
    [options addOption:[CDOptionFlag            name:@"select-only-directories"]];
    [options addOption:[CDOptionFlag            name:@"no-select-directories"]];
    [options addOption:[CDOptionFlag            name:@"select-multiple"]];
    [options addOption:[CDOptionFlag            name:@"no-select-multiple"]];

    return options;
}

- (void) createControl {
    savePanel = [NSOpenPanel openPanel];
	NSString *file = nil;
	NSString *dir = nil;

	[self setMisc];

    NSOpenPanel *openPanel = (NSOpenPanel *)savePanel;

	// Multiple selection.
    [openPanel setAllowsMultipleSelection:arguments.options[@"select-multiple"].wasProvided];

	// Select directories.
    [openPanel setCanChooseDirectories:arguments.options[@"create-directories"].wasProvided || arguments.options[@"select-directories"].wasProvided];

    // Select only directories.
    if (arguments.options[@"select-only-directories"].wasProvided) {
		[openPanel setCanChooseDirectories:YES];
		[openPanel setCanChooseFiles:NO];
	}

    // Packages as directories.
    [openPanel setTreatsFilePackagesAsDirectories:arguments.options[@"packages-as-directories"].wasProvided];

	// set starting file (to be used later with 
	// runModal...) - doesn't work.
	if (arguments.options[@"with-file"].wasProvided) {
		file = arguments.options[@"with-file"].stringValue;
	}
	// set starting directory (to be used later with runModal...)
	if (arguments.options[@"with-directory"].wasProvided) {
		dir = arguments.options[@"with-directory"].stringValue;
	}
    
    // Check for dir or file path existance.
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    // Directory
    if (dir != nil && ![fm fileExistsAtPath:dir]) {
        [self warning:@"Option --with-directory specifies a directory that does not exist: %@", dir, nil];
    }
    // File
    if (file != nil && ![fm fileExistsAtPath:file]) {
        [self warning:@"Option --with-file specifies a file that does not exist: %@", file, nil];
    }

    panel.panel = openPanel;

	// resize window if user specified alternate width/height
    if ([panel needsResize]) {
		[openPanel setContentSize:[panel findNewSize]];
	}
	
    // Reposition Panel
    [panel setPosition];
    
    [self setTimeout];
    
    NSInteger result;

    if (dir != nil) {
        if (file != nil) {
            dir = [dir stringByAppendingString:@"/"];
            dir = [dir stringByAppendingString:file];
        }
        NSURL * url = [[[NSURL alloc] initFileURLWithPath:dir] autorelease];
        openPanel.directoryURL = url;
    }
    result = [openPanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        controlExitStatus = -1;
        NSEnumerator *en = [openPanel.URLs objectEnumerator];
        id key;
        while (key = [en nextObject]) {
            [controlReturnValues addObject:[key path]];
        }
    }
    else {
        controlExitStatus = -2;
        controlReturnValues = [NSMutableArray array];
    }
    [super stopControl];
}

- (BOOL)isExtensionAllowed:(NSString *)filename {
    BOOL extensionAllowed = YES;
    if (extensions != nil && extensions.count) {
        NSString* extension = filename.pathExtension;
        extensionAllowed = [extensions containsObject:extension];
    }
    if (arguments.options[@"allowed-files"].wasProvided) {
        NSArray *allowedFiles = arguments.options[@"allowed-files"].arrayValue;
        if (allowedFiles != nil && allowedFiles.count) {
            if ([allowedFiles containsObject:filename.lastPathComponent]) {
                return YES;
            }
            else {
                return NO;
            }
        }
        else {
            return extensionAllowed;
        }
    }
    else {
        return extensionAllowed;
    }
}

@end
