// CDPopUpButtonControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDPopUpButtonControl.h"
#import "CDStandardPopUpButtonControl.h"


@implementation CDPopUpButtonControl

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
    return @"popup";
}

- (void) createControl {
    [self addMinWidth:popupControl.frame.size.width];
    [controlItems addObject:popupControl];
    [self iconAffectedByControl:popupControl];
    // Setup the control
    popupControl.keyEquivalent = @" ";
    popupControl.target = self;
    popupControl.action = @selector(selectionChanged:);
	[popupControl removeAllItems];
    // Set popup/pulldown style
    popupControl.pullsDown = option[@"pulldown"] ? YES : NO;
    // Populate menu
    NSArray *items = option[@"items"].arrayValue;
	if (items != nil && items.count) {
		NSEnumerator *en = [items objectEnumerator];
		id obj;
		while (obj = [en nextObject]) {
			[popupControl addItemWithTitle:(NSString *)obj];
		}
        NSUInteger selected = option[@"selected"].wasProvided ? option[@"selected"].unsignedIntegerValue : 0;
        [popupControl selectItemAtIndex:selected];
	}
	[self setTitleButtonsLabel:option[@"label"].stringValue];
}

- (void) controlHasFinished:(int)button {
	if (option[@"string-output"].wasProvided) {
        [controlReturnValues addObject:popupControl.titleOfSelectedItem];
	} else {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%ld", (long)popupControl.indexOfSelectedItem]];
	}
    [super controlHasFinished:button];
}

- (void) selectionChanged:(id)sender {
    [popupControl synchronizeTitleAndSelectedItem];
	if (option[@"exit-onchange"].wasProvided) {
		controlExitStatus = 4;
		controlExitStatusString = @"4";
        if (option[@"string-output"].wasProvided) {
            [controlReturnValues addObject:popupControl.titleOfSelectedItem];
        } else {
            [controlReturnValues addObject:[NSString stringWithFormat:@"%ld", (long)popupControl.indexOfSelectedItem]];
        }
        [self stopControl];
	}
}


@end
