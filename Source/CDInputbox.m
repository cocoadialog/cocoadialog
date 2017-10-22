// CDInputbox.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDInputbox.h"

@implementation CDInputbox

+ (NSString *)scope {
  return @"input";
}

+ (CDOptions *)availableOptions {
  CDOptions *options = super.availableOptions;

  // Required at least one button.
  options[@"buttons"].require(YES).min(1);

  return options.addOptionsToScope(self.class.scope,
    @[
      CDOption.create(CDBoolean, @"secure").deprecates(@[CDOption.create(CDBoolean, @"no-show")]),
      CDOption.create(CDBoolean, @"selected").deprecates(@[CDOption.create(CDBoolean, @"not-selected")]),
      CDOption.create(CDString, @"value").deprecates(@[CDOption.create(CDString, @"text")]),
    ]);
}

- (BOOL)isReturnValueEmpty {
  return self.input.stringValue.isBlank;
}

- (NSString *)returnValueEmptyText {
  return @"The text field can cannot be empty, please enter some text.";
}

- (void)controlHasFinished:(NSInteger)button {
  self.returnValues[@"value"] = self.input.stringValue;
  [super controlHasFinished:button];
}

- (void)setControl:(id)sender {
  if (self.options[@"secure"].boolValue) {
    self.input = [[NSSecureTextField alloc] init];
  }
  else {
    self.input = [[NSTextField alloc] init];
  }

  self.input.refusesFirstResponder = YES;

  // Set initial text in textfield.
  [self.input setStringValue:self.options[@"value"].stringValue];

  // Select all the text.
  if (self.options[@"selected"].wasProvided || self.options[@"selected"].boolValue) {
    [self.input selectAll:nil];
  }

  // Add the control to the view.
  [self.controlView addSubview:self.input];
}

@end
