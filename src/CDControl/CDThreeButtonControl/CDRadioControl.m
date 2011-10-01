//
//  CDRadioControl.m
//  CocoaDialog
//
//  Created by Mark Carver on 9/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDRadioControl.h"

@implementation CDRadioControl

- (NSDictionary *) availableKeys
{
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    
	return [NSDictionary dictionaryWithObjectsAndKeys:
            vNone,@"allow-mixed",
            vMul, @"items",
            vOne, @"selected",
            vMul, @"mixed",
            vMul, @"disabled",
            vOne, @"rows",
            vOne, @"columns",
            nil];
}

- (BOOL) validateControl:(CDOptions *)options
{
    // Check that we're in the right sub-class
    if (![self isMemberOfClass:[CDRadioControl class]]) {
        if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"This run-mode is not properly classed."];
		}
        return NO;
    }
	// Check that at least button1 has been specified
	if (![options optValue:@"button1"])	{
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Must supply at least --button1"];
		}
		return NO;
	}
    // Check that at least one item has been specified
    NSArray *items = [[[NSArray alloc] init] autorelease];
	items = [options optValues:@"items"];
    if (![items count]) { 
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Must supply at least one --items"];
		}
		return NO;
	}
    // Load nib
	if (![NSBundle loadNibNamed:@"tbc" owner:self]) {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Could not load tbc.nib"];
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
        NSArray * items = [controlMatrix cells];
        if (items != nil && [items count]) {
            NSCell * selectedCell = [controlMatrix selectedCell];
            if (selectedCell != nil) {
                itemRv = [selectedCell title];
            }
            else {
                itemRv = [NSString stringWithFormat:@"%d", -1];
            }
        }
        else {
            itemRv = [NSString stringWithFormat:@"%d", -1];
        }
	} else {
		buttonRv = [NSString stringWithFormat:@"%d",rv];
        NSArray * items = [controlMatrix cells];
        if (items != nil && [items count]) {
            NSCell * selectedCell = [controlMatrix selectedCell];
            if (selectedCell != nil) {
                itemRv = [NSString stringWithFormat:@"%d", [[controlMatrix selectedCell] tag]];
            }
            else {
                itemRv = [NSString stringWithFormat:@"%d", -1];
            }
        }
        else {
            itemRv = [NSString stringWithFormat:@"%d", -1];
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
    unsigned long selected = -1;
    NSArray *disabled = [[[NSArray alloc] init] autorelease];


    if ([options hasOpt:@"selected"]) {
        selected = [[options optValue:@"selected"] intValue];
    }

    if ([options hasOpt:@"disabled"]) {
        disabled = [options optValues:@"disabled"];
    }
    
    // Set default precedence: columns, if both are present or neither are present
    int matrixPrecedence = 0;
    
    // Set default number of columns
    unsigned long columns = 1;
    // Set specified number of columns
    if ([options hasOpt:@"columns"]) {
        columns = [[options optValue:@"columns"] intValue];
        if (columns < 1) {
            columns = 1;
        }
    }
    
    // Set default number of rows
    unsigned long rows = 1;
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
    unsigned long currItem = 0;
    NSEnumerator *en = [items objectEnumerator];
    float cellWidth = 0.0;
    id obj;
    while (obj = [en nextObject]) {
        NSButton * button = [[[NSButton alloc] init] autorelease];
        [button setButtonType:NSRadioButton];
        [button setTitle:[items objectAtIndex:currItem]];
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
    [controlMatrix setAllowsEmptySelection:YES];
    [controlMatrix deselectAllCells];
    [controlMatrix setMode:NSRadioModeMatrix];
    
    // Populate the matrix
    currItem = 0;
    for (unsigned long currColumn = 0; currColumn <= columns - 1; currColumn++) {
        for (unsigned long currRow = 0; currRow <= rows - 1; currRow++) {
            if (currItem <= [items count] - 1) {
                NSButtonCell * cell = [controls objectAtIndex:currItem];
                [controlMatrix putCell:cell atRow:currRow column:currColumn];
                if (selected == currItem) {
                    [controlMatrix selectCellAtRow:currRow column:currColumn];
                }
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
