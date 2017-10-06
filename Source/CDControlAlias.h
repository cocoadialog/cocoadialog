// CDControlAlias.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#ifndef CDControlAlias_h
#define CDControlAlias_h

#import "CDControl.h"
#import "CDOptions.h"

@class CDOptions;
@class CDControl;

typedef void (^CDControlAliasDefaultOptions)(CDOptions *options, CDControl *control);

#pragma mark -
@interface CDControlAlias : NSObject

@property (strong, readonly)      NSString                          *controlName;
@property (strong, readonly)      NSString                          *helpText;
@property (strong, readonly)      NSString                          *name;
@property (strong, readonly)      CDControlAliasDefaultOptions      process;

+ (instancetype) alias:(NSString *)name forControl:(NSString *)controlName helpText:(NSString *)options block:(CDControlAliasDefaultOptions)process;

@end

#endif /* CDControlAlias_h */
