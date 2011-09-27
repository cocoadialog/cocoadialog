//
//  CDCheckboxControl.m
//  CocoaDialog
//
//  Created by Mark Carver on 9/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDCheckboxControl.h"

@implementation CDCheckboxControl

- (NSDictionary *) availableKeys
{
//	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    
	return [NSDictionary dictionaryWithObjectsAndKeys:
            vOne, @"text",
            vOne, @"rows",
            vOne, @"columns",
            vMul, @"items",
            vMul, @"checked",
            vMul, @"mixed",
            vMul, @"disabled",
            nil];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	NSString *buttonRv = nil;
	NSString *itemRv   = nil;
    
	[self setOptions:options];
    
	// check that they specified at least a button1
	// return nil if not
	if (![options optValue:@"button1"] 
	    && [self isMemberOfClass:[CDCheckboxControl class]]) 
	{
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Must supply at least a --button1"];
		}
		return nil;
	}
    
	// Load tbc.xib or return nil
	if (![NSBundle loadNibNamed:@"tbc" owner:self]) {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Could not load tbc.xib"];
		}
		return nil;
	}
    
    NSArray *items = [[[NSArray alloc] init] autorelease];
	items = [options optValues:@"items"];
    if (![items count]) { 
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Must supply at least one --items"];
		}
		return nil;
	}
    
	[self setTitleButtonsLabel:[options optValue:@"text"]];
	
	[self setTimeout];
    
	[self runAndSetRv];
    
	// set return values 
    NSArray * checkboxes = [controlMatrix cells];
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
        if (checkboxes != nil && [checkboxes count]) {
            NSMutableArray *itemRvArray = [[[NSMutableArray alloc] init] autorelease];
            NSEnumerator *en = [checkboxes objectEnumerator];
            id obj;
            int state;
            while (obj = [en nextObject]) {
                if ([[obj className] isEqualToString:@"NSButtonCell"]) {
                    state = [obj state];
                    switch (state) {
                        case NSOffState: [itemRvArray addObject: @"off"]; break;
                        case NSOnState: [itemRvArray addObject: @"on"]; break;
                        case NSMixedState: [itemRvArray addObject: @"mixed"]; break;
                    }
                }
            }
            itemRv = [itemRvArray componentsJoinedByString:@" "];
        }
	} else {
		buttonRv = [NSString stringWithFormat:@"%d",rv];
        if (checkboxes != nil && [checkboxes count]) {
            NSMutableArray *itemRvArray = [[[NSMutableArray alloc] init] autorelease];
            NSEnumerator *en = [checkboxes objectEnumerator];
            id obj;
            while (obj = [en nextObject]) {
                if ([[obj className] isEqualToString:@"NSButtonCell"]) {
                    [itemRvArray addObject: [NSString stringWithFormat:@"%i", [obj state]]];
                }
            }
            itemRv = [itemRvArray componentsJoinedByString:@" "];
        }
	}
	return [NSArray arrayWithObjects:buttonRv, itemRv, nil];
}


- (void) setControl:(id)sender
{
    CDOptions *options = [self options];
    
    // Setup the control
    NSArray *items = [[[NSArray alloc] init] autorelease];
	items = [options optValues:@"items"];
    NSArray *checked = [[[NSArray alloc] init] autorelease];
    NSArray *mixed = [[[NSArray alloc] init] autorelease];
    NSArray *disabled = [[[NSArray alloc] init] autorelease];
    
    if ([options hasOpt:@"checked"]) {
        checked = [options optValues:@"checked"];
    }
    if ([options hasOpt:@"mixed"]) {
        mixed = [options optValues:@"mixed"];
    }
    if ([options hasOpt:@"disabled"]) {
        disabled = [options optValues:@"disabled"];
    }
    
    // Set default precedence: columns, if both are present or neither are present
    int matrixPrecedence = 0;
    
    // Set default number of columns
    NSInteger columns = 1;
    // Set specified number of columns
    if ([options hasOpt:@"columns"]) {
        columns = [[options optValue:@"columns"] intValue];
        if (columns < 1) {
            columns = 1;
        }
    }
    
    // Set default number of rows
    NSInteger rows = 1;
    // Set specified number of rows
    if ([options hasOpt:@"rows"]) {
        rows = [[options optValue:@"rows"] intValue];
        if (rows < 1) {
            rows = 1;
        }
        if (rows > [items count]){
            rows = [items count];
        }
        // User has specified number of rows, but not columns.
        // Set precedence to expand columns, not rows
        if (![options hasOpt:@"columns"]) {
            matrixPrecedence = 1;
        }
    }
    
    [self setControl: self matrixRows:rows matrixColumns:columns items:items precedence:matrixPrecedence];
    rows = [controlMatrix numberOfRows];
    columns = [controlMatrix numberOfColumns];
    
    NSMutableArray * controls = [[[NSMutableArray alloc] init] autorelease];
    
    // Create the control for each item
    NSInteger currItem = 0;
    NSEnumerator *en = [items objectEnumerator];
    float cellWidth = 0.0;
    id obj;
    while (obj = [en nextObject]) {
        NSButton * button = [[[NSButton alloc] init] autorelease];
        [button setButtonType:NSSwitchButton];
        [button setTitle:[items objectAtIndex:currItem]];
        if (checked != nil && [checked count]) {
            if ([checked containsObject:[NSString stringWithFormat:@"%i", currItem]]) {
                [[button cell] setState:NSOnState];
            }
        }
        if (mixed != nil && [mixed count]) {
            if ([mixed containsObject:[NSString stringWithFormat:@"%i", currItem]]) {
                [[button cell] setAllowsMixedState:YES];
                [[button cell] setState:NSMixedState];
            }
        }
        if (disabled != nil && [disabled count]) {
            if ([disabled containsObject:[NSString stringWithFormat:@"%i", currItem]]) {
                [[button cell] setEnabled: NO];
            }
        }
        [[button cell] setTag:currItem];
        [button sizeToFit];
        if ([button frame].size.width > cellWidth) {
            cellWidth = [button frame].size.width;
        }
        [controls addObject:[button cell]];
        currItem++;
    }
    
    // Set other attributes of matrix
    [controlMatrix setAutosizesCells:NO];
    [controlMatrix setCellSize:NSMakeSize(cellWidth, 18.0f)];
    [controlMatrix setMode:NSHighlightModeMatrix];
    
    // Populate the matrix
    currItem = 0;
    for (int currColumn = 0; currColumn <= columns - 1; currColumn++) {
        for (int currRow = 0; currRow <= rows - 1; currRow++) {
            if (currItem <= [items count] - 1) {
                NSButtonCell * cell = [controls objectAtIndex:currItem];
                [controlMatrix putCell:cell atRow:currRow column:currColumn];
                currItem++;
            }
            else {
                NSCell * blankCell = [[[NSCell alloc] init] autorelease];
                [blankCell setType:NSNullCellType];
                [blankCell setEnabled:NO];
                [controlMatrix putCell:blankCell atRow:currRow column:currColumn];
            }
        }
    }
}


- (void) dealloc
{
	[super dealloc];
}


@end
