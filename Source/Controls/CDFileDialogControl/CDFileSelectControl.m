// CDFileSelectControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

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
    [openPanel setAllowsMultipleSelection:option[@"select-multiple"].wasProvided];

	// Select directories.
    [openPanel setCanChooseDirectories:option[@"create-directories"].wasProvided || option[@"select-directories"].wasProvided];

    // Select only directories.
    if (option[@"select-only-directories"].wasProvided) {
		[openPanel setCanChooseDirectories:YES];
		[openPanel setCanChooseFiles:NO];
	}

    // Packages as directories.
    [openPanel setTreatsFilePackagesAsDirectories:option[@"packages-as-directories"].wasProvided];

	// set starting file (to be used later with 
	// runModal...) - doesn't work.
	if (option[@"with-file"].wasProvided) {
		file = option[@"with-file"].stringValue;
	}
	// set starting directory (to be used later with runModal...)
	if (option[@"with-directory"].wasProvided) {
		dir = option[@"with-directory"].stringValue;
	}
    
    // Check for dir or file path existance.
    NSFileManager *fm = [[NSFileManager alloc] init];
    // Directory
    if (dir != nil && ![fm fileExistsAtPath:dir]) {
        [self warning:@"Option --with-directory specifies a directory that does not exist: %@", dir, nil];
    }
    // File
    if (file != nil && ![fm fileExistsAtPath:file]) {
        [self warning:@"Option --with-file specifies a file that does not exist: %@", file, nil];
    }

    self.panel = openPanel;

	// resize window if user specified alternate width/height
    if ([self needsResize]) {
		[openPanel setContentSize:[self findNewSize]];
	}
	
    // Reposition Panel
    [self setPosition];
    
    [self setTimeout];
    
    NSInteger result;

    if (dir != nil) {
        if (file != nil) {
            dir = [dir stringByAppendingString:@"/"];
            dir = [dir stringByAppendingString:file];
        }
        NSURL * url = [[NSURL alloc] initFileURLWithPath:dir];
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
    if (option[@"allowed-files"].wasProvided) {
        NSArray *allowedFiles = option[@"allowed-files"].arrayValue;
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
