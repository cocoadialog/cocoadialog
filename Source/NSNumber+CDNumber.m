// NSNumber+CDNumber.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSNumber+CDNumber.h"

@implementation NSNumber (CDNumber)

- (BOOL)isBoolean {
  return strcmp([self objCType], @encode(BOOL)) == 0;
}

- (BOOL)isPercent {
  NSNumber *number = objc_getAssociatedObject(self, @selector(isPercent));
  return number != nil && number.boolValue;
}

- (void)setIsPercent:(BOOL)isPercent {
  NSNumber *number = @(isPercent);
  objc_setAssociatedObject(self, @selector(isPercent), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *(^)(BOOL))percent {
  return ^NSNumber *(BOOL percent) {
    self.isPercent = percent;
    return self;
  };
}

@end
