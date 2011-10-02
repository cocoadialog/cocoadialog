/*
	CDPopUpButtonControl.m
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

#import "CDPopUpButtonControl.h"
#import "CDStandardPopUpButtonControl.h"


@implementation CDPopUpButtonControl

- (NSDictionary *) availableKeys
{
    NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];

	return [NSDictionary dictionaryWithObjectsAndKeys:
		vMul,   @"items",
        vOne,   @"selected",
		vNone,  @"exit-onchange",
		vNone,  @"pulldown",
		nil];
}

- (NSDictionary *) depreciatedKeys
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
            @"label", @"text",
            nil];
}

- (BOOL) validateControl:(CDOptions *)options
{
    // Check that we're in the right sub-class
    if (![self isMemberOfClass:[CDPopUpButtonControl class]]) {
        if (![self isMemberOfClass:[CDStandardPopUpButtonControl class]]) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"This run-mode is not properly classed."];
            }
            return NO;
        }
    }
	// Check that at least button1 has been specified
	if (![options optValue:@"button1"])	{
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least --button1"];
		}
		return NO;
	}
    // Check that at least one item has been specified
    NSArray *items = [[[NSArray alloc] init] autorelease];
	items = [options optValues:@"items"];
    if (![items count]) { 
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least one --items"];
		}
		return NO;
	}
    // Load nib
	if (![NSBundle loadNibNamed:@"tbc" owner:self]) {
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Could not load tbc.nib"];
		}
		return NO;
	}
    // Everything passed
    return YES;
}


- (NSArray *) runControlFromOptions:(CDOptions *)options
{
    // Validate control before continuing
	if (![self validateControl:options]) {
        return nil;
    }
    
    NSString * labelText = @"";
    if ([options hasOpt:@"label"] && [options optValue:@"label"] != nil) {
        labelText = [options optValue:@"label"];
    }
    
	[self setTitleButtonsLabel:labelText];
	[self setTimeout];
	[self runAndSetRv];

    NSString *buttonRv = nil;
	NSString *itemRv   = nil;

	// set return values 
	if ([options hasOpt:@"string-output"]) {
		if (rv == 1) {
			buttonRv = [button1 title];
		} else if (rv == 2) {
			buttonRv = [button2 title];
		} else if (rv == 3) {
			buttonRv = [button3 title];
		} else if (rv == 4) {
			buttonRv = @"4";
		} else if (rv == 0) {
			buttonRv = @"timeout";
		}
		itemRv = [[controlMatrix cellAtRow:0 column:0] titleOfSelectedItem];
	} else {
		buttonRv = [NSString stringWithFormat:@"%d",rv];
		itemRv   = [NSString stringWithFormat:@"%d", [[controlMatrix cellAtRow:0 column:0] indexOfSelectedItem]];
	}
	return [NSArray arrayWithObjects:buttonRv, itemRv, nil];
}

- (void) setControl:(id)sender
{
    CDOptions *options = [self options];
    
    // Setup control matrix
    [controlMatrix setAutosizesCells:NO];
    [controlMatrix renewRows:1 columns:1];
    [controlMatrix setCellSize:NSMakeSize([controlMatrix frame].size.width, 22.0f)];
    [controlMatrix setMode:NSHighlightModeMatrix];
    // Setup the control
    NSPopUpButton *popup = [[[NSPopUpButton alloc] init] autorelease];
    [popup setTarget:self];
    [popup setAction:@selector(selectionChanged:)];
	[popup removeAllItems];
    // Set popup/pulldown style
    [popup setPullsDown:[options hasOpt:@"pulldown"] ? YES : NO];
    // Populate menu
    NSArray *items = [[[NSArray alloc] init] autorelease];
	items = [options optValues:@"items"];
	if (items != nil && [items count]) {
		NSEnumerator *en = [items objectEnumerator];
		id obj;
		while (obj = [en nextObject]) {
			[popup addItemWithTitle:(NSString *)obj];
		}
	}
    NSInteger selected = [options hasOpt:@"selected"] ? [[options optValue:@"selected"] integerValue] : 0;
	[popup selectItemAtIndex:selected];
    // Add control to matrix
    [controlMatrix putCell:[popup cell] atRow:0 column:0];
}
     
- (void) selectionChanged:(id)sender
{
    NSPopUpButtonCell * popup = [controlMatrix cellAtRow:0 column:0];
    [popup synchronizeTitleAndSelectedItem];
	if ([[self options] hasOpt:@"exit-onchange"]) {
		rv = 4;
		[NSApp stop:nil];
		return;
	}
}

- (void) dealloc
{
	[super dealloc];
}

@end
