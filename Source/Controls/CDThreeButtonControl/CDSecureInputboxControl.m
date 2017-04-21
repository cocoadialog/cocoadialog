// CDInputboxControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDSecureInputboxControl.h"

@implementation CDSecureInputboxControl

- (instancetype) init {
    self = [super init];
    if (self) {
        option[@"no-show"].value = @YES;
    }
    return self;
}

@end
