//
//  CDSlider.h
//  CocoaDialog
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
}

- (void) updateLabel;

@end
