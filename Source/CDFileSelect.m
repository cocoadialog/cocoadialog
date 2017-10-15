// CDFileSelect.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDFileSelect.h"

@implementation CDFileSelect

+ (CDOptions *) availableOptions {
    return super.availableOptions.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDString,   @"allowed-files").max(-1),
    CDOption.create(CDBoolean,  @"select-directories").deprecates(@[CDOption.create(CDBoolean, @"no-select-directories")]),
    CDOption.create(CDBoolean,  @"select-only-directories"),
    CDOption.create(CDBoolean,  @"select-multiple").deprecates(@[CDOption.create(CDBoolean, @"no-select-multiple")]),
    ]);
}

- (void) createSavePanel {
    self.savePanel = [NSOpenPanel openPanel];
}

- (void) createControl {
    [self createControl];

    // Check file existance.
    if (self.file && !self.file.isBlank && ![self.fileManager fileExistsAtPath:self.file]) {
        self.terminal.warning(@"The %@ option specified a file that does not exist: %@", @"file".optionFormat, self.file, nil);
    }

    NSOpenPanel *openPanel = (NSOpenPanel *) self.savePanel;
    openPanel.allowsMultipleSelection = self.options[@"select-multiple"].boolValue;
    openPanel.canChooseDirectories = self.options[@"create-directories"].boolValue || self.options[@"select-directories"].boolValue;

    // Select only directories.
    if (self.options[@"select-only-directories"].boolValue) {
        openPanel.canChooseDirectories = YES;
        openPanel.canChooseFiles = NO;
	}

    self.panel = openPanel;

    [self createPanel];
    [self createTimeout];
    
    if (self.directory && !self.directory.isBlank) {
        if (self.file && !self.file.isBlank) {
            self.directory = [self.directory stringByAppendingString:@"/"];
            self.directory = [self.directory stringByAppendingString:self.file];
        }
        openPanel.directoryURL = [NSURL fileURLWithPath:self.directory];
    }

    NSInteger result = [openPanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        NSMutableArray *files = @[].mutableCopy;
        NSEnumerator *en = [openPanel.URLs objectEnumerator];
        NSURL *url;
        while (url = [en nextObject]) {
            [files addObject:[url path]];
        }
        self.returnValues[@"button"] = self.options[@"return-labels"] ? @"OKAY".localized : @0;
        self.returnValues[@"value"] = files;
    }
    else {
        self.exitStatus = CDTerminalExitCodeCancel;
        self.returnValues[@"button"] = self.options[@"return-labels"] ? @"CANCEL".localized : @1;
    }
    [super stopControl];
}

- (BOOL)isExtensionAllowed:(NSString *)filename {
    BOOL extensionAllowed = YES;
    if (self.extensions && self.extensions.count) {
        NSString* extension = filename.pathExtension;
        extensionAllowed = [self.extensions containsObject:extension];
    }
    if (self.options[@"allowed-files"].wasProvided) {
        NSArray *allowedFiles = self.options[@"allowed-files"].arrayValue;
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
