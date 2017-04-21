// CDInputboxControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDInputboxControl.h"

@implementation CDInputboxControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag            name:@"not-selected"]];
    [options addOption:[CDOptionFlag            name:@"no-show"]];
    [options addOption:[CDOptionSingleString    name:@"value"]];

    // Deprecated options.
    [options addOption:[CDOptionDeprecated      from:@"text"                to:@"value"]];
    [options addOption:[CDOptionDeprecated      from:@"informative-text"    to:@"label"]];

    // Required options.
    options[@"button1"].required = YES;

    return options;
}

- (BOOL)isReturnValueEmpty {
    NSString *value = [controlMatrix cellAtRow:0 column:0].stringValue;
    return [value isEqualToString:@""];
}

- (NSString *) returnValueEmptyText {
    return @"The text field can cannot be empty, please enter some text.";
}

- (void) createControl {
    NSString * labelText = @"";
    if (option[@"label"].wasProvided) {
        labelText = option[@"label"].stringValue;
    }
	[self setTitleButtonsLabel:labelText];
}

- (void) controlHasFinished:(NSUInteger)button {
    [controlReturnValues addObject:[controlMatrix cellAtRow:0 column:0].stringValue];
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {
    // Set other attributes of matrix
    controlMatrix.cellSize = NSMakeSize(controlMatrix.frame.size.width, 20.0f);
    [controlMatrix renewRows:1 columns:1];
    [controlMatrix setAutosizesCells:NO];
    controlMatrix.mode = NSRadioModeMatrix;
    [controlMatrix setAllowsEmptySelection:NO];
    
    id inputbox;
    if (option[@"no-show"].wasProvided) {
        inputbox = [[NSSecureTextField alloc] init];
    }
    else {
        inputbox = [[NSTextField alloc] init];
    }
    [inputbox setRefusesFirstResponder:YES];
    // Set initial text in textfield
    if (option[@"value"].wasProvided) {
        [inputbox setStringValue:option[@"value"].stringValue];
    }
    else {
        [inputbox setStringValue:@""];
    }
    [controlMatrix putCell:[inputbox cell] atRow:0 column:0];
    
    // select all the text
	if (option[@"not-selected"].wasProvided) {
        [controlMatrix deselectAllCells];
	}
    else {
        [controlMatrix selectTextAtRow:0 column:0];
    }

}

@end
