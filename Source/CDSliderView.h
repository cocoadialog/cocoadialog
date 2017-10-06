// CDSliderView.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDControlView.h"

#ifndef CDSliderView_h
#define CDSliderView_h

@interface CDSliderView : CDControlView;

@property (nonatomic)               IBInspectable               BOOL                        alwaysShowValue;
@property (nonatomic)               IBInspectable               double                      emptyValue;
@property (strong)       IBOutlet                    NSTextField                 *label;
@property (nonatomic)               IBInspectable               double                      max;
@property (nonatomic)               IBInspectable               double                      min;
@property (strong)       IBOutlet                    NSSlider                    *slider;
@property (strong)       IBOutlet                    NSLayoutConstraint          *sliderBottomConstraint;
@property (strong)       IBOutlet                    NSLayoutConstraint          *sliderTopConstraint;
@property (nonatomic)               IBInspectable               BOOL                        sticky;
@property (nonatomic)               IBInspectable               NSUInteger                  ticks;
@property (strong)       IBOutlet                    NSTextField                 *ticksLabel;
@property (nonatomic)               IBInspectable               double                      value;
@property (strong)       IBOutlet                    NSTextField                 *valueLabel;

- (void) sliderChanged;

@end

@interface CDSliderCell : NSSliderCell

@property (nonatomic)               BOOL            alwaysShowValue;
@property (retain)       id              delegate;
@property (nonatomic)               BOOL            sticky;
@property (nonatomic)               BOOL            tracking;
@property (retain)       NSTextField     *valueLabel;

@end


#endif /* CDSliderView_h */

