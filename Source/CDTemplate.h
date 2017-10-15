// CDTemplate.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDTemplate;

#import "CDTextField.h"

#import <GRMustache/GRMustache.h>
#import "CDTerminal.h"

@interface CDTemplate : NSObject

#pragma mark - Properties
@property (strong)      id                                                          data;
@property (strong)      GRMustacheTemplateRepository*                               repository;
@property (strong)      NSMutableDictionary <NSString*, GRMustacheTemplate*>*       templates;
@property (strong)      CDTerminal*                                                 terminal;

#pragma mark - Public static methods
+ (instancetype) sharedInstance;

#pragma mark - Public chainable methods
- (NSString *(^)(NSString *name, id data)) render;

#pragma mark - Public instance methods

@end
