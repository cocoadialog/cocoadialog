// CDDropdown.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDDropdown.h"

@implementation CDDropdown

@synthesize dropdownControl;

+ (NSString *)scope {
  return @"dropdown";
}

+ (CDOptions *)availableOptions {
  return [super availableOptions].addOptionsToScope(self.class.scope,
    @[
      CDOption.create(CDString, @"label").deprecates(@[CDOption.create(CDString, @"text")]),
      CDOption.create(CDBoolean, @"exit-onchange"),
      CDOption.create(CDString, @"items").min(2).max(-1).require(YES),
      CDOption.create(CDBoolean, @"pulldown").process((CDOptionProcessBlock) ^(CDControl *control) {
        if (control.options[@"pulldown"].boolValue) {
          control.options[@"buttons"].require(YES);
        }
      }),
      CDOption.create(CDNumber, @"selected"),
    ]);
}

- (void)createControl {
  // Setup the control
  dropdownControl.keyEquivalent = @" ";
  dropdownControl.target = self;
  dropdownControl.action = @selector(selectionChanged:);
  [dropdownControl removeAllItems];

  // Set pulldown style.
  dropdownControl.pullsDown = self.options[@"pulldown"].wasProvided;

  // Populate menu
  NSArray *items = self.options[@"items"].arrayValue;
  if (items != nil && items.count) {
    NSEnumerator *en = [items objectEnumerator];
    id obj;
    while ((obj = [en nextObject])) {
      [dropdownControl addItemWithTitle:(NSString *) obj];
    }
    NSUInteger selected = self.options[@"selected"].wasProvided ? self.options[@"selected"].unsignedIntegerValue : 0;
    [dropdownControl selectItemAtIndex:selected];
  }
}

- (void)controlHasFinished:(NSInteger)button {
  if (self.options[@"return-labels"].wasProvided) {
    self.returnValues[@"value"] = dropdownControl.titleOfSelectedItem;
  }
  else {
    self.returnValues[@"value"] = @(dropdownControl.indexOfSelectedItem);
  }
  [super controlHasFinished:button];
}

- (void)selectionChanged:(id)sender {
  [dropdownControl synchronizeTitleAndSelectedItem];
  if (self.options[@"exit-onchange"].wasProvided) {
    if (self.options[@"return-labels"].wasProvided) {
      self.returnValues[@"value"] = dropdownControl.titleOfSelectedItem;
    }
    else {
      self.returnValues[@"value"] = @(dropdownControl.indexOfSelectedItem);
    }
    [self stopControl];
  }
}


@end
