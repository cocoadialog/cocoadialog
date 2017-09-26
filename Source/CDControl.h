// CDControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

// Categories.
#import "NSArray+CocoaDialog.h"
#import "NSString+CocoaDialog.h"

// Classes.
#import "CDColumns.h"
#import "CDJson.h"
#import "CDOptions.h"
#import "CDOption.h"
#import "CDTerminal.h"

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

@protocol CDControlProtocol <NSWindowDelegate>

- (CDOptions *) availableOptions;
- (void) createControl;
- (void) loadControlNib;
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
    NSString                    *controlName;
    NSMutableArray              *controlItems;
    NSMutableDictionary         *returnValues;

    // Timer
    NSThread                    *mainThread;
    NSTimer                     *timer;
    NSThread                    *timerThread;
    double                      timeout;
}

#pragma mark - Properties
@property (nonatomic, assign)               NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>  *app;
@property (nonatomic, retain)               NSString        *controlName;
@property (nonatomic, readonly)             NSString        *controlNib;
@property (nonatomic, readonly)             BOOL            isBaseControl;
// For DX/readability use "option" opposed to "options".
@property (nonatomic, retain)               CDOptions       *option;
@property (nonatomic, retain)               CDTerminal      *terminal;

#pragma mark - Public static methods
+ (instancetype) control;

#pragma mark - Public instance methods
- (NSBundle *) appBundle;
- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds;
- (instancetype) initWithSeenOptions:(NSMutableArray *)seenOptions NS_DESIGNATED_INITIALIZER;

#pragma mark - Icon
@property (nonatomic, readonly)             NSImage         *icon;
@property (nonatomic, readonly)             NSMutableArray  *iconControls;
@property (nonatomic, readonly)             NSData          *iconData;
@property (nonatomic, readonly)             NSData          *iconDataWithDefault;
@property (nonatomic, readonly)             NSImage         *iconImage;
@property (nonatomic, readonly)             NSImage         *iconWithDefault;
@property (nonatomic, retain)   IBOutlet    NSImageView     *iconView;

- (void) iconAffectedByControl:(id)control;
- (NSImage *) iconFromFile:(NSString *)file;
- (NSImage *) iconFromName:(NSString *)name;
- (void) setIconFromOptions;

#pragma mark - Logging
- (void) debug:(NSString *)format, ...      NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) error:(NSString *)format, ...      NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) fatal:(CDExitCode)exitCode error:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3) NS_REQUIRES_NIL_TERMINATION;
- (void) verbose:(NSString *)format, ...    NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) warning:(NSString *)format, ...    NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Panel
@property (nonatomic, readonly)             NSSize          findNewSize;
@property (nonatomic, readonly)             NSScreen        *getScreen;
@property (nonatomic, readonly)             BOOL            needsResize;
@property (nonatomic, retain)   IBOutlet    NSPanel         *panel;

- (void) addMinHeight:(CGFloat)height;
- (void) addMinWidth:(CGFloat)width;
- (void) resize;
- (void) setFloat;
- (void) setPanelEmpty;
- (void) setPosition;
- (void) setTitle;
- (void) setTitle:(NSString *)string;

#pragma mark - Timer
@property (nonatomic, retain)   IBOutlet    NSTextField     *timeoutLabel;

- (void) createTimer;
- (void) processTimer;
- (void) setTimeout;
- (void) setTimeoutLabel;

@end
