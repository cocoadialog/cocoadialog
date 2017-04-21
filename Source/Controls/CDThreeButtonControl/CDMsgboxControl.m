// CDMsgboxControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDMsgboxControl.h"

@implementation CDMsgboxControl

@synthesize text;

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleString    name:@"alert"]];

    // Deprecated options.
    [options addOption:[CDOptionDeprecated      from:@"text"                to:@"alert"]];
    [options addOption:[CDOptionDeprecated      from:@"informative-text"    to:@"label"]];

    return options;
}

- (NSString *)controlNib {
    return @"Msgbox";
}

- (void) createControl {
    NSRect expandingLabelRect = expandingLabel.frame;
    
    float alertNewHeight = -4.0f;
    NSRect alertRect = text.frame;
    float alertHeightDiff = alertNewHeight - alertRect.size.height;
    if (option[@"alert"].wasProvided) {
        [self iconAffectedByControl:text];
        text.stringValue = option[@"alert"].stringValue;
    }
    else {
        expandingLabelRect.origin.y -= alertHeightDiff;
        expandingLabel.frame = expandingLabelRect;
        [text setHidden:YES];
    }

    // Set panel's new width and height
    NSSize p = self.panel.contentView.frame.size;
    p.height += alertHeightDiff;
    [self.panel setContentSize:p];

	[self setTitleButtonsLabel:option[@"label"].stringValue];
}

@end
