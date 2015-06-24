//
//  CDSlider.h
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/31/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDThreeButtonControl.h"

@interface CDSlider : CDThreeButtonControl {
    double      emptyValue;
    double      max;
    double      min;
    int         ticks;
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
@property (strong) id delegate;
@property (strong) NSTextField *valueLabel;

@end
