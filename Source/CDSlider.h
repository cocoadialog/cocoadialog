// CDSlider.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDSlider;

#import "CDDialog.h"
#import "CDSliderView.h"

@interface CDSlider : CDDialog

# pragma mark - Properties
@property (nonatomic)               double          emptyValue;
@property (nonatomic)               double          max;
@property (nonatomic)               double          min;
@property (retain)                  CDSliderView    *slider;
@property (nonatomic)               BOOL            sticky;
@property (nonatomic)               NSUInteger      ticks;
@property (nonatomic)               double          value;

@end
