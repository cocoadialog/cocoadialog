// CDIcon.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDApplication.h"

@interface CDIcon : NSObject

#pragma mark - Properties

#pragma mark - Readonly Properties
@property (strong, readonly)        CDApplication*                  app;
@property (strong, readonly)        CDTerminal*                     terminal;
@property (strong, readonly)        CDTemplate*                     template;

#pragma mark - Public static methods
+ (instancetype) sharedInstance;

#pragma mark - Public instance methods
- (NSImage *) iconFromFile:(NSString *)file;
- (NSImage *) iconFromName:(NSString *)name;

@end

