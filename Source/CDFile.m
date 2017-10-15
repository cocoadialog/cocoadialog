// CDFile.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDFile.h"

@implementation CDFile

+ (NSString *) scope {
    return @"file";
}

+ (CDOptions *) availableOptions {
    return super.availableOptions.addOptionsToScope([self class].scope,
  @[

    CDOption.create(CDString,   @"label").deprecates(@[CDOption.create(CDString, @"text")]),
    CDOption.create(CDBoolean,  @"create-directories").deprecates(@[CDOption.create(CDBoolean, @"no-create-directories")]),
    CDOption.create(CDBoolean,  @"packages-as-directories"),
    CDOption.create(CDString,   @"extensions").max(-1).deprecates(@[CDOption.create(CDString, @"with-extensions").max(-1)]).process((CDOptionProcessBlock) ^NSArray* (NSArray *values) {
        if (!values.count) {
            return values;
        }
        NSMutableArray* newValues = @[].mutableCopy;
        for (NSString* extension in values) {
            if ([extension isEqualToString:@"."] || [extension isEqualToString:@"*"]) {
                [newValues addObject:@""];
            }
            // Strip leading '.' from each extension
            else if (extension.length > 1 && [[extension substringWithRange:NSMakeRange(0,1)] isEqualToString:@"."]) {
                [newValues addObject:[extension substringFromIndex:1]];
            }
        }
        return newValues;
    }),
    CDOption.create(CDString,   @"directory").deprecates(@[CDOption.create(CDString, @"with-directory")]),
    CDOption.create(CDString,   @"file").deprecates(@[CDOption.create(CDString, @"with-file")]),
    ]);
}

- (void) createSavePanel {
    self.savePanel = [NSSavePanel savePanel];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _fileManager = [[NSFileManager alloc] init];
    }
    return self;
}

// Set options common to any file save panel
- (void) createControl {
    [super createControl];

    // Options.
    self.directory = self.options[@"directory"].stringValue;
    self.extensions = self.options[@"extensions"].arrayValue;
    self.file = self.options[@"file"].stringValue ?: @"";

    // Create save panel.
    [self createSavePanel];

    // Save panel properties.
    self.savePanel.delegate = self;
    self.savePanel.canCreateDirectories = self.options[@"create-directories"].boolValue;
    self.savePanel.treatsFilePackagesAsDirectories = self.options[@"packages-as-directories"].boolValue;
    self.savePanel.title = self.options[@"title"].stringValue;
    self.savePanel.message = self.options[@"label"].stringValue;

    // Check directory existance.
    if (self.directory && !self.directory.isBlank && ![self.fileManager fileExistsAtPath:self.directory]) {
        self.terminal.warning(@"The %@ option specified a directory that does not exist: %@", @"directory".optionFormat, self.directory, nil);
    }
}

- (BOOL)isExtensionAllowed:(NSString *)filename {
    if (self.extensions != nil && self.extensions.count) {
        NSString* extension = filename.pathExtension;
        return [self.extensions containsObject:extension];
    }
    else {
        return YES;
    }
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename {
    BOOL packageAsDir = self.options[@"packages‑as‑directories"].boolValue;
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
