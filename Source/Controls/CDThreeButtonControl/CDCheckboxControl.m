//
//  CDCheckboxControl.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 9/20/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDCheckboxControl.h"

@implementation CDCheckboxControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleNumber        name:@"rows"        category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionSingleNumber        name:@"columns"     category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionMultipleStrings     name:@"items"       category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"checked"     category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"mixed"       category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"disabled"    category:@"_CHECKBOX_OPTIONS"]];

    return options;
}

- (BOOL)isReturnValueEmpty {
    if (checkboxes.count > 0) {
        NSEnumerator *en = [checkboxes objectEnumerator];
        BOOL hasChecked = NO;
        id obj;
        while (obj = [en nextObject]) {
            if ([obj state] == NSOnState){
                hasChecked = YES;
                break;
            }
        }
        return !hasChecked;
    }
    else {
        return NO;
    }
}
- (NSString *) returnValueEmptyText {
    if (checkboxes.count > 1) {
        return @"You must check at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must check the item \"%@\" before continuing.", [checkboxes[0] title]];
    }
}

- (BOOL) validateOptions {
    // Check that we're in the right sub-class
    if (![self isMemberOfClass:[CDCheckboxControl class]]) {
        [self fatalError:@"This control is not properly classed."];
    }

    // Check that at least button1 has been specified.
	if (![arguments getOption:@"button1"])	{
        [self fatalError:@"Must supply at least --button1"];
	}

    // Check that at least one item has been specified.
    NSArray *items = [NSArray arrayWithArray:[arguments getOption:@"items"]];
    if (!items.count) { 
        [self fatalError:@"Must supply at least one item in --items"];
	}

    return [super validateOptions];
}
- (void) createControl {
	[self setTitleButtonsLabel:[arguments getOption:@"label"]];

	// set return values 
    NSArray * cells = controlMatrix.cells;
    NSMutableArray *tmpValues = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *en = [cells objectEnumerator];
    id obj;
    while (obj = [en nextObject]) {
        if ([[obj className] isEqualToString:@"NSButtonCell"]) {
            [tmpValues addObject:obj];
        } 
    }
    checkboxes = [[NSMutableArray arrayWithArray:tmpValues] autorelease];
    en = [tmpValues objectEnumerator];
    while (obj = [en nextObject]) {
        checkboxes[[obj tag]] = obj;
    }
}

- (void) controlHasFinished:(int)button {
    NSMutableArray *checkboxesArray = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *en = [checkboxes objectEnumerator];
    id obj;
	if ([self.arguments hasOption:@"string-output"]) {
        if (checkboxes != nil && checkboxes.count) {
            unsigned long state;
            while (obj = [en nextObject]) {
                state = [obj state];
                switch (state) {
                    case NSOffState: [checkboxesArray addObject: @"off"]; break;
                    case NSOnState: [checkboxesArray addObject: @"on"]; break;
                    case NSMixedState: [checkboxesArray addObject: @"mixed"]; break;
                }
            }
            [controlReturnValues addObject:[checkboxesArray componentsJoinedByString:@" "]];
        }
	} else {
        if (checkboxes != nil && checkboxes.count) {
            while (obj = [en nextObject]) {
                [checkboxesArray addObject: [NSString stringWithFormat:@"%li", (long)[obj state]]];
            }
            [controlReturnValues addObject:[checkboxesArray componentsJoinedByString:@" "]];
        }
	}    
    [super controlHasFinished:button];
}


- (void) setControl:(id)sender {
    // Setup the control
    NSArray *items = [NSArray arrayWithArray:[arguments getOption:@"items"]];
    NSArray *checked = [[[NSArray alloc] init] autorelease];
    NSArray *mixed = [[[NSArray alloc] init] autorelease];
    NSArray *disabled = [[[NSArray alloc] init] autorelease];
    
    if ([arguments hasOption:@"checked"]) {
        checked = [arguments getOption:@"checked"];
    }
    if ([arguments hasOption:@"mixed"]) {
        mixed = [arguments getOption:@"mixed"];
    }
    if ([arguments hasOption:@"disabled"]) {
        disabled = [arguments getOption:@"disabled"];
    }
    
    // Set default precedence: columns, if both are present or neither are present
    int matrixPrecedence = 0;
    
    // Set default number of columns
    unsigned long columns = 1;
    // Set specified number of columns
    if ([arguments hasOption:@"columns"]) {
        columns = (unsigned long) [arguments getOption:@"columns"];
        if (columns < 1) {
            columns = 1;
        }
    }
    
    // Set default number of rows
    unsigned long rows = 1;
    // Set specified number of rows
    if ([arguments hasOption:@"rows"]) {
        rows = (unsigned long) [arguments getOption:@"rows"];
        if (rows < 1) {
            rows = 1;
        }
        if (rows > items.count){
            rows = items.count;
        }
        // User has specified number of rows, but not columns.
        // Set precedence to expand columns, not rows
        if (![arguments hasOption:@"columns"]) {
            matrixPrecedence = 1;
        }
    }
    
    [self setControl: self matrixRows:rows matrixColumns:columns items:items precedence:matrixPrecedence];
    rows = controlMatrix.numberOfRows;
    columns = controlMatrix.numberOfColumns;
    
    NSMutableArray * controls = [[[NSMutableArray alloc] init] autorelease];
    
    // Create the control for each item
    unsigned long currItem = 0;
    NSEnumerator *en = [items objectEnumerator];
    float cellWidth = 0.0;
    id obj;
    while (obj = [en nextObject]) {
        NSButton * button = [[[NSButton alloc] init] autorelease];
        [button setButtonType:NSSwitchButton];
        button.title = items[currItem];
        if (checked != nil && checked.count) {
            if ([checked containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                button.cell.state = NSOnState;
            }
        }
        if (mixed != nil && mixed.count) {
            if ([mixed containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                [button.cell setAllowsMixedState:YES];
                button.cell.state = NSMixedState;
            }
        }
        if (disabled != nil && disabled.count) {
            if ([disabled containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                [button.cell setEnabled: NO];
            }
        }
        button.cell.tag = currItem;
        [button sizeToFit];
        if (button.frame.size.width > cellWidth) {
            cellWidth = button.frame.size.width;
        }
        [controls addObject:button.cell];
        currItem++;
    }
    
    // Set other attributes of matrix
    [controlMatrix setAutosizesCells:NO];
    controlMatrix.cellSize = NSMakeSize(cellWidth, 18.0f);
    controlMatrix.mode = NSHighlightModeMatrix;
    
    // Populate the matrix
    currItem = 0;
    for (unsigned long currColumn = 0; currColumn <= columns - 1; currColumn++) {
        for (unsigned long currRow = 0; currRow <= rows - 1; currRow++) {
            if (currItem <= items.count - 1) {
                NSButtonCell * cell = controls[currItem];
                [controlMatrix putCell:cell atRow:currRow column:currColumn];
                currItem++;
            }
            else {
                NSCell * blankCell = [[[NSCell alloc] init] autorelease];
                blankCell.type = NSNullCellType;
                [blankCell setEnabled:NO];
                [controlMatrix putCell:blankCell atRow:currRow column:currColumn];
            }
        }
    }
}

@end
