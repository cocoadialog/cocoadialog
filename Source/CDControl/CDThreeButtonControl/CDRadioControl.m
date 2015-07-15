//
//  CDRadioControl.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 9/23/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDRadioControl.h"

@implementation CDRadioControl

- (NSDictionary *) availableKeys
{
	NSNumber *vNone = @CDOptionsNoValues;
	NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vMul = @CDOptionsMultipleValues;

	return @{@"allow-mixed": vNone,
            @"items": vMul,
            @"selected": vOne,
            @"mixed": vMul,
            @"disabled": vMul,
            @"rows": vOne,
            @"columns": vOne};
}

- (BOOL) validateOptions {
    // Check that we're in the right sub-class
    if (![self isMemberOfClass:[CDRadioControl class]]) {
        if ([options hasOpt:@"debug"]) {
			[self debug:@"This run-mode is not properly classed."];
		}
        return NO;
    }
	// Check that at least button1 has been specified
	if (![options optValue:@"button1"])	{
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least --button1"];
		}
		return NO;
	}
    // Check that at least one item has been specified
    NSArray *items = [NSArray arrayWithArray:[options optValues:@"items"]];
    if (![items count]) {
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least one --items"];
		}
		return NO;
	}
    // Load nib
	if (![[NSBundle mainBundle] loadNibNamed:@"tbc" owner:self topLevelObjects:nil])
    {
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Could not load tbc.nib"];
		}
		return NO;
	}
    // Everything passed
    return YES;
}

- (BOOL)isReturnValueEmpty
{
    NSArray * items = [controlMatrix cells];
    if (items && [items count]) {
        NSCell * selectedCell = [controlMatrix selectedCell];
        if (selectedCell) {
            return NO;
        }
        else {
            return YES;
        }
    }
    else {
        return NO;
    }
}

- (NSString *) returnValueEmptyText
{
    NSArray * items = [controlMatrix cells];
    if ([items count] > 1) {
        return @"You must select at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must select the item \"%@\" before continuing.", [[controlMatrix cellAtRow:0 column:0] title]];
    }
}

- (void) createControl {
    // Validate control before continuing
	if (![self validateControl:options]) {
        return;
    }

    NSString * labelText = @"";
    if ([options hasOpt:@"label"] && [options optValue:@"label"]) {
        labelText = [options optValue:@"label"];
    }
	[self setTitleButtonsLabel:labelText];
}

- (void) controlHasFinished:(int)button {
    NSArray * radioArray = [controlMatrix cells];
    if (radioArray && [radioArray count]) {
        NSCell * selectedCell = [controlMatrix selectedCell];
        if (selectedCell) {
            if ([[self options] hasOpt:@"string-output"]) {
                [controlReturnValues addObject:[selectedCell title]];
            }
            else {
                [controlReturnValues addObject:[NSString stringWithFormat:@"%ld", (long)[[controlMatrix selectedCell] tag]]];
            }
        }
        else {
            [controlReturnValues addObject:[NSString stringWithFormat:@"%d", -1]];
        }
    }
    else {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%d", -1]];
    }
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {
    // Setup the control
    NSArray *items = [NSArray arrayWithArray:[options optValues:@"items"]];
    unsigned long selected = -1;
    NSArray *disabled = [[NSArray alloc] init];


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

    NSMutableArray * controls = [[NSMutableArray alloc] init];

    // Create the control for each item
    float cellWidth = 0.0;

    NSUInteger index = 0;
    for (id object in items)
    {
        NSButton * button = [[NSButton alloc] init];
        [button setButtonType:NSRadioButton];
        [button setTitle:items[index]];
        if (disabled && [disabled count]) {
            if ([disabled containsObject:[NSString stringWithFormat:@"%lu", index]]) {
                [[button cell] setEnabled: NO];
            }
        }
        [[button cell] setTag:index];
        [button sizeToFit];
        if ([button frame].size.width > cellWidth) {
            cellWidth = [button frame].size.width;
        }
        [controls addObject:[button cell]];
    }
    

    // Set other attributes of matrix
    [controlMatrix setAutosizesCells:NO];
    [controlMatrix setCellSize:NSMakeSize(cellWidth, 18.0f)];
    [controlMatrix setAllowsEmptySelection:YES];
    [controlMatrix deselectAllCells];
    [controlMatrix setMode:NSRadioModeMatrix];

    // Populate the matrix
    int x = 0;
    for (unsigned long currColumn = 0; currColumn <= columns - 1; currColumn++) {
        for (unsigned long currRow = 0; currRow <= rows - 1; currRow++) {
            if (x <= [items count] - 1) {
                NSButtonCell * cell = controls[x];
                [controlMatrix putCell:cell atRow:currRow column:currColumn];
                if (selected == x) {
                    [controlMatrix selectCellAtRow:currRow column:currColumn];
                }
                x++;
            }
            else {
                NSCell * blankCell = [[NSCell alloc] init];
                [blankCell setType:NSNullCellType];
                [blankCell setEnabled:NO];
                [controlMatrix putCell:blankCell atRow:currRow column:currColumn];
            }
        }
    }
}

@end
