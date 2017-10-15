// CDControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDControl, CDControlAlias;

#import "CDApplication.h"
#import "CDTerminal.h"
#import "CDTemplate.h"

#pragma mark -
@protocol CDControlProtocol

#pragma mark - Properties
@property (assign)                  CDTerminalExitCode              exitStatus;
@property (strong)                  CDOptions*                      options;
@property (strong)                  NSMutableDictionary*            returnValues;

#pragma mark - Readonly Properties
@property (strong, readonly)        CDApplication*                  app;
@property (strong, readonly)        CDControlAlias*                 alias;
@property (assign, readonly)        BOOL                            isBaseControl;
@property (strong, readonly)        NSString*                       name;
@property (strong, readonly)        NSString*                       nib;
@property (strong, readonly)        CDTerminal*                     terminal;
@property (strong, readonly)        CDTemplate*                     template;
@property (strong, readonly)        NSArray*                        topLevelObjects;

#pragma mark - Public static methods
+ (CDOptions *) availableOptions;
+ (instancetype) control;
+ (NSString *) scope;

#pragma mark - Public instance methods
- (void) createControl;
- (NSScreen *) getScreen;
- (instancetype) initWithName:(NSString*)aName alias:(CDControlAlias *)anAlias;
- (void) runControl;
- (void) stopControl;

@end

@interface CDControl : NSObject <CDControlProtocol>

@end
