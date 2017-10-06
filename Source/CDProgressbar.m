// CDProgressbar.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDProgressbar.h"

@implementation CDProgressbar

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    // Remove normal buttons.
    [options remove:@"button1"];
    [options remove:@"button1"];
    [options remove:@"button1"];

    // --labels
    [options add:[CDOptionMultipleStrings       name:@"labels"              category:@"PROGRESSBAR_OPTION"]];
    [options add:[CDOptionSingleString          name:@"text"                replacedBy:@"labels" valueIndex:0]];
    options[@"labels"].maximumValues = @2;

    // --indeterminate
    [options add:[CDOptionBoolean               name:@"indeterminate"       category:@"PROGRESSBAR_OPTION"]];

    // --percent
    [options add:[CDOptionSingleString          name:@"percent"             category:@"PROGRESSBAR_OPTION"]];

    // --second-label
    [options add:[CDOptionSingleString          name:@"second-label"        category:@"PROGRESSBAR_OPTION"]];

    // --stoppable
    [options add:[CDOptionBoolean               name:@"stoppable"           category:@"PROGRESSBAR_OPTION"]];

    return options;
}

- (void) initControl {
    [super initControl];

    self.progressbar = [[CDProgressbarView alloc] initWithDialog:self];

    // Set text label.
    self.labels = option[@"labels"].arrayValue ?: [NSArray array];

    // Set whether progressbar is stoppable.
    self.progressbar.stoppable = option[@"stoppable"].boolValue;

    CDProgressbarInputHandler *inputHandler = [[CDProgressbarInputHandler alloc] init];
    [inputHandler setDelegate:self];

    // Set initial percent.
    if (option[@"percent"].wasProvided) {
        double initialPercent;
        if ([inputHandler parseString:option[@"percent"].stringValue intoProgress:&initialPercent]) {
            self.progressbar.value = initialPercent;
        }
    }

    // set indeterminate
    self.progressbar.indeterminate = option[@"indeterminate"].boolValue;

    NSOperationQueue* queue = [NSOperationQueue new];
    [queue addOperation:inputHandler];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (self.confirmationSheet == alert) {
        self.confirmationSheet = nil;
    }
    if (returnCode == NSAlertFirstButtonReturn && self.progressbar.stoppable) {
        self.stopped = YES;
        [self progressFinished];
    }
}

- (void) progressFinished {
    if (self.confirmationSheet) {
        [NSApp endSheet:self.confirmationSheet.window];
        self.confirmationSheet = nil;
    }

    if (self.stopped) {
        [self fatal:CDExitCodeCancel error:NSLocalizedString(@"PROGRESS_BAR_CANCELED", nil), nil];
    }

    [self stopControl];
}

- (void) progressUpdate:(NSDictionary *)data {
    if (data[@"value"] != nil) {
        NSNumber *value = data[@"value"];
        self.progressbar.value = value.doubleValue;
    }
    if (data[@"labels"] != nil) {
        self.progressbar.labels = data[@"labels"];
    }
}

- (IBAction) stop:(id)sender {
    self.confirmationSheet = [[NSAlert alloc] init];
    [self.confirmationSheet setIcon:[self iconFromName:@"caution"]];
    [self.confirmationSheet addButtonWithTitle:NSLocalizedString(@"PROGRESS_BAR_STOP", nil)];
    [self.confirmationSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    self.confirmationSheet.messageText = NSLocalizedString(@"PROGRESS_BAR_STOP_QUESTION", nil);
    [self.confirmationSheet beginSheetModalForWindow:self.panel completionHandler:^(NSModalResponse returnCode) {
        [self alertDidEnd:self.confirmationSheet returnCode:returnCode contextInfo:nil];
    }];
//    [self.confirmationSheet beginSheetModalForWindow:self.panel modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

@end
