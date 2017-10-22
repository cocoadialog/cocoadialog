// NSNumber+CDNumber.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface NSNumber (CDNumber)

@property(nonatomic, readonly) BOOL isBoolean;
@property(nonatomic, assign) BOOL isPercent;

- (NSNumber *(^)(BOOL))percent;

@end
