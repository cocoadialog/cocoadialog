

#import "CDThreeButtonControl.h"

@implementation CDRadioControl

- (NSDictionary*) availableKeys
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
    if (![self isMemberOfClass:CDRadioControl.class]) {
        if ([self.options hasOpt:@"debug"]) {
			[self debug:@"This run-mode is not properly classed."];
		}
        return NO;
    }
	// Check that at least button1 has been specified
	if (![self.options optValue:@"button1"])	{
    [self debug:@"Must supply at least --button1"];
		return NO;
	}
  // Check that at least one item has been specified
  NSArray *items = [NSArray arrayWithArray:[self.options optValues:@"items"]];
  if (!items.count)
    return [self debug:@"Must supply at least one --items"], NO;

  // Load nib
	if (![NSBundle loadNibNamed:@"tbc" owner:self])
    return [self debug:@"Could not load tbc.nib"], NO;

  // Everything passed
  return YES;
}

- (BOOL)isReturnValueEmpty
{
    NSArray * items = controlMatrix.cells;
    return items && items.count ? controlMatrix.selectedCell /* NSCell * selectedCell */ == nil : NO;
}

- (NSString*) returnValueEmptyText
{
    NSArray * items = controlMatrix.cells;
    return items.count > 1 ? @"You must select at least one item before continuing."
                           : [NSString stringWithFormat: @"You must select the item \"%@\" before continuing.", [[controlMatrix cellAtRow:0 column:0] title]];
}

- (void) createControl {

  // Validate control before continuing
	if (![self validateControl:self.options]) return;
    
  NSString * labelText = [self.options hasOpt:@"label"] && [self.options optValue:@"label"]
                       ? [self.options optValue:@"label"] : @"";

	[self setTitleButtonsLabel:labelText];
}

- (void) controlHasFinished:(int)button {

    NSArray * radioArray = controlMatrix.cells;
    if (radioArray != nil && [radioArray count]) {

        NSCell * selectedCell = controlMatrix.selectedCell;

        if (selectedCell)

          [self.controlReturnValues addObject:
            [self.options hasOpt:@"string-output"]
              ? selectedCell.title
              : [NSString stringWithFormat:@"%d", [controlMatrix.selectedCell tag]]];
        else
            [self.controlReturnValues addObject:[NSString stringWithFormat:@"%d", -1]];
    }
    else {
        [self.controlReturnValues addObject:[NSString stringWithFormat:@"%d", -1]];
    }
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {
    // Setup the control
    NSArray *items = [NSArray arrayWithArray:[self.options optValues:@"items"]];
    unsigned long selected = -1;
    NSArray *disabled = NSArray.new;


    if ([self.options hasOpt:@"selected"])
        selected = [[self.options optValue:@"selected"] intValue];

    if ([self.options hasOpt:@"disabled"])
        disabled = [self.options optValues:@"disabled"];
    
    // Set default precedence: columns, if both are present or neither are present
    int matrixPrecedence = 0;
    
    // Set default number of columns
    unsigned long columns = 1;
    // Set specified number of columns
    if ([self.options hasOpt:@"columns"]) {
        columns = [[self.options optValue:@"columns"] intValue];
        if (columns < 1) columns = 1;
    }
    
    // Set default number of rows
    unsigned long rows = 1;
    // Set specified number of rows
    if ([self.options hasOpt:@"rows"]) {
        rows = [[self.options optValue:@"rows"] intValue];
        if (rows < 1) rows = 1;

        if (rows > [items count]) rows = items.count;
        // User has specified number of rows, but not columns.
        // Set precedence to expand columns, not rows
        if (![self.options hasOpt:@"columns"])
            matrixPrecedence = 1;
    }

    [self setControl: self matrixRows:rows matrixColumns:columns items:items precedence:matrixPrecedence];
    rows = controlMatrix.numberOfRows;
    columns = controlMatrix.numberOfColumns;
    
    NSMutableArray * controls = @[].mutableCopy;
    
    // Create the control for each item
    unsigned long currItem = 0;
    NSEnumerator *en = items.objectEnumerator;
    float cellWidth = 0.0;
    id obj;
    while (obj = en.nextObject) {
        NSButton * button = NSButton.new;
        [button setButtonType:NSRadioButton];
        [button setTitle:items[currItem]];
        if (disabled != nil && disabled.count &&
           [disabled containsObject:[NSString stringWithFormat:@"%i", currItem]])
                [button.cell setEnabled: NO];

        [button.cell setTag:currItem];
        [button sizeToFit];
        if (button.frame.size.width > cellWidth) {
            cellWidth = button.frame.size.width;
        }
        [controls addObject:button.cell];
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
                NSButtonCell * cell = controls[currItem];
                [controlMatrix putCell:cell atRow:currRow column:currColumn];
                if (selected == currItem) {
                    [controlMatrix selectCellAtRow:currRow column:currColumn];
                }
                currItem++;
            }
            else {
                NSCell * blankCell = NSCell.new;
                [blankCell setType:NSNullCellType];
                [blankCell setEnabled:NO];
                [controlMatrix putCell:blankCell atRow:currRow column:currColumn];
            }
        }
    }
}

@end
