// CDDropdown.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDDropdown.h"

@implementation CDDropdown

@synthesize dropdownControl;

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    // --label
    [options add:[CDOptionSingleString        name:@"label"             category:@"DROPDOWN_OPTION"]];
    [options add:[CDOptionSingleString        name:@"text"              replacedBy:@"label"]];

    // --exit-onchange
    [options add:[CDOptionBoolean             name:@"exit-onchange"     category:@"DROPDOWN_OPTION"]];

    // --items
    [options add:[CDOptionMultipleStrings     name:@"items"             category:@"DROPDOWN_OPTION"]];
    options[@"items"].minimumValues = @2;
    options[@"items"].required = YES;

    // --pulldown
    [options add:[CDOptionBoolean             name:@"pulldown"          category:@"DROPDOWN_OPTION"]];

    // --selected
    [options add:[CDOptionSingleNumber        name:@"selected"          category:@"DROPDOWN_OPTION"]];

    // Required options.
    [options[@"buttons"] addConditionalRequirement:^BOOL{
        return !option[@"pulldown"].wasProvided;
    }];

    return options;
}

- (void) initControl {
    // Setup the control
    dropdownControl.keyEquivalent = @" ";
    dropdownControl.target = self;
    dropdownControl.action = @selector(selectionChanged:);
	[dropdownControl removeAllItems];

    // Set pulldown style.
    dropdownControl.pullsDown = option[@"pulldown"].wasProvided;

    // Populate menu
    NSArray *items = option[@"items"].arrayValue;
	if (items != nil && items.count) {
		NSEnumerator *en = [items objectEnumerator];
		id obj;
		while (obj = [en nextObject]) {
			[dropdownControl addItemWithTitle:(NSString *)obj];
		}
        NSUInteger selected = option[@"selected"].wasProvided ? option[@"selected"].unsignedIntegerValue : 0;
        [dropdownControl selectItemAtIndex:selected];
	}
}

- (void) controlHasFinished:(NSUInteger)button {
	if (option[@"return-labels"].wasProvided) {
        returnValues[@"value"] = dropdownControl.titleOfSelectedItem;
	} else {
        returnValues[@"value"] = [NSNumber numberWithInteger:dropdownControl.indexOfSelectedItem];
	}
    [super controlHasFinished:button];
}

- (void) selectionChanged:(id)sender {
    [dropdownControl synchronizeTitleAndSelectedItem];
	if (option[@"exit-onchange"].wasProvided) {
        if (option[@"return-labels"].wasProvided) {
            returnValues[@"value"] = dropdownControl.titleOfSelectedItem;
        } else {
            returnValues[@"value"] = [NSNumber numberWithInteger:dropdownControl.indexOfSelectedItem];
        }
        [self stopControl];
	}
}


@end
