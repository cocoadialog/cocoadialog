// CDSlider.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDSlider.h"

@implementation CDSlider

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    // Require at least one button.
    options[@"buttons"].required = YES;
    options[@"buttons"].minimumValues = @1;

    // --always-show-value
    [options add:[CDOptionBoolean             name:@"always-show-value"     category:@"SLIDER_OPTION"]];

    // --empty-value
    [options add:[CDOptionSingleString        name:@"empty-value"           category:@"SLIDER_OPTION"]];

    // --max
    [options add:[CDOptionSingleNumber        name:@"max"                   category:@"SLIDER_OPTION"]];
    options[@"max"].defaultValue = @100;

    // --min
    [options add:[CDOptionSingleNumber        name:@"min"                   category:@"SLIDER_OPTION"]];
    options[@"min"].defaultValue = @0;

    // --return-float
    [options add:[CDOptionBoolean             name:@"return-float"          category:@"SLIDER_OPTION"]];

    // --ticks
    [options add:[CDOptionSingleNumber        name:@"ticks"                 category:@"SLIDER_OPTION"]];

    // --slider-label
    [options add:[CDOptionSingleString        name:@"slider-label"          category:@"SLIDER_OPTION"]];

    // --sticky
    [options add:[CDOptionBoolean             name:@"sticky"                category:@"SLIDER_OPTION"]];

    // --value
    [options add:[CDOptionSingleNumber        name:@"value"                 category:@"SLIDER_OPTION"]];

    return options;
}

- (BOOL)isReturnValueEmpty {
    return (self.slider.value == self.emptyValue);
}

- (NSString *) returnValueEmptyText {
    return [NSString stringWithFormat:@"The value for the slider must be greater than: %i", (int) self.min];
}

- (void) controlHasFinished:(NSUInteger)button {
    if (option[@"return-float"].wasProvided) {
        returnValues[@"value"] = @((int)(self.slider.value * 100) / 100.0);
    }
    else {
        returnValues[@"value"] = [NSNumber numberWithInteger:(int) self.slider.value];
    }
    [super controlHasFinished:button];
}

- (void) initControl {
    [super initControl];

    self.min = option[@"min"].doubleValue;
    self.max = option[@"max"].doubleValue;

    // Determine the current value.
    if (option[@"value"].wasProvided) {
        self.value = option[@"value"].doubleValue;
        if (self.value < self.min || self.value > self.max) {
            [self warning:@"The provided value for the option --value cannot be smaller than --min or greater than --max. Using the --min value: %f", self.min, nil];
            self.value = self.min;
        }
    }
    else {
        self.value = self.min;
    }

    // Determine what constitutes an "empty" value.
    if (option[@"empty-value"].wasProvided) {
        self.emptyValue = option[@"empty-value"].doubleValue;
        if (self.emptyValue < self.min || self.emptyValue > self.max) {
            [self warning:@"The provided value for the option --empty-value cannot be smaller than --min or greater than --max. Using the --min value: %f", self.min, nil];
        }
    }
    else {
        self.emptyValue = self.min;
    }

    // Determine the number of ticks.
    double defaultTicks = self.max > 5 ? 5 : self.max;
    if (option[@"ticks"].wasProvided) {
        self.ticks = option[@"ticks"].unsignedIntegerValue;
        if (self.ticks < self.min || self.ticks > self.max) {
            [self warning:@"The provided value for the option --ticks cannot be smaller than --min or greater than --max. Using the default --ticks value: %f", defaultTicks, nil];
            self.ticks = defaultTicks;
        }
    }
    else {
        self.ticks = defaultTicks;
    }

    self.slider = [[CDSliderView alloc] initWithDialog:self];
}

@end
