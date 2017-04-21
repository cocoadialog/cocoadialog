// CDRadioControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDRadioControl.h"

@implementation CDRadioControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag                name:@"allow-mixed"]];
    [options addOption:[CDOptionSingleNumber        name:@"columns"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"disabled"]];
    [options addOption:[CDOptionMultipleStrings     name:@"items"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"mixed"]];
    [options addOption:[CDOptionSingleNumber        name:@"rows"]];
    [options addOption:[CDOptionSingleNumber        name:@"selected"]];

    // Minimum values.
    options[@"items"].minimumValues = @2;

    // Required options.
    options[@"button1"].required = YES;
    options[@"items"].required = YES;

    return options;
}

- (BOOL)isReturnValueEmpty {
    NSArray * items = controlMatrix.cells;
    if (items != nil && items.count) {
        NSCell * selectedCell = controlMatrix.selectedCell;
        if (selectedCell != nil) {
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

- (NSString *) returnValueEmptyText {
    NSArray * items = controlMatrix.cells;
    if (items.count > 1) {
        return @"You must select at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must select the item \"%@\" before continuing.", [controlMatrix cellAtRow:0 column:0].title];
    }
}

- (void) createControl {    
    NSString * labelText = @"";
    if (option[@"label"].wasProvided) {
        labelText = option[@"label"].stringValue;
    }
	[self setTitleButtonsLabel:labelText];
}

- (void) controlHasFinished:(NSUInteger)button {
    NSArray * radioArray = controlMatrix.cells;
    if (radioArray != nil && radioArray.count) {
        NSCell * selectedCell = controlMatrix.selectedCell;
        if (selectedCell != nil) {
            if (option[@"string-output"].wasProvided) {
                [controlReturnValues addObject:selectedCell.title];
            }
            else {
                [controlReturnValues addObject:[NSString stringWithFormat:@"%ld", controlMatrix.selectedCell.tag]];
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
    NSArray *items = option[@"items"].arrayValue;
    NSArray *disabled = option[@"disabled"].wasProvided ? option[@"disabled"].arrayValue : [NSArray array];
    NSUInteger selected = option[@"selected"].wasProvided ? option[@"selected"].unsignedIntegerValue : -1;

    // Set default precedence: columns, if both are present or neither are present
    int matrixPrecedence = 0;
    
    // Set number of columns.
    NSUInteger columns = option[@"columns"].wasProvided ? option[@"columns"].unsignedIntegerValue : 1;
    if (columns < 1) {
        columns = 1;
    }

    // Set number of rows.
    NSUInteger rows = option[@"rows"].wasProvided ? option[@"rows"].unsignedIntegerValue : 1;
    if (rows < 1) {
        rows = 1;
    }
    if (rows > items.count){
        rows = items.count;
    }

    // User has specified number of rows, but not columns.
    // Set precedence to expand columns, not rows
    if (!option[@"columns"].wasProvided) {
        matrixPrecedence = 1;
    }

    [self setControl: self matrixRows:rows matrixColumns:columns items:items precedence:matrixPrecedence];
    rows = controlMatrix.numberOfRows;
    columns = controlMatrix.numberOfColumns;
    
    NSMutableArray * controls = [[NSMutableArray alloc] init];
    
    // Create the control for each item
    unsigned long currItem = 0;
    NSEnumerator *en = [items objectEnumerator];
    float cellWidth = 0.0;
    id obj;
    while (obj = [en nextObject]) {
        NSButton * button = [[NSButton alloc] init];
        [button setButtonType:NSRadioButton];
        button.title = items[currItem];
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
    [controlMatrix setAllowsEmptySelection:YES];
    [controlMatrix deselectAllCells];
    controlMatrix.mode = NSRadioModeMatrix;
    
    // Populate the matrix
    currItem = 0;
    for (unsigned long currColumn = 0; currColumn <= columns - 1; currColumn++) {
        for (unsigned long currRow = 0; currRow <= rows - 1; currRow++) {
            if (currItem <= items.count - 1) {
                NSButtonCell * cell = controls[currItem];
                [controlMatrix putCell:cell atRow:currRow column:currColumn];
                if (selected == currItem) {
                    [controlMatrix selectCellAtRow:currRow column:currColumn];
                }
                currItem++;
            }
            else {
                NSCell * blankCell = [[NSCell alloc] init];
                blankCell.type = NSNullCellType;
                [blankCell setEnabled:NO];
                [controlMatrix putCell:blankCell atRow:currRow column:currColumn];
            }
        }
    }
}

@end
