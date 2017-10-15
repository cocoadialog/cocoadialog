// CDFileSave.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDFileSave.h"

@implementation CDFileSave

- (void) createControl {
    [super createControl];

    self.savePanel.allowedFileTypes = nil;
    self.savePanel.nameFieldStringValue = self.file;
    if (self.directory && !self.directory.isBlank) {
        self.savePanel.directoryURL = [NSURL fileURLWithPath:self.directory];
    }

    self.panel = self.savePanel;

    [self createPanel];
    [self createTimeout];

    NSInteger result = [self.savePanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        self.returnValues[@"button"] = self.options[@"return-labels"] ? @"OKAY".localized : @0;
        self.returnValues[@"value"] = self.savePanel.URL.path;
    }
    else {
        self.exitStatus = CDTerminalExitCodeCancel;
        self.returnValues[@"button"] = self.options[@"return-labels"] ? @"CANCEL".localized : @1;
    }
    [super stopControl];
}

@end
