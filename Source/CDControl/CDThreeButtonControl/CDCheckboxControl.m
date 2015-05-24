//
//  CDCheckboxControl.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 9/20/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDCheckboxControl.h"

@implementation CDCheckboxControl

- (NSDictionary *) availableKeys {
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];

	return [NSDictionary dictionaryWithObjectsAndKeys:
            vOne, @"rows",
            vOne, @"columns",
            vMul, @"items",
            vMul, @"checked",
            vMul, @"mixed",
            vMul, @"disabled",
            nil];
}
- (BOOL)isReturnValueEmpty {
    if ([checkboxes count] > 0) {
        NSEnumerator *en = [checkboxes objectEnumerator];
        BOOL hasChecked = NO;
        id obj;
        while ((obj = [en nextObject])) {
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
    if ([checkboxes count] > 1) {
        return @"You must check at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must check the item \"%@\" before continuing.", [[checkboxes objectAtIndex:0] title]];
    }
}

- (BOOL) validateOptions {
    // Check that we're in the right sub-class
    if (![self isMemberOfClass:[CDCheckboxControl class]]) {
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
    // Everything passed
    return YES;
}
- (void) createControl {
	[self setTitleButtonsLabel:[options optValue:@"label"]];

	// set return values
    NSArray * cells = [controlMatrix cells];
    NSMutableArray *tmpValues = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *en = [cells objectEnumerator];
    id obj;
    while ((obj = [en nextObject])) {
        if ([[obj className] isEqualToString:@"NSButtonCell"]) {
            [tmpValues addObject:obj];
        }
    }
    checkboxes = [[NSMutableArray arrayWithArray:tmpValues] autorelease];
    en = [tmpValues objectEnumerator];
    while (obj == [en nextObject]) {
        [checkboxes replaceObjectAtIndex:[obj tag] withObject:obj];
    }
}

- (void) controlHasFinished:(int)button {
    NSMutableArray *checkboxesArray = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *en = [checkboxes objectEnumerator];
    id obj;
	if ([[self options] hasOpt:@"string-output"]) {
        if (checkboxes != nil && [checkboxes count]) {
            unsigned long state;
            while ((obj = [en nextObject])) {
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
        if (checkboxes != nil && [checkboxes count]) {
            while ((obj = [en nextObject])) {
                [checkboxesArray addObject: [NSString stringWithFormat:@"%li", (long)[obj state]]];
            }
            [controlReturnValues addObject:[checkboxesArray componentsJoinedByString:@" "]];
        }
	}
    [super controlHasFinished:button];
}


- (void) setControl:(id)sender {
    // Setup the control
    NSArray *items = [NSArray arrayWithArray:[options optValues:@"items"]];
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
    while ((obj = [en nextObject])) {
        NSButton * button = [[[NSButton alloc] init] autorelease];
        [button setButtonType:NSSwitchButton];
        [button setTitle:[items objectAtIndex:currItem]];
        if (checked != nil && [checked count]) {
            if ([checked containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                [[button cell] setState:NSOnState];
            }
        }
        if (mixed != nil && [mixed count]) {
            if ([mixed containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                [[button cell] setAllowsMixedState:YES];
                [[button cell] setState:NSMixedState];
            }
        }
        if (disabled != nil && [disabled count]) {
            if ([disabled containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
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
    for (unsigned long currColumn = 0; currColumn <= columns - 1; currColumn++) {
        for (unsigned long currRow = 0; currRow <= rows - 1; currRow++) {
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

@end
