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

- (NSDictionary *) availableKeys
{
	NSNumber *vMul = @CDOptionsMultipleValues;
//	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = @CDOptionsNoValues;

	return @{@"allowed-files": vMul,
		@"select-directories": vNone,
		@"select-only-directories": vNone,
		@"no-select-directories": vNone,
		@"select-multiple": vNone,
		@"no-select-multiple": vNone};
}

- (void) createControl {
    savePanel = [NSOpenPanel openPanel];
	NSString *file = nil;
	NSString *dir = nil;
	
	[self setMisc];

    NSOpenPanel *openPanel = (NSOpenPanel *)savePanel;
    
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
    
    // Only check for dir or file path existance if debug is enabled.
    if ([options hasOpt:@"debug"]) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        // Directory
        if (dir != nil && ![fm fileExistsAtPath:dir]) {
            [self debug:[NSString stringWithFormat:@"Option --with-directory specifies a directory that does not exist: %@", dir]];
        }
        // File
        if (file != nil) {
            NSString *path = dir;
            if (path == nil) {
                path = [openPanel directory];
            }
            path = [path stringByAppendingString:@"/"];
            path = [path stringByAppendingString:file];
            if (![fm fileExistsAtPath:path]) {
                [self debug:[NSString stringWithFormat:@"Option --with-file specifies a file that does not exist: %@", path]];
            }
        }
    }
    
    [panel setPanel:openPanel];

	// resize window if user specified alternate width/height
    if ([panel needsResize]) {
		[openPanel setContentSize:[panel findNewSize]];
	}
	
    // Reposition Panel
    [panel setPosition];
    
    [self setTimeout];
    
    NSInteger result;
    
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber10_6) {
        result = [openPanel runModalForDirectory:dir file:file];
    }
    else {
        if (dir != nil) {
            if (file != nil) {
                dir = [dir stringByAppendingString:@"/"];
                dir = [dir stringByAppendingString:file];
            }
            NSURL * url = [[NSURL alloc] initFileURLWithPath:dir];
            [openPanel setDirectoryURL:url];
        }
        result = [openPanel runModal];
    }
    if (result == NSFileHandlingPanelOKButton) {
        controlExitStatus = -1;
        NSEnumerator *en = [[openPanel URLs] objectEnumerator];
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
    if (extensions != nil && [extensions count]) {
        NSString* extension = [filename pathExtension];
        extensionAllowed = [extensions containsObject:extension];
    }
    if ([options hasOpt:@"allowed-files"]) {
        NSArray *allowedFiles = [options optValues:@"allowed-files"];
        if (allowedFiles != nil && [allowedFiles count]) {
            if ([allowedFiles containsObject:[filename lastPathComponent]]) {
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
