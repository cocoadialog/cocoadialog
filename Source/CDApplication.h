// CDApp.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

// Category extensions.
#import "NSArray+CDArray.h"
#import "NSPanel+CDPanel.h"
#import "NSString+CDString.h"

// Controls.
#import "CDControl.h"
#import "CDControl.h"
#import "CDCheckbox.h"
#import "CDFileSelect.h"
#import "CDFileSave.h"
#import "CDInputbox.h"
#import "CDDropdown.h"
#import "CDProgressbar.h"
#import "CDRadio.h"
#import "CDSlider.h"
#import "CDTemplate.h"
#import "CDTextbox.h"

#pragma mark - Constants
#define CDSite "https://mstratman.github.io/cocoadialog/"

#pragma mark -
@interface CDApplication : NSApplication <NSApplicationDelegate, NSUserNotificationCenterDelegate>

#pragma mark - Properties
@property (retain)           CDControl   *control;

#pragma mark - Public static methods
+ (NSString *) appName;
+ (NSString *) appTitle;
+ (NSString *) appVersion;
+ (NSArray<NSString *> *) availableControls;
+ (NSArray <CDControlAlias *> *)controlAliases;
+ (NSDictionary<NSString *, NSString *> *) deprecatedControls;
+ (CDControlAlias *)getControlAliasFor:(NSString *)name;
+ (NSDictionary<NSString *, NSString *> *) removedControls;

#pragma mark - Public instance methods
- (CDControl *) getControl;
@end
