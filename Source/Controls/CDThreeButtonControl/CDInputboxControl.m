/*
	CDInputboxControl.m
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

#import "CDInputboxControl.h"
#import "CDStandardInputboxControl.h"



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
    if (arguments.options[@"label"].wasProvided) {
        labelText = arguments.options[@"label"].stringValue;
    }
	[self setTitleButtonsLabel:labelText];
}

- (void) controlHasFinished:(int)button {
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
    if (arguments.options[@"no-show"].wasProvided) {
        inputbox = [[[NSSecureTextField alloc] init] autorelease];
    }
    else {
        inputbox = [[[NSTextField alloc] init] autorelease];
    }
    [inputbox setRefusesFirstResponder:YES];
    // Set initial text in textfield
    if (arguments.options[@"value"].wasProvided) {
        [inputbox setStringValue:arguments.options[@"value"].stringValue];
    }
    else {
        [inputbox setStringValue:@""];
    }
    [controlMatrix putCell:[inputbox cell] atRow:0 column:0];
    
    // select all the text
	if (arguments.options[@"not-selected"].wasProvided) {
        [controlMatrix deselectAllCells];
	}
    else {
        [controlMatrix selectTextAtRow:0 column:0];
    }

}

@end
