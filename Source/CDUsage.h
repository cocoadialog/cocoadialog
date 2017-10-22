// CDUsage.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDApplication.h"

#import <Foundation/Foundation.h>

@interface CDUsage : NSObject

@property(strong, readonly) CDApplication *app;
@property(strong, readonly) CDTerminal *terminal;
@property(strong, readonly) CDTemplate *template;

+ (instancetype)usage;

- (void)showUsage;

@end
