/*
	CDFileDialogControl.m
	CocoaDialog
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

- (id)init
{
    self = [self initWithOptions:nil];
    extensions = [[[NSMutableArray alloc] init] retain];
    return self;
}

- (void) dealloc
{
    [extensions release];
	[super dealloc];
}

// This must be overridden if you want local global options for your control
- (NSDictionary *) globalAvailableKeys {
    NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
    NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            // General
            vNone, @"help",
            vNone, @"debug",
            vNone, @"quiet",
            vOne,  @"title",
            vOne,  @"width",
            vOne,  @"height",
            vOne,  @"posX",
            vOne,  @"posY",
            vNone, @"minimize",
            vNone, @"resize",
            vOne,  @"icon",
            vOne,  @"icon-bundle",
            vOne,  @"icon-type",
            vOne,  @"icon-file",
            vOne,  @"icon-size",
            vOne,  @"icon-width",
            vOne,  @"icon-height",
            vNone, @"string-output",
            vNone, @"no-newline",
            // Open/Save
            vOne,  @"label",
            vNone, @"packages-as-directories",
            vMul,  @"with-extensions",
            vOne,  @"with-directory",
            vOne,  @"with-file",
            nil];
}

- (NSDictionary *) depreciatedKeys
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
            @"label", @"text",
            nil];
}

// Set options common to any file save panel
- (void) setMisc {
    [savePanel setDelegate:self];
    CDOptions *options = [self options];
    extensions = [[[NSMutableArray alloc] init] retain];
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
        NSLog(@"%@: %@", extension, [extensions containsObject:extension] ? @"YES" : @"NO");
        return [extensions containsObject:extension];
    }
    else {
        return YES;
    }
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename {
    CDOptions *options = [self options];
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
