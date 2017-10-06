// CDCheckbox.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDCheckbox.h"

@implementation CDCheckbox

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    // Require --button1.
    options[@"button1"].required = YES;

    // --checked
    [options add:[CDOptionMultipleNumbers     name:@"checked"     category:@"CHECKBOX_OPTIONS"]];

    // --disabled
    [options add:[CDOptionMultipleNumbers     name:@"disabled"    category:@"CHECKBOX_OPTIONS"]];

    // --items
    [options add:[CDOptionMultipleStrings     name:@"items"       category:@"CHECKBOX_OPTIONS"]];
    options[@"items"].required = YES;

    // --mixed
    [options add:[CDOptionMultipleNumbers     name:@"mixed"       category:@"CHECKBOX_OPTIONS"]];

    return options;
}

- (void) initControl {
    [super initControl];

    self.checked = option[@"checked"].arrayValue ?: [NSArray array];
    self.items = option[@"items"].arrayValue ?: [NSArray array];
    self.mixed = option[@"mixed"].arrayValue ?: [NSArray array];
    self.disabled = option[@"disabled"].arrayValue ?: [NSArray array];
    
    // set return values
    NSArray * cells = self.matrix.cells;
    NSMutableArray *tmpValues = [NSMutableArray array];
    NSEnumerator *en = [cells objectEnumerator];
    id obj;
    while (obj = [en nextObject]) {
        if ([[obj className] isEqualToString:@"NSButtonCell"]) {
            [tmpValues addObject:obj];
        } 
    }
    self.checkboxes = [NSMutableArray arrayWithArray:tmpValues];
    en = [tmpValues objectEnumerator];
    while (obj = [en nextObject]) {
        self.checkboxes[[obj tag]] = obj;
    }
}

- (void) initMatrix {
    [super initMatrix];

    // Create the control for each item
    NSUInteger currItem = 0;
    NSEnumerator *en = [self.items objectEnumerator];
    float cellWidth = 0.0;
    id obj;
    while (obj = [en nextObject]) {
        NSButton * button = [[NSButton alloc] init];
        [button setButtonType:NSSwitchButton];
        button.title = self.items[currItem];
        if (self.checked.count) {
            if ([self.checked containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                button.cell.state = NSOnState;
            }
        }
        if (self.mixed.count) {
            if ([self.mixed containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                [button.cell setAllowsMixedState:YES];
                button.cell.state = NSMixedState;
            }
        }
        if (self.disabled.count) {
            if ([self.disabled containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                [button.cell setEnabled: NO];
            }
        }
        button.cell.tag = currItem;
        [button sizeToFit];
        if (button.frame.size.width > cellWidth) {
            cellWidth = button.frame.size.width;
        }
        [self.cells addObject:button.cell];
        currItem++;
    }

    // Set other attributes of matrix
    [self.matrix setAutosizesCells:NO];
    self.matrix.cellSize = NSMakeSize(cellWidth, 18.0f);
    self.matrix.mode = NSHighlightModeMatrix;
}


- (void) controlHasFinished:(NSUInteger)button {
    NSMutableArray *checkboxesArray = [NSMutableArray array];
    NSEnumerator *en = [self.checkboxes objectEnumerator];
    id obj;
    if (option[@"return-labels"].wasProvided) {
        if (self.checkboxes != nil && self.checkboxes.count) {
            unsigned long state;
            while (obj = [en nextObject]) {
                state = [obj state];
                switch (state) {
                    case NSOffState: [checkboxesArray addObject: @"off"]; break;
                    case NSOnState: [checkboxesArray addObject: @"on"]; break;
                    case NSMixedState: [checkboxesArray addObject: @"mixed"]; break;
                }
            }
        }
    } else {
        if (self.checkboxes != nil && self.checkboxes.count) {
            while (obj = [en nextObject]) {
                [checkboxesArray addObject:[NSNumber numberWithInteger:[obj state]]];
            }
        }
    }

    returnValues[@"value"] = checkboxesArray;

    [super controlHasFinished:button];
}

- (BOOL) isReturnValueEmpty {
    if (self.checkboxes.count > 0) {
        NSEnumerator *en = [self.checkboxes objectEnumerator];
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
    if (self.checkboxes.count > 1) {
        return @"You must check at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must check the item \"%@\" before continuing.", [self.checkboxes[0] title]];
    }
}

@end
