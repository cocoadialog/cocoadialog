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

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
		vOne,   @"value",
        vNone,  @"selected",
		vNone,  @"no-show",
		nil];
}

- (NSDictionary *) depreciatedKeys
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
            @"value", @"text",
            @"label", @"informative-text",
            nil];
}

- (BOOL) validateOptions {    
    // Check that we're in the right sub-class
    if (![self isMemberOfClass:[CDInputboxControl class]]) {
        if (![self isMemberOfClass:[CDStandardInputboxControl class]]) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"This run-mode is not properly classed."];
            }
            return NO;
        }
    }
	// Check that at least button1 has been specified
	if (![options optValue:@"button1"] && ![self isMemberOfClass:[CDStandardInputboxControl class]])	{
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least --button1"];
		}
		return NO;
	}
    // Everything passed
    return YES;
}

- (BOOL)isReturnValueEmpty {
    NSString *value = [[controlMatrix cellAtRow:0 column:0] stringValue];
    return [value isEqualToString:@""];
}

- (NSString *) returnValueEmptyText
{
    return @"The text field can cannot be empty, please enter some text.";
}

- (void) createControl {
    NSString * labelText = @"";
    if ([options hasOpt:@"label"] && [options optValue:@"label"] != nil) {
        labelText = [options optValue:@"label"];
    }
	[self setTitleButtonsLabel:labelText];
}

- (void) controlHasFinished:(int)button {
    [controlReturnValues addObject:[[controlMatrix cellAtRow:0 column:0] stringValue]];
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {
    // Set other attributes of matrix
    [controlMatrix setCellSize:NSMakeSize([controlMatrix frame].size.width, 20.0f)];
    [controlMatrix renewRows:1 columns:1];
    [controlMatrix setAutosizesCells:NO];
    [controlMatrix setMode:NSRadioModeMatrix];
    [controlMatrix setAllowsEmptySelection:NO];
    
    id inputbox;
    if ([options hasOpt:@"no-show"]) {
        inputbox = [[[NSSecureTextField alloc] init] autorelease];
    }
    else {
        inputbox = [[[NSTextField alloc] init] autorelease];
    }
    [inputbox setRefusesFirstResponder:YES];
    // Set initial text in textfield
    if ([options optValue:@"value"]) {
        [inputbox setStringValue:[options optValue:@"value"]];
    }
    else {
        [inputbox setStringValue:@""];
    }
    [controlMatrix putCell:[inputbox cell] atRow:0 column:0];
    
    // select all the text
	if ([options hasOpt:@"selected"]) {
        [controlMatrix selectTextAtRow:0 column:0];
	}
    else {
        [controlMatrix deselectAllCells];
    }

}

@end
