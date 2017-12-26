// CDRadio.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDRadio.h"

@implementation CDRadio

+ (NSString *)scope {
  return @"radio";
}

+ (CDOptions *)availableOptions {
  CDOptions *options = super.availableOptions;

  // Require at least one button.
  options[@"button1"].require(YES).min(1);

  return options.addOptionsToScope(self.class.scope,
    @[
      CDOption.create(CDBoolean, @"allow-mixed"),
      CDOption.create(CDNumber, @"disabled").max(-1),
      CDOption.create(CDString, @"items").min(2).max(-1).require(YES),
      CDOption.create(CDNumber, @"mixed").max(-1),
      CDOption.create(CDNumber, @"selected"),
    ]);
}

- (void)controlHasFinished:(NSInteger)button {
  if (self.matrix.cells != nil && self.matrix.cells.count) {
    NSCell *selectedCell = self.matrix.selectedCell;
    if (selectedCell != nil) {
      if (self.options[@"return-labels"].boolValue) {
        self.returnValues[@"value"] = selectedCell.title;
      }
      else {
        self.returnValues[@"value"] = @(self.matrix.selectedCell.tag);
      }
    }
    else {
      self.returnValues[@"value"] = @-1;
    }
  }
  else {
    self.returnValues[@"value"] = @-1;
  }
  [super controlHasFinished:button];
}

- (void)createControl {
  [super createControl];
  self.items = self.options[@"items"].arrayValue ?: [NSArray array];
  self.mixed = self.options[@"mixed"].arrayValue ?: [NSArray array];
  self.disabled = self.options[@"disabled"].arrayValue ?: [NSArray array];
}

- (void)initMatrix {
  [super initMatrix];

  NSUInteger i = 0;
  float cellWidth = 0.0f;
  for (NSString *item in self.items) {
    NSButton *button = [[NSButton alloc] init];
    [button setButtonType:NSRadioButton];
    button.title = item;
    if (self.disabled != nil && self.disabled.count) {
      if ([self.disabled containsObject:[NSString stringWithFormat:@"%lu", i]]) {
        [button.cell setEnabled:NO];
      }
    }
    button.cell.tag = i;
    [button sizeToFit];
    if (button.frame.size.width > cellWidth) {
      cellWidth = (float) button.frame.size.width;
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

- (BOOL)isCellSelected:(NSUInteger)index {
  return self.options[@"selected"].wasProvided && self.options[@"selected"].unsignedIntValue == index;
}

- (BOOL)isReturnValueEmpty {
  return !(self.matrix.cells == nil || !self.matrix.cells.count || self.matrix.selectedCell != nil);
}

- (NSString *)returnValueEmptyText {
  if (self.matrix.cells.count > 1) {
    return @"You must select at least one item before continuing.";
  }
  else {
    return [NSString stringWithFormat:@"You must select the item \"%@\" before continuing.", [self.matrix cellAtRow:0 column:0].title];
  }
}

@end
