// CDControlAlias.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDControlAlias.h"

@implementation CDControlAlias

+ (CDControlAlias *(^)(NSString *from, NSString *to))create {
  return ^CDControlAlias *(NSString *from, NSString *to) {
    return [CDControlAlias from:from to:to];
  };
}

+ (instancetype)from:(NSString *)from to:(NSString *)to {
  return [[self alloc] initFrom:from to:to];
}

- (instancetype)initFrom:(NSString *)from to:(NSString *)to {
  self = [super init];
  if (self) {
    _name = from;
    _controlName = to;
  }
  return self;
}

- (CDControlAlias *(^)(CDControlAliasProcessBlock block))process {
  return ^CDControlAlias *(CDControlAliasProcessBlock block) {
    _processBlock = [block copy];
    return self;
  };
}

- (CDControlAlias *(^)(NSString *usage))usage {
  return ^CDControlAlias *(NSString *usage) {
    _usageDescription = usage;
    return self;
  };
}

@end
