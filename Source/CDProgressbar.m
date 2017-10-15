// CDProgressbar.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDProgressbar.h"

#import "CDProgressbarInputHandler.h"
#import "CDIcon.h"

@implementation CDProgressbar

+ (NSString *) scope {
    return @"progressbar";
}

+ (CDOptions *) availableOptions {
    CDOptions *options = super.availableOptions;

    // Remove normal buttons.
    [options remove:@"button1"];
    [options remove:@"button1"];
    [options remove:@"button1"];

    return options.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDString,   @"labels").max(2).deprecates(@[CDOption.create(CDString, @"text").toValueIndex(0)]),
    CDOption.create(CDNumber,   @"percent"),
    CDOption.create(CDBoolean,  @"indeterminate"),
    CDOption.create(CDBoolean,  @"stoppable"),
    ]);
}

- (void) createControl {
    [super createControl];

    self.progressbar = [[CDProgressbarView alloc] initWithDialog:self];

    // Set text label.
    self.labels = self.options[@"labels"].arrayValue ?: [NSArray array];

    // Set whether progressbar is stoppable.
    self.progressbar.stoppable = self.options[@"stoppable"].boolValue;

    CDProgressbarInputHandler *inputHandler = [[CDProgressbarInputHandler alloc] init];
    [inputHandler setDelegate:self];

    // Set initial percent.
    if (self.options[@"percent"].wasProvided) {
        double initialPercent;
        if ([inputHandler parseString:self.options[@"percent"].stringValue intoProgress:&initialPercent]) {
            self.progressbar.value = initialPercent;
        }
    }

    // set indeterminate
    self.progressbar.indeterminate = self.options[@"indeterminate"].boolValue;

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
        self.terminal.error(@"OPTION_PROGRESSBAR_CANCELED".localized, nil).exit(CDTerminalExitCodeCancel);
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
    [self.confirmationSheet setIcon:[CDIcon.sharedInstance iconFromName:@"caution"]];
    [self.confirmationSheet addButtonWithTitle:@"OPTION_PROGRESSBAR_STOP".localized];
    [self.confirmationSheet addButtonWithTitle:@"CANCEL".localized];
    self.confirmationSheet.messageText = @"PROGRESS_BAR_STOP_QUESTION".localized;
    [self.confirmationSheet beginSheetModalForWindow:self.panel completionHandler:^(NSModalResponse returnCode) {
        [self alertDidEnd:self.confirmationSheet returnCode:returnCode contextInfo:nil];
    }];
//    [self.confirmationSheet beginSheetModalForWindow:self.panel modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

@end
