// CDControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDControl, CDControlAlias;

#import <Foundation/Foundation.h>

#import "CDApplication.h"
#import "CDTerminal.h"
#import "CDTemplate.h"

@protocol CDControlProtocol

@property(assign) CDTerminalExitCode exitStatus;
@property(strong) CDOptions *options;
@property(strong) NSMutableDictionary *returnValues;

@property(strong, readonly) CDApplication *app;
@property(strong, readonly) CDControlAlias *alias;
@property(assign, readonly) BOOL isBaseControl;
@property(strong, readonly) NSString *name;
@property(strong, readonly) NSString *nib;
@property(strong, readonly) CDTerminal *terminal;
@property(strong, readonly) CDTemplate *template;
@property(strong, readonly) NSArray *topLevelObjects;

+ (CDOptions *)availableOptions;
+ (instancetype)initWithName:(NSString *)aName alias:(CDControlAlias *)anAlias;
+ (NSString *)scope;

- (void)createControl;
- (NSScreen *)getScreen;
- (void)runControl;
- (void)stopControl;

@end

@interface CDControl : NSObject <CDControlProtocol>

@end
