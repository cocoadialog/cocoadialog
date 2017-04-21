// CDSlider.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDThreeButtonControl.h"

@interface CDSlider : CDThreeButtonControl {
    double      emptyValue;
    double      max;
    double      min;
    BOOL        sticky;
    NSUInteger  ticks;
    double      value;
    NSTextField *sliderLabel;
    NSTextField *valueLabel;
}

- (void) sliderChanged;

@end

@interface CDSliderCell : NSSliderCell {
    BOOL        alwaysShowValue;
    id          delegate;
    NSTextField *valueLabel;
    BOOL        tracking;
}
@property BOOL alwaysShowValue;
@property BOOL sticky;
@property (retain) id delegate;
@property (retain) NSTextField *valueLabel;

@end
