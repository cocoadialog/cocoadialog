// CDRadio.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDRadio.h"

@implementation CDRadio

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    // Require --button1.
    options[@"button1"].required = YES;

    // --allow-mixed
    [options add:[CDOptionBoolean             name:@"allow-mixed"]];

    // --disabled
    [options add:[CDOptionMultipleNumbers     name:@"disabled"]];

    // --items
    [options add:[CDOptionMultipleStrings     name:@"items"]];
    options[@"items"].minimumValues = @2;
    options[@"items"].required = YES;

    // --mixed
    [options add:[CDOptionMultipleNumbers     name:@"mixed"]];

    // --selected
    [options add:[CDOptionSingleNumber        name:@"selected"]];

    return options;
}

- (void) controlHasFinished:(NSUInteger)button {
    if (self.matrix.cells != nil && self.matrix.cells.count) {
        NSCell *selectedCell = self.matrix.selectedCell;
        if (selectedCell != nil) {
            if (option[@"return-labels"].wasProvided) {
                returnValues[@"value"] = selectedCell.title;
            }
            else {
                returnValues[@"value"] = [NSNumber numberWithInteger:self.matrix.selectedCell.tag];
            }
        }
        else {
            returnValues[@"value"] = @-1;
        }
    }
    else {
        returnValues[@"value"] = @-1;
    }
    [super controlHasFinished:button];
}

- (void) initControl {
    [super initControl];
    self.items = option[@"items"].arrayValue ?: [NSArray array];
    self.mixed = option[@"mixed"].arrayValue ?: [NSArray array];
    self.disabled = option[@"disabled"].arrayValue ?: [NSArray array];
}

- (void) initMatrix {
    [super initMatrix];

    NSUInteger i = 0;
    float cellWidth = 0.0f;
    for (NSString *item in self.items) {
        NSButton *button = [[NSButton alloc] init];
        [button setButtonType:NSRadioButton];
        button.title = item;
        if (self.disabled != nil && self.disabled.count) {
            if ([self.disabled containsObject:[NSString stringWithFormat:@"%lu", i]]) {
                [button.cell setEnabled: NO];
            }
        }
        button.cell.tag = i;
        [button sizeToFit];
        if (button.frame.size.width > cellWidth) {
            cellWidth = button.frame.size.width;
        }
        [self.cells addObject:button.cell];
        i++;
    }

    // Set other attributes of matrix
    [self.matrix setAutosizesCells:NO];
    self.matrix.cellSize = NSMakeSize(cellWidth, 18.0f);
    [self.matrix setAllowsEmptySelection:YES];
    self.matrix.mode = NSRadioModeMatrix;
}

- (BOOL) isCellSelected:(NSUInteger)index {
    return option[@"selected"].wasProvided ? option[@"selected"].unsignedIntValue == index : NO;
}

- (BOOL) isReturnValueEmpty {
    if (self.matrix.cells == nil || !self.matrix.cells.count || self.matrix.selectedCell != nil) {
        return NO;
    }
    return YES;
}

- (NSString *) returnValueEmptyText {
    if (self.matrix.cells.count > 1) {
        return @"You must select at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must select the item \"%@\" before continuing.", [self.matrix cellAtRow:0 column:0].title];
    }
}

@end
