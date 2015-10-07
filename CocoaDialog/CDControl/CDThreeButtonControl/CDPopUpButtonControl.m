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

#import "CDThreeButtonControl.h"

@implementation CDPopUpButtonControl

- (NSDictionary*) availableKeys
{
    NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
	NSNumber *vMul = @CDOptionsMultipleValues;

	return @{@"items": vMul,
        @"selected": vOne,
		@"exit-onchange": vNone,
		@"pulldown": vNone};
}

- (NSDictionary*) depreciatedKeys
{
	return @{@"text": @"label"};
}

- (BOOL) validateOptions {
    // Check that we're in the right sub-class
    if (![self isMemberOfClass:[CDPopUpButtonControl class]]) {
        if (![self isMemberOfClass:[CDStandardPopUpButtonControl class]]) {
            if ([self.options hasOpt:@"debug"]) {
                [self debug:@"This run-mode is not properly classed."];
            }
            return NO;
        }
    }
	// Check that at least button1 has been specified
	if (![self.options optValue:@"button1"] && ![self isMemberOfClass:[CDStandardPopUpButtonControl class]])	{
		if ([self.options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least --button1"];
		}
		return NO;
	}
    // Check that at least one item has been specified
    NSArray *items = [NSArray arrayWithArray:[self.options optValues:@"items"]];
    if (![items count]) { 
		if ([self.options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least one --items"];
		}
		return NO;
	}
    // Load nib
	if (![NSBundle loadNibNamed:@"popup" owner:self]) {
		if ([self.options hasOpt:@"debug"]) {
			[self debug:@"Could not load popup.nib"];
		}
		return NO;
	}
    // Everything passed
    return YES;
}

- (NSString*) controlNib {
    return @"popup";
}

- (void) createControl {
    [self.panel addMinWidth:self.popupControl.frame.size.width];
    [controlItems addObject:self.popupControl];
    [self.icon addControl:self.popupControl];
    // Setup the control
    [self.popupControl setKeyEquivalent:@" "];
    [self.popupControl setTarget:self];
    [self.popupControl setAction:@selector(selectionChanged:)];
	[self.popupControl removeAllItems];
    // Set popup/pulldown style
    [self.popupControl setPullsDown:[self.options hasOpt:@"pulldown"] ? YES : NO];
    // Populate menu
    NSArray *items = [NSArray arrayWithArray:[self.options optValues:@"items"]];
	if (items != nil && [items count]) {
		NSEnumerator *en = [items objectEnumerator];
		id obj;
		while (obj = [en nextObject]) {
			[self.popupControl addItemWithTitle:(NSString *)obj];
		}
        NSInteger selected = [self.options hasOpt:@"selected"] ? [[self.options optValue:@"selected"] integerValue] : 0;
        [self.popupControl selectItemAtIndex:selected];
	}
	[self setTitleButtonsLabel:[self.options optValue:@"label"]];
}

- (void) controlHasFinished:(int)button {
	if ([[self options] hasOpt:@"string-output"]) {
        [controlReturnValues addObject:self.popupControl.titleOfSelectedItem];
	} else {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%d", self.popupControl.indexOfSelectedItem]];
	}
    [super controlHasFinished:button];
}

- (void) selectionChanged:(id)sender {
    [self.popupControl synchronizeTitleAndSelectedItem];
	if ([[self options] hasOpt:@"exit-onchange"]) {
		controlExitStatus = 4;
		controlExitStatusString = @"4";
        if ([[self options] hasOpt:@"string-output"]) {
            [controlReturnValues addObject:self.popupControl.titleOfSelectedItem];
        } else {
            [controlReturnValues addObject:[NSString stringWithFormat:@"%d", self.popupControl.indexOfSelectedItem]];
        }
        [self stopControl];
	}
}


@end
