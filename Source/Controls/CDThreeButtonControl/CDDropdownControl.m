// CDDropdownControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDDropdownControl.h"

@implementation CDDropdownControl

@synthesize dropdownControl;

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag                name:@"exit-onchange"]];
    [options addOption:[CDOptionMultipleStrings     name:@"items"]];
    [options addOption:[CDOptionFlag                name:@"pulldown"]];
    [options addOption:[CDOptionSingleNumber        name:@"selected"]];

    // Deprecated options.
    [options addOption:[CDOptionDeprecated          from:@"text" to:@"label"]];

    // Minimum values.
    options[@"items"].minimumValues = @2;

    // Required options.
    [options[@"button1"] addConditionalRequirement:^BOOL{
        return !option[@"pulldown"].wasProvided;
    }];
    options[@"items"].required = YES;

    return options;
}

- (NSString *)controlNib {
    return @"Dropdown";
}

- (void) createControl {
    [self addMinWidth:dropdownControl.frame.size.width];
    [controlItems addObject:dropdownControl];
    [self iconAffectedByControl:dropdownControl];
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
	[self setTitleButtonsLabel:option[@"label"].stringValue];
}

- (void) controlHasFinished:(NSUInteger)button {
	if (option[@"string-output"].wasProvided) {
        [returnValues addObject:dropdownControl.titleOfSelectedItem];
	} else {
        [returnValues addObject:[NSString stringWithFormat:@"%ld", (long)dropdownControl.indexOfSelectedItem]];
	}
    [super controlHasFinished:button];
}

- (void) selectionChanged:(id)sender {
    [dropdownControl synchronizeTitleAndSelectedItem];
	if (option[@"exit-onchange"].wasProvided) {
        if (option[@"string-output"].wasProvided) {
            [returnValues addObject:dropdownControl.titleOfSelectedItem];
        } else {
            [returnValues addObject:[NSString stringWithFormat:@"%ld", (long)dropdownControl.indexOfSelectedItem]];
        }
        [self stopControl];
	}
}


@end
