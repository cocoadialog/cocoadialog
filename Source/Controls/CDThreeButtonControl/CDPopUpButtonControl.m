/*
	CDPopUpButtonControl.m
	cocoaDialog
	Copyright (C) 2004 Mark A. Stratman <mark@sporkstorms.org>
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.
 
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
 
	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

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

    // Required options.
    options[@"button1"].required = YES;
    options[@"items"].required = YES;

    return options;
}

- (BOOL) validateOptions {
    BOOL pass = [super validateOptions];

    // Check that at least one item has been specified.
    // @todo this really could be checked automatically now that options
    // are objects and could specify the number of minimum values.
    if (!arguments.options[@"items"].arrayValue.count) {
        [self error:@"Must supply at least one item in --items", nil];
        pass = NO;
    }

    return pass;
}

- (NSString *)controlNib {
    return @"popup";
}

- (void) createControl {
    [panel addMinWidth:popupControl.frame.size.width];
    [controlItems addObject:popupControl];
    [icon addControl:popupControl];
    // Setup the control
    popupControl.keyEquivalent = @" ";
    popupControl.target = self;
    popupControl.action = @selector(selectionChanged:);
	[popupControl removeAllItems];
    // Set popup/pulldown style
    popupControl.pullsDown = arguments.options[@"pulldown"] ? YES : NO;
    // Populate menu
    NSArray *items = arguments.options[@"items"].arrayValue;
	if (items != nil && items.count) {
		NSEnumerator *en = [items objectEnumerator];
		id obj;
		while (obj = [en nextObject]) {
			[popupControl addItemWithTitle:(NSString *)obj];
		}
        NSUInteger selected = arguments.options[@"selected"].wasProvided ? arguments.options[@"selected"].unsignedIntegerValue : 0;
        [popupControl selectItemAtIndex:selected];
	}
	[self setTitleButtonsLabel:arguments.options[@"label"].stringValue];
}

- (void) controlHasFinished:(int)button {
	if (arguments.options[@"string-output"].wasProvided) {
        [controlReturnValues addObject:popupControl.titleOfSelectedItem];
	} else {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%ld", (long)popupControl.indexOfSelectedItem]];
	}
    [super controlHasFinished:button];
}

- (void) selectionChanged:(id)sender {
    [popupControl synchronizeTitleAndSelectedItem];
	if (arguments.options[@"exit-onchange"].wasProvided) {
		controlExitStatus = 4;
		controlExitStatusString = @"4";
        if (arguments.options[@"string-output"].wasProvided) {
            [controlReturnValues addObject:popupControl.titleOfSelectedItem];
        } else {
            [controlReturnValues addObject:[NSString stringWithFormat:@"%ld", (long)popupControl.indexOfSelectedItem]];
        }
        [self stopControl];
	}
}


@end
