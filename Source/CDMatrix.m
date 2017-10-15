// CDMatrix.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDMatrix.h"

@implementation CDMatrix

#pragma mark - Subclassed public instance methods

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (self.matrix.cells.count && self.matrix.selectedCell) {
        [self.matrix selectCellAtRow:self.matrix.selectedRow column:self.matrix.selectedColumn];
    }
}

+ (CDOptions *) availableOptions {
    return super.availableOptions.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDNumber, @"columns").setDefaultValue(@"1"),
    CDOption.create(CDNumber, @"rows").setDefaultValue(@"1"),
    ]);
}

- (void) createControl {
    [super createControl];

    // Set default precedence: columns, if both are present or neither are present
    self.expandColumns = YES;

    // Set number of columns.
    self.columns = self.options[@"columns"].unsignedIntegerValue;
    if (self.columns < 1) {
        self.columns = 1;
    }

    // Set number of rows.
    self.rows = self.options[@"rows"].unsignedIntegerValue;
    if (self.rows < 1) {
        self.rows = 1;
    }
    // User has specified number of rows, but not columns.
    // Set precedence to expand columns, not rows
    if (self.rows > 1 && !self.options[@"columns"].wasProvided) {
        self.expandColumns = YES;
    }

    // Initialize controls.
    self.cells = [NSMutableArray array];

    // Initialize the matrix.
    [self initMatrix];

    // Initialize the cells (columns/rows).
    [self initMatrixCells];

    // Determine if the control added cells to the matrix.
    if (self.matrix.cells.count > 0) {
        [self.matrix sizeToCells];
        [self.matrix.superview setNeedsDisplay:YES];
    }
    else {
        self.matrix.hidden = YES;
        [self.matrix setFrameSize:NSMakeSize(0.0f, 0.0f)];
    }

    // Deselect all cells.
    [self.matrix deselectAllCells];

    // Populate the matrix
    NSUInteger i = 0;
    for (unsigned long currColumn = 0; currColumn <= self.columns - 1; currColumn++) {
        for (unsigned long currRow = 0; currRow <= self.rows - 1; currRow++) {
            if (i <= self.cells.count - 1) {
                NSCell *cell = self.cells[i];
                [self.matrix putCell:cell atRow:currRow column:currColumn];
                if ([self isCellSelected:i]) {
                    [self.matrix selectCellAtRow:currRow column:currColumn];
                }
                i++;
            }
            else {
                NSCell *blankCell = [[NSCell alloc] init];
                blankCell.type = NSNullCellType;
                [blankCell setEnabled:NO];
                [self.matrix putCell:blankCell atRow:currRow column:currColumn];
            }
        }
    }

}

#pragma mark - Public instance methods

- (void) initMatrix {}
- (BOOL) isCellSelected:(NSUInteger)index {
    return NO;
}

#pragma mark - Private instance methods

- (void) initMatrixCells {
    // Ensure subclassed controls provided at least one cell.
    if (!self.cells.count) {
        self.terminal.error(@"The %@ control did not initialize any matrix cells.", self.name.doubleQuote.bold.white, nil).exit(CDTerminalExitCodeControlFailure);
    }

    // Default exact columns/rows.
    unsigned long exactColumns = self.cells.count / self.rows;
    float exactColumnsFloat = (float) self.cells.count / (float)self.rows;

    unsigned long exactRows = self.cells.count / self.columns;
    float exactRowsFloat = (float) self.cells.count / (float) self.columns;

    // Columns have precedence over rows, if items extend past number of columns
    // rows will be increased to account for the additional items.
    if (self.expandColumns) {
        // Items do not fill columns, reduce the columns to fit.
        if (exactColumnsFloat < (float) self.columns) {
            self.columns = (int) exactColumns;
        }
        // Items exceed columns, expand rows
        else if (exactColumnsFloat > (float) self.columns) {
            self.rows = self.cells.count / self.columns;
            exactRowsFloat = (float) self.cells.count / (float) self.columns;
            if (exactRowsFloat > (float) self.rows) {
                self.rows++;
            }
            exactColumnsFloat = (float) self.cells.count / (float)self.rows;
            if (exactColumnsFloat <= (float) self.columns) {
                self.columns = (int) exactColumnsFloat;
            }
        }
        // Extend rows once more if the division is greater than a whole number.
        if (exactRowsFloat > (float) self.rows) {
            self.rows++;
        }
    }
    // Rows have precedence over columns, if items extend past number of rows
    // columns will be increased to account for the additional items.
    else {
        // Items do not fill rows, reduce the rows to fit.
        if (exactRowsFloat < (float) self.rows) {
            self.rows = exactRows;
        }
        // Items exceed rows, expand columns.
        else if (exactRowsFloat > (float) self.rows) {
            self.columns = self.cells.count / self.rows;
            exactColumnsFloat = (float) self.cells.count / (float) self.rows;
            if (exactColumnsFloat > (float) self.columns) {
                self.columns++;
            }
        }
        // Extend rows once more if the division is greater than a whole number.
        if (exactColumnsFloat > (float) self.columns) {
            self.columns++;
        }
    }

    // Ensure columns do not exceed the control count.
    if (self.expandColumns && self.columns > self.cells.count) {
        self.columns = self.cells.count;
    }
    // Ensure rows do not exceed the control count.
    else if (!self.expandColumns && self.rows > self.cells.count) {
        self.rows = self.cells.count;
    }

    // Tell the matrix how many rows and columns it has.
    [self.matrix renewRows:self.rows columns:self.columns];
}

@end
