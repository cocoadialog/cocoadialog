// CDInputbox.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDInputbox.h"

@implementation CDInputbox

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    // --secure
    [options add:[CDOptionBoolean           name:@"secure"              category:@"INPUT_OPTION"]];
    [options add:[CDOptionBoolean           name:@"no-show"             replacedBy:@"secure"]];

    // --selected
    [options add:[CDOptionBoolean           name:@"selected"            category:@"INPUT_OPTION"]];
    [options add:[CDOptionBoolean           name:@"not-selected"        replacedBy:@"selected"]];

    // --value
    [options add:[CDOptionSingleString      name:@"value"               category:@"INPUT_OPTION"]];
    [options add:[CDOptionSingleString      name:@"text"                replacedBy:@"value"]];

    // Required options.
    options[@"buttons"].required = YES;
    options[@"buttons"].minimumValues = @1;

    return options;
}

- (BOOL)isReturnValueEmpty {
    return self.input.stringValue.isBlank;
}

- (NSString *) returnValueEmptyText {
    return @"The text field can cannot be empty, please enter some text.";
}

- (void) controlHasFinished:(NSUInteger)button {
    returnValues[@"value"] = self.input.stringValue;
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {
    if (option[@"secure"].boolValue) {
        self.input = [[NSSecureTextField alloc] init];
    }
    else {
        self.input = [[NSTextField alloc] init];
    }

    self.input.refusesFirstResponder = YES;

    // Set initial text in textfield.
    [self.input setStringValue:option[@"value"].stringValue];

    // Select all the text.
	if (option[@"selected"].wasProvided || option[@"selected"].boolValue) {
        [self.input selectAll:nil];
	}

    // Add the control to the view.
    [self.controlView addSubview:self.input];
}

@end
