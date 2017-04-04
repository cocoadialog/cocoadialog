/*
	CDFileDialogControl.m
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

#import "CDFileDialogControl.h"

@implementation CDFileDialogControl

- (instancetype)init {
    self = [self initWithOptions:nil];
    extensions = [[[NSMutableArray alloc] init] retain];
    return self;
}

- (void) dealloc {
    [extensions release];
	[super dealloc];
}

- (NSMutableDictionary *)availableOptions {
    NSMutableDictionary *availableOptions = [super availableOptions];
    
    [availableOptions addEntriesFromDictionary:@{
                                     @"label": @CDOptionsOneValue,
                                     @"create-directories": @CDOptionsNoValues,
                                     @"packages-as-directories": @CDOptionsNoValues,
                                     @"with-extensions": @CDOptionsMultipleValues,
                                     @"with-directory": @CDOptionsOneValue,
                                     @"with-file": @CDOptionsOneValue,
                                     }];
    return availableOptions;
}

- (NSDictionary *) depreciatedKeys {
	return @{@"text": @"label"};
}

// Set options common to any file save panel
- (void) setMisc {
    savePanel.delegate = self;
    
    // Create directories.
    savePanel.canCreateDirectories = [options hasOpt:@"create-directories"];

    // Extensions.
    extensions = [[[NSMutableArray alloc] init] retain];
    NSArray *optionExtensions = [options optValues:@"with-extensions"];
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
	if ([options optValue:@"title"] != nil) {
		savePanel.title = [options optValue:@"title"];
	}
	// set message displayed on file select panel
	if ([options optValue:@"label"] != nil) {
		savePanel.message = [options optValue:@"label"];
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
    BOOL packageAsDir = [options hasOpt:@"packages‑as‑directories"];
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
