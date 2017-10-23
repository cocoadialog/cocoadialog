// CDApp.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.
@class CDApplication;

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

#import "CDClass.h"
#import "CDOptions.h"
#import "CDControlAlias.h"
#import "CDControl.h"
#import "CDTerminal.h"
#import "CDTemplate.h"
#import "NSArray+CDArray.h"
#import "NSPanel+CDPanel.h"
#import "NSString+CDColor.h"
#import "NSString+CDString.h"

@interface CDApplication : NSApplication <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
  NSString *deprecatedFrom;
  NSString *deprecatedTo;
  NSString *removedControl;
  NSString *removedReplacement;
}

- (NSString *)templateDataKey;
- (NSDictionary *)templateDataValue;

@property(strong, readonly) NSString *baseUrl;
@property(strong, readonly) CDControl *control;
@property(strong, readonly) CDControlAlias *controlAlias;
@property(strong, readonly) NSString *name;
@property(strong, readonly) CDOptions *options;
@property(strong, readonly) CDTerminal *terminal;
@property(strong, readonly) NSString *title;
@property(strong, readonly) NSString *version;

+ (NSArray<NSString *> *)availableControls;
+ (NSDictionary<NSString *, NSString *> *)deprecatedControls;
+ (NSDictionary<NSString *, NSString *> *)removedControls;

- (NSArray <CDControlAlias *> *)controlAliases;
- (CDControlAlias *)getControlAliasFor:(NSString *)name;

@end
