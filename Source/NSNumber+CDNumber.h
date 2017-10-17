// NSNumber+CDNumber.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface NSNumber (CDNumber)

#pragma mark - Properties
@property (nonatomic, readonly) BOOL        isBoolean;
@property (nonatomic, assign)   BOOL        isPercent;

#pragma mark - Public chainable methods
- (NSNumber *(^)(BOOL)) percent;

@end
