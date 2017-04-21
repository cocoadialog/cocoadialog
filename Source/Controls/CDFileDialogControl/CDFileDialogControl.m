// CDFileDialogControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDFileDialogControl.h"

@implementation CDFileDialogControl

- (void) dealloc {
    [extensions release];
	[super dealloc];
}

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleString    name:@"label"]];
    [options addOption:[CDOptionFlag            name:@"create-directories"]];
    [options addOption:[CDOptionFlag            name:@"packages-as-directories"]];
    [options addOption:[CDOptionMultipleStrings name:@"with-extensions"]];
    [options addOption:[CDOptionSingleString    name:@"with-directory"]];
    [options addOption:[CDOptionSingleString    name:@"with-file"]];

    // Deprecated.
    [options addOption:[CDOptionDeprecated      from:@"text" to:@"label"]];

    return options;
}

// Set options common to any file save panel
- (void) setMisc {
    savePanel.delegate = self;
    
    // Create directories.
    savePanel.canCreateDirectories = option[@"create-directories"].boolValue;

    // Extensions.
    extensions = [NSMutableArray array];
    NSArray *optionExtensions = option[@"with-extensions"].arrayValue;
	if (optionExtensions != nil && optionExtensions.count) {
		NSString *extension;
		NSEnumerator *en = [optionExtensions objectEnumerator];
		while (extension = [en nextObject]) {
			if ([extension isEqualToString:@"."]) {
                extension = @"";
            }
            // Strip leading '.' from each extension
            else if (extension.length > 1 && [[extension substringWithRange:NSMakeRange(0,1)] isEqualToString:@"."]) {
				extension = [extension substringFromIndex:1];
			}
            [extensions addObject:extension];
        }
	}

	// Set title
	if (option[@"title"].wasProvided) {
		savePanel.title = option[@"title"].stringValue;
	}
	// set message displayed on file select panel
	if (option[@"label"].wasProvided) {
		savePanel.message = option[@"label"].stringValue;
	}
}

- (BOOL)isExtensionAllowed:(NSString *)filename {
    if (extensions != nil && extensions.count) {
        NSString* extension = filename.pathExtension;
        return [extensions containsObject:extension];
    }
    else {
        return YES;
    }
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename {
    BOOL packageAsDir = option[@"packages‑as‑directories"].boolValue;
    BOOL isPackage = [[NSWorkspace sharedWorkspace] isFilePackageAtPath:filename];
    BOOL isDir;
    // Allow directories and/or packages to be selectable
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDir] && isDir) {
        // Filename is package
        if (isPackage) {
            // Navigate packages
            if (packageAsDir) {
                return YES;
            }
            // Packages are not navigable, run through extension logic
            else {
                return [self isExtensionAllowed:filename];
            }
        }
        else {
            return YES;
        }
    }
    // Run through extension logic
    else {
        return [self isExtensionAllowed:filename];
    }
}


@end
