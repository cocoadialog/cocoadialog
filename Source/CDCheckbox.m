// CDCheckbox.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDCheckbox.h"

@implementation CDCheckbox

+ (NSString *)scope {
  return @"checkbox";
}

+ (CDOptions *)availableOptions {
  CDOptions *options = super.availableOptions;

  // Require at least one button.
  options[@"button1"].require(YES).min(1);

  return options.addOptionsToScope(self.class.scope,
    @[
      CDOption.create(CDNumber, @"checked").max(-1),
      CDOption.create(CDNumber, @"disabled").max(-1),
      CDOption.create(CDString, @"items").max(-1).require(YES),
      CDOption.create(CDNumber, @"mixed").max(-1),
    ]);
}

- (void)createControl {
  [super createControl];

  self.checked = self.options[@"checked"].arrayValue ?: [NSArray array];
  self.items = self.options[@"items"].arrayValue ?: [NSArray array];
  self.mixed = self.options[@"mixed"].arrayValue ?: [NSArray array];
  self.disabled = self.options[@"disabled"].arrayValue ?: [NSArray array];

  // set return values
  NSArray *cells = self.matrix.cells;
  NSMutableArray *tmpValues = [NSMutableArray array];
  NSEnumerator *en = [cells objectEnumerator];
  id obj;
  while ((obj = [en nextObject])) {
    if ([[obj className] isEqualToString:@"NSButtonCell"]) {
      [tmpValues addObject:obj];
    }
  }
  self.checkboxes = [NSMutableArray arrayWithArray:tmpValues];
  en = [tmpValues objectEnumerator];
  while ((obj = [en nextObject])) {
    NSUInteger i = (NSUInteger) ((NSView *) obj).tag;
    self.checkboxes[i] = obj;
  }
}

- (void)initMatrix {
  [super initMatrix];

  // Create the control for each item
  NSUInteger currItem = 0;
  NSEnumerator *en = [self.items objectEnumerator];
  float cellWidth = 0.0;
  id obj;
  while ((obj = [en nextObject])) {
    NSButton *button = [[NSButton alloc] init];
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
        [button.cell setEnabled:NO];
      }
    }
    button.cell.tag = currItem;
    [button sizeToFit];
    if (button.frame.size.width > cellWidth) {
      cellWidth = (float) button.frame.size.width;
    }
    [self.cells addObject:button.cell];
    currItem++;
  }

  // Set other attributes of matrix.
  [self.matrix setAutosizesCells:NO];
  self.matrix.cellSize = NSMakeSize(cellWidth, 18.0f);
  self.matrix.mode = NSHighlightModeMatrix;
}


- (void)controlHasFinished:(NSInteger)button {
  NSMutableArray *checkboxesArray = [NSMutableArray array];
  NSEnumerator *en = [self.checkboxes objectEnumerator];
  id obj;
  if (self.options[@"return-labels"].wasProvided) {
    if (self.checkboxes != nil && self.checkboxes.count) {
      NSControlStateValue state;
      while ((obj = [en nextObject])) {
        state = [obj state];
        if (state == NSOffState) {
          [checkboxesArray addObject:@"off"];
        }
        else if (state == NSOnState) {
          [checkboxesArray addObject:@"on"];
        }
        else if (state == NSMixedState) {
          [checkboxesArray addObject:@"mixed"];
        }
      }
    }
  }
  else {
    if (self.checkboxes != nil && self.checkboxes.count) {
      while ((obj = [en nextObject])) {
        [checkboxesArray addObject:@([obj state])];
      }
    }
  }

  self.returnValues[@"value"] = checkboxesArray;

  [super controlHasFinished:button];
}

- (BOOL)isReturnValueEmpty {
  if (self.checkboxes.count > 0) {
    NSEnumerator *en = [self.checkboxes objectEnumerator];
    BOOL hasChecked = NO;
    id obj;
    while ((obj = [en nextObject])) {
      if ([obj state] == NSOnState) {
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

- (NSString *)returnValueEmptyText {
  if (self.checkboxes.count > 1) {
    return @"You must check at least one item before continuing.";
  }
  else {
    return [NSString stringWithFormat:@"You must check the item \"%@\" before continuing.", [self.checkboxes[0] title]];
  }
}

@end
