// CDTextbox.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDTextbox.h"

@implementation CDTextbox

+ (NSString *) scope {
    return @"textbox";
}

+ (CDOptions *) availableOptions {
    CDOptions* options = super.availableOptions;

    // Require at least one button.
    options[@"buttons"].require(YES).min(1);

    return options.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDBoolean,  @"editable").deprecates(@[CDOption.create(CDBoolean, @"no-editable")]),
    CDOption.create(CDString,   @"file").deprecates(@[CDOption.create(CDString, @"text-from-file")]),
    CDOption.create(CDBoolean,  @"focus").deprecates(@[CDOption.create(CDBoolean, @"focus-textbox")]),
    CDOption.create(CDString,   @"scroll-to").allow(@[@"bottom", @"top"]).setDefaultValue(@"top"),
    CDOption.create(CDBoolean,  @"selected"),
    CDOption.create(CDString,   @"value").deprecates(@[CDOption.create(CDString, @"text")]),
    ]);
}

- (void) createControl {
    [super createControl];
    
    self.textView = [[CDTextView alloc] initWithDialog:self];
	
	// Set first responder
	// Why doesn't this work for the button?
	if (self.options[@"focus"].wasProvided) {
		[self.panel makeFirstResponder:self.textView.textView];
	}
    else {
		[self.panel makeFirstResponder:self.button1];
	}
}

- (BOOL) isReturnValueEmpty {
    return [self.textView.textView.textStorage.string isEqualToString:@""];
}

- (NSString *) returnValueEmptyText {
    return @"The text box can cannot be empty, please enter some text.";
}

- (void) controlHasFinished:(NSUInteger)button {
	if (self.options[@"editable"].wasProvided && self.options[@"editable"].boolValue) {
        self.returnValues[@"value"] = self.textView.textView.textStorage.string;
	}
    [super controlHasFinished:button];
}


@end
