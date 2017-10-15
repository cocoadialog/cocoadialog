// CDLocale.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDLocale;

#import "CDTerminal.h"

@interface CDLocale : NSObject

@property (strong, readonly) NSDictionary*  dictionary;
@property (strong, readonly) CDTerminal*    terminal;

+ (instancetype) sharedInstance;
- (NSString *) localize:(NSString *)key;

@end
