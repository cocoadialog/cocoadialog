// CDProgressbarView.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDProgressbarView.h"

@implementation CDProgressbarView

- (void) setLabels:(NSArray <NSString *> *)labels {
    _labels = labels;
//    NSString *primaryLabel = labels[0] ?: nil;
//    NSString *secondaryLabel = labels[0] ?: nil;
//
}

- (void) setIndeterminate:(BOOL)indeterminate {
    _indeterminate = indeterminate;
    [self.progressbar setIndeterminate:indeterminate];
    if (indeterminate) {
        [self.progressbar startAnimation:self];
    }
    else {
        [self.progressbar stopAnimation:self];
    }
}

@end
