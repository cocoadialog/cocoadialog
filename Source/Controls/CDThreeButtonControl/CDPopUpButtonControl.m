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

    return options;
}

- (BOOL) validateOptions {
    // Check that we're in the right sub-class.
    if (![self isMemberOfClass:[CDPopUpButtonControl class]] && ![self isMemberOfClass:[CDStandardPopUpButtonControl class]]) {
        [self fatalError:@"This control is not properly classed."];
    }

    // Check that at least button1 has been specified.
	if (![arguments getOption:@"button1"] && ![self isMemberOfClass:[CDStandardPopUpButtonControl class]])	{
        [self fatalError:@"You must specify the --button1 option."];
	}
    // Check that at least one item has been specified.
    if (![NSArray arrayWithArray:[arguments getOption:@"items"]].count) {
        [self fatalError:@"Must supply at least one item in the --items option."];
	}

    return [super validateOptions];
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
    popupControl.pullsDown = [arguments hasOption:@"pulldown"] ? YES : NO;
    // Populate menu
    NSArray *items = [NSArray arrayWithArray:[arguments getOption:@"items"]];
	if (items != nil && items.count) {
		NSEnumerator *en = [items objectEnumerator];
		id obj;
		while (obj = [en nextObject]) {
			[popupControl addItemWithTitle:(NSString *)obj];
		}
        NSInteger selected = [arguments hasOption:@"selected"] ? (long) [arguments getOption:@"selected"] : 0;
        [popupControl selectItemAtIndex:selected];
	}
	[self setTitleButtonsLabel:[arguments getOption:@"label"]];
}

- (void) controlHasFinished:(int)button {
	if ([self.arguments hasOption:@"string-output"]) {
        [controlReturnValues addObject:popupControl.titleOfSelectedItem];
	} else {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%ld", (long)popupControl.indexOfSelectedItem]];
	}
    [super controlHasFinished:button];
}

- (void) selectionChanged:(id)sender {
    [popupControl synchronizeTitleAndSelectedItem];
	if ([self.arguments hasOption:@"exit-onchange"]) {
		controlExitStatus = 4;
		controlExitStatusString = @"4";
        if ([self.arguments hasOption:@"string-output"]) {
            [controlReturnValues addObject:popupControl.titleOfSelectedItem];
        } else {
            [controlReturnValues addObject:[NSString stringWithFormat:@"%ld", (long)popupControl.indexOfSelectedItem]];
        }
        [self stopControl];
	}
}


@end
