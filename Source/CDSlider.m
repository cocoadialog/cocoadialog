// CDSlider.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDSlider.h"

@implementation CDSlider

# pragma mark - Properties
- (BOOL)isReturnValueEmpty {
  return (self.slider.value == self.emptyValue);
}

- (NSString *)returnValueEmptyText {
  return [NSString stringWithFormat:@"The value for the slider must be greater than: %i", (int) self.min];
}

# pragma mark - Public static methods
+ (NSString *)scope {
  return @"slider";
}

+ (CDOptions *)availableOptions {
  CDOptions *options = [super availableOptions];

  // Require at least one button.
  options[@"buttons"].require(YES).min(1);

  return options.addOptionsToScope(self.class.scope,
    @[
      CDOption.create(CDBoolean, @"always-show-value"),
      CDOption.create(CDNumber, @"empty-value"),
      CDOption.create(CDNumber, @"max").setDefaultValue(@"100"),
      CDOption.create(CDNumber, @"min").setDefaultValue(@"0"),
      CDOption.create(CDBoolean, @"return-float"),
      CDOption.create(CDNumber, @"ticks").setDefaultValue(@"10"),
      CDOption.create(CDString, @"slider-label").setDefaultValue(@"OPTION_SLIDER_SLIDER_LABEL".localized),
      CDOption.create(CDBoolean, @"sticky"),
      CDOption.create(CDNumber, @"value"),
    ]);
}

# pragma mark - Public instance methods
- (void)controlHasFinished:(NSInteger)button {
  if (self.options[@"return-float"].boolValue) {
    self.returnValues[@"value"] = @((int) (self.slider.value * 100) / 100.0);
  }
  else {
    self.returnValues[@"value"] = @((int) self.slider.value);
  }
  [super controlHasFinished:button];
}

- (void)createControl {
  [super createControl];

  self.min = self.options[@"min"].doubleValue;
  self.max = self.options[@"max"].doubleValue;

  // Determine the current value.
  if (self.options[@"value"].wasProvided) {
    self.value = self.options[@"value"].doubleValue;
    if (self.value < self.min || self.value > self.max) {
      self.terminal.warning(@"The provided value for the option --value cannot be smaller than --min or greater than --max. Using the --min value: %f", self.min, nil);
      self.value = self.min;
    }
  }
  else {
    self.value = self.min;
  }

  // Determine what constitutes an "empty" value.
  if (self.options[@"empty-value"].wasProvided) {
    self.emptyValue = self.options[@"empty-value"].doubleValue;
    if (self.emptyValue < self.min || self.emptyValue > self.max) {

      self.terminal.warning(@"The provided value for the option --empty-value cannot be smaller than --min or greater than --max. Using the --min value: %f", self.min, nil);
    }
  }
  else {
    self.emptyValue = self.min;
  }

  // Determine the number of ticks.
  double defaultTicks = self.max > 5 ? 5 : self.max;
  if (self.options[@"ticks"].wasProvided) {
    self.ticks = self.options[@"ticks"].unsignedIntegerValue;
    if (self.ticks < self.min || self.ticks > self.max) {
      self.terminal.warning(@"The provided value for the option --ticks cannot be smaller than --min or greater than --max. Using the default --ticks value: %f", defaultTicks, nil);
      self.ticks = (NSUInteger) defaultTicks;
    }
  }
  else {
    self.ticks = (NSUInteger) defaultTicks;
  }

  self.slider = [[CDSliderView alloc] initWithDialog:self];
}

@end
