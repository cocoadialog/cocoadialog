// CDView.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDControlView.h"

@implementation CDControlView

+ (instancetype) initWithDialog:(CDDialog *)dialog {
    return [[super alloc] initWithDialog:dialog];
}

- (instancetype) initWithDialog:(CDDialog *)dialog {
    self = [super initWithFrame:NSMakeRect(0, 0, dialog.controlView.frame.size.width, dialog.controlView.frame.size.height)];
    if (self) {
        self.dialog = dialog;

        // Attempt to load a XIB for this view.
        if (![[NSBundle mainBundle] loadNibNamed:[self className] owner:self topLevelObjects:nil]) {
            dialog.terminal.error(@"Control view does not contain a XIB named: %@", [self className].doubleQuote.white.bold, nil).exit(CDTerminalExitCodeControlFailure);
        }

        if (self.contentView == nil) {
            dialog.terminal.error(@"The %@ control view has not properly bound the %@ property.", [self className].doubleQuote.white.bold, @"contentView".doubleQuote.white.bold, nil).exit(CDTerminalExitCodeControlFailure);
        }

        self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin | NSViewWidthSizable | NSViewHeightSizable;

        [self addSubview:self.contentView];
        self.contentView.frame = self.bounds;

        // Initialize the view.
        [self initView];

        // Add this view to the control view.
        [self.dialog.controlView addSubview:self];
    }
    return self;
}

- (void) initView {
}

@end
