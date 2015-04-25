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
    extensions = [[NSMutableArray alloc] init];
    return self;
}


// This must be overridden if you want local global options for your control
- (NSDictionary *) globalAvailableKeys {
    NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
    NSNumber *vMul = @CDOptionsMultipleValues;
    return @{@"help": vNone,
            @"debug": vNone,
            @"quiet": vNone,
            @"timeout": vOne,
            @"timeout-format": vOne,
            @"string-output": vNone,
            @"no-newline": vNone,
            // Panel
            @"title": vOne,
            @"width": vOne,
            @"height": vOne,
            @"posX": vOne,
            @"posY": vOne,
            @"no-float": vNone,
            @"minimize": vNone,
            @"resize": vNone,
            // Icon
            @"icon": vOne,
            @"icon-bundle": vOne,
            @"icon-type": vOne,
            @"icon-file": vOne,
            @"icon-size": vOne,
            @"icon-width": vOne,
            @"icon-height": vOne,

            // CDFileDialogs
            @"label": vOne,
            @"packages-as-directories": vNone,
            @"with-extensions": vMul,
            @"with-directory": vOne,
            @"with-file": vOne};
}

- (NSDictionary *) depreciatedKeys {
	return @{@"text": @"label"};
}

// Set options common to any file save panel
- (void) setMisc {
    [savePanel setDelegate:self];
    extensions = [[NSMutableArray alloc] init];
    NSArray *optionExtensions = [options optValues:@"with-extensions"];
	if (optionExtensions != nil && [optionExtensions count]) {
		NSString *extension;
		NSEnumerator *en = [optionExtensions objectEnumerator];
		while (extension = [en nextObject]) {
			if ([extension isEqualToString:@"."]) {
                extension = @"";
            }
            // Strip leading '.' from each extension
            else if ([extension length] > 1 && [[extension substringWithRange:NSMakeRange(0,1)] isEqualToString:@"."]) {
				extension = [extension substringFromIndex:1];
			}
            [extensions addObject:extension];
        }
	}

	// Set title
	if ([options optValue:@"title"] != nil) {
		[savePanel setTitle:[options optValue:@"title"]];
	}
	// set message displayed on file select panel
	if ([options optValue:@"label"] != nil) {
		[savePanel setMessage:[options optValue:@"label"]];
	}
}

- (BOOL)isExtensionAllowed:(NSString *)filename {
    if (extensions != nil && [extensions count]) {
        NSString* extension = [filename pathExtension];
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
