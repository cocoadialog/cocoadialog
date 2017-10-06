// CDControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#ifndef CDControl_h
#define CDControl_h

// Categories.
#import "NSArray+CDArray.h"
#import "NSPanel+CDPanel.h"
#import "NSString+CDString.h"

// Classes.
#import "CDControlAlias.h"
@class CDControlAlias;

#import "CDColumns.h"
#import "CDJson.h"
#import "CDOptions.h"
#import "CDOption.h"
#import "CDTerminal.h"
#import "CDTemplate.h"

// Exit codes.
typedef NS_ENUM(int, CDExitCode) {
    CDExitCodeOk = 0,
    CDExitCodeCancel = 1,
    CDExitCodeUnknownControl = 10,
    CDExitCodeControlFailure = 10,
    CDExitCodeInvalidOption = 20,
    CDExitCodeRequiredOption = 21,
    CDExitCodeTimeout = 124,
    CDExitCodeUnknown = 255,
};

#pragma mark -
@protocol CDControlProtocol

- (CDOptions *) availableOptions;
- (void) initControl;
- (void) runControl;
- (void) showUsage;
- (void) stopControl;

@end

#pragma mark -
@interface CDControl : NSObject <CDControlProtocol> {
    // For DX/readability use "option" opposed to "options".
    CDOptions                   *option;

    // Variables
    CDExitCode                  exitStatus;
    NSString                    *name;
    NSMutableArray              *controlItems;
    NSMutableDictionary         *returnValues;
}

#pragma mark - Properties
@property (retain)               CDControlAlias  *alias;
@property (assign)               NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>  *app;
@property (nonatomic, retain)    NSString        *name;
@property (readonly)             BOOL            isBaseControl;
// For DX/readability use "option" opposed to "options".
@property (retain)               CDOptions       *option;
@property (retain)               CDTerminal      *terminal;
@property (readonly)             NSString        *xib;

#pragma mark - Public static methods
+ (instancetype) control;

#pragma mark - Public instance methods
- (NSBundle *) appBundle;
- (NSScreen *) getScreen;
- (instancetype) initWithAlias:(CDControlAlias *)alias seenOptions:(NSArray *)seenOptions NS_DESIGNATED_INITIALIZER;
- (NSString *) loadTemplate:(NSString *)name withData:(id)data;

#pragma mark - Logging
- (void) debug:(NSString *)format, ...      NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) error:(NSString *)format, ...      NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) fatal:(CDExitCode)exitCode error:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3) NS_REQUIRES_NIL_TERMINATION;
- (void) verbose:(NSString *)format, ...    NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) warning:(NSString *)format, ...    NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Icon
- (NSImage *) iconFromFile:(NSString *)file;
- (NSImage *) iconFromName:(NSString *)name;

@end

#endif /* CDControl_h */
