// CDControlAlias.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDControlAlias;

#import <Foundation/Foundation.h>

#import "CDControl.h"

typedef void (^CDControlAliasProcessBlock)(CDControl *control);

@interface CDControlAlias : NSObject

@property(strong, readonly) NSString *controlName;
@property(strong, readonly) NSString *name;
@property(strong, readonly) CDControlAliasProcessBlock processBlock;
@property(strong, readonly) NSString *usageDescription;

+ (CDControlAlias *(^)(NSString *from, NSString *to))create;
+ (instancetype)from:(NSString *)from to:(NSString *)to;

- (CDControlAlias *(^)(NSString *usage))usage;
- (CDControlAlias *(^)(CDControlAliasProcessBlock block))process;

@end
