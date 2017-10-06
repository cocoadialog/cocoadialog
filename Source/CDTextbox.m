// CDTextbox.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDTextbox.h"

@implementation CDTextbox

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    // --editable
    [options add:[CDOptionBoolean               name:@"editable"              category:@"TEXTBOX_OPTION"]];
    [options add:[CDOptionBoolean               name:@"no-editable"           replacedBy:@"editable"]];

    // --file
    [options add:[CDOptionSingleString          name:@"file"                  category:@"TEXTBOX_OPTION"]];
    [options add:[CDOptionSingleString          name:@"text-from-file"        replacedBy:@"file"]];

    // --focus
    [options add:[CDOptionBoolean               name:@"focus"                 category:@"TEXTBOX_OPTION"]];
    [options add:[CDOptionBoolean               name:@"focus-textbox"         replacedBy:@"focus"]];

    // --scroll-to
    [options add:[CDOptionSingleString          name:@"scroll-to"             category:@"TEXTBOX_OPTION"]];
    [options[@"scroll-to"].allowedValues addObjectsFromArray:@[@"bottom", @"top"]];
    options[@"scroll-to"].defaultValue = @"top";

    // --selected
    [options add:[CDOptionBoolean               name:@"selected"              category:@"TEXTBOX_OPTION"]];

    // --value
    [options add:[CDOptionSingleString          name:@"value"                 category:@"TEXTBOX_OPTION"]];
    [options add:[CDOptionSingleString          name:@"text"                  replacedBy:@"value"]];

    // Require at least one button.
    options[@"buttons"].required = YES;
    options[@"buttons"].minimumValues = @1;

    return options;
}

- (void) initControl {
    [super initControl];
    
    self.textView = [[CDTextView alloc] initWithDialog:self];
	
	// Set first responder
	// Why doesn't this work for the button?
	if (option[@"focus"].wasProvided) {
		[self.panel makeFirstResponder:self.textView.textView];
	} else {
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
	if (option[@"editable"].wasProvided && option[@"editable"].boolValue) {
        returnValues[@"value"] = self.textView.textView.textStorage.string;
	}
    [super controlHasFinished:button];
}


@end
