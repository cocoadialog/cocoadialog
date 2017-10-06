// CDControlAlias.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDControlAlias.h"

#pragma mark -
@implementation CDControlAlias

+ (instancetype) alias:(NSString *)name forControl:(NSString *)controlName helpText:(NSString *)helpText block:(CDControlAliasDefaultOptions)process {
    return [[self alloc] initAlias:name forControl:controlName helpText:helpText block:process];
}

- (instancetype) initAlias:(NSString *)name forControl:(NSString *)controlName helpText:(NSString *)helpText block:(CDControlAliasDefaultOptions)process {
    self = [super init];
    if (self) {
        _name = name;
        _controlName = controlName;
        _helpText = helpText;
        _process = process;
    }
    return self;
}

@end
