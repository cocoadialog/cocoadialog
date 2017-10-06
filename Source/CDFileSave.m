// CDFileSave.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDFileSave.h"

@implementation CDFileSave

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options add:[CDOptionBoolean       name:@"no-create-directories"]];

    return options;
}

- (void) initControl {
	savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:nil];
    
	NSString *file = @"";
	NSString *dir = nil;
	
	[self setMisc];

    [savePanel setTreatsFilePackagesAsDirectories:option[@"packages-as-directories"].wasProvided];

	if (option[@"no-create-directories"].wasProvided) {
		[savePanel setCanCreateDirectories:NO];
	}

	// Set starting file (to be used later with runModal...) - doesn't work.
	if (option[@"with-file"].wasProvided) {
		file = option[@"with-file"].stringValue;
	}
	// Set starting directory (to be used later with runModal...)
	if (option[@"with-directory"].wasProvided) {
		dir = option[@"with-directory"].stringValue;
	}
    
    // Check for dir or file path existance.
    NSFileManager *fm = [[NSFileManager alloc] init];
    if (dir != nil && ![fm fileExistsAtPath:dir]) {
        [self warning:@"Option --with-directory specifies a directory that does not exist: %@", dir, nil];
    }

    self.panel = savePanel;

    [self initPanel];
    [self initTimeout];
	
    NSInteger result;
    if (dir != nil) {
        NSURL * url = [[NSURL alloc] initFileURLWithPath:dir];
        savePanel.directoryURL = url;
    }
    savePanel.nameFieldStringValue = file;
    result = [savePanel runModal];

    if (result == NSFileHandlingPanelOKButton) {
        returnValues[@"button"] = option[@"return-labels"] ? NSLocalizedString(@"OKAY", nil) : @0;
        returnValues[@"value"] = savePanel.URL.path;
    }
    else {
        exitStatus = CDExitCodeCancel;
        returnValues[@"button"] = option[@"return-labels"] ? NSLocalizedString(@"CANCEL", nil) : @1;
    }
    [super stopControl];
}

@end
