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

#import "CDFileDialogControl.h"

@implementation CDFileSaveControl

- (NSDictionary*) availableKeys
{
//	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
//	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = @CDOptionsNoValues;

	return @{@"no-create-directories": vNone};
}

- (void) createControl {
	savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:nil];
    
	NSString *file = @"";
	NSString *dir = nil;
	
//  [self setOptions:options];
	[self setMisc];

	if ([self.options hasOpt:@"packages-as-directories"]) {
		[savePanel setTreatsFilePackagesAsDirectories:YES];
	} else {
		[savePanel setTreatsFilePackagesAsDirectories:NO];
	}

	if ([self.options hasOpt:@"no-create-directories"]) {
		[savePanel setCanCreateDirectories:NO];
	} else {
		[savePanel setCanCreateDirectories:YES];
	}

	// set starting file (to be used later with 
	// runModal...) - doesn't work.
	if ([self.options optValue:@"with-file"] != nil) {
		file = [self.options optValue:@"with-file"];
	}
	// set starting directory (to be used later with runModal...)
	if ([self.options optValue:@"with-directory"] != nil) {
		dir = [self.options optValue:@"with-directory"];
	}
    
    // Only check for dir or file path existance if debug is enabled.
    if ([self.options hasOpt:@"debug"]) {
        NSFileManager *fm = NSFileManager.new;
        // Directory
        if (dir != nil && ![fm fileExistsAtPath:dir]) {
            [self debug:[NSString stringWithFormat:@"Option --with-directory specifies a directory that does not exist: %@", dir]];
        }
    }
    
    [self.panel setPanel:savePanel];

	// resize window if user specified alternate width/height
    if ([self.panel needsResize]) {
		[savePanel setContentSize:[self.panel findNewSize]];
	}
	
    // Reposition Panel
    [self.panel setPosition];
    
    [self setTimeout];
	
    NSInteger result;
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber10_6) {
        result = [savePanel runModalForDirectory:dir file:file];
    }
    else {
        if (dir) [savePanel setDirectoryURL:[NSURL.alloc initFileURLWithPath:dir]];
        [savePanel setNameFieldStringValue:file];
        result = [savePanel runModal];
    }
    if (result == NSFileHandlingPanelOKButton) {
        [self setValue:@(-1) forKey:@"controlExitStatus"];
        [self.controlReturnValues addObject:savePanel.filename];
    }
    else {
        [self setValue:@(-2) forKey:@"controlExitStatus"];
        [self.controlReturnValues removeAllObjects];
    }
    [super stopControl];
}

@end
