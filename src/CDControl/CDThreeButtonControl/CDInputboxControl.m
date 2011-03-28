/*
	CDInputboxControl.m
	CocoaDialog
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


@implementation CDInputboxControl

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
		vOne, @"text",
		vOne, @"informative-text",
		vOne, @"button1",
		vOne, @"button2",
		vOne, @"button3",
		vNone,@"no-show",
		vNone,@"float",
		vOne, @"timeout",
		nil];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	NSString *returnString = nil;

	[self setOptions:options];

	// check that they specified at least a button1
	// return nil if not
	if (![options optValue:@"button1"] 
	    && [self isMemberOfClass:[CDInputboxControl class]]) 
	{
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Must supply at least a --button1"];
		}
		return nil;
	}	
	
	// Load Inputbox.nib or return nil
	NSString *nib = [options hasOpt:@"no-show"] ? @"SecureInputbox" : @"Inputbox";
	if (![NSBundle loadNibNamed:nib owner:self]) {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Could not load Inputbox.nib"];
		}
		return nil;
	}
	
	// Set initial text in textfield
	if ([options optValue:@"text"]) {
		[textField setStringValue:[options optValue:@"text"]];
	} else {
		[textField setStringValue:@""];
	}
	inputText = [[textField stringValue] retain];

	[self setTitleButtonsLabel:[options optValue:@"informative-text"]];

	// select all the text
	if ([options hasOpt:@"selected"]) {
		[textField selectText:self];
	}
	
	[self setTimeout];

	[self runAndSetRv];


	// set returnString
	if ([options hasOpt:@"string-output"]) {
		if (rv == 1) {
			returnString = [button1 title];
		} else if (rv == 2) {
			returnString = [button2 title];
		} else if (rv == 3) {
			returnString = [button3 title];
		} else if (rv == 0) {
			returnString = @"timeout";
		}
	} else {
		returnString = [NSString stringWithFormat:@"%d",rv];
	}
	return [NSArray arrayWithObjects:returnString, inputText, nil];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[inputText release];
	inputText = [[textField stringValue] retain];
}
- (void) dealloc
{
	[inputText release];
	[super dealloc];
}

@end
