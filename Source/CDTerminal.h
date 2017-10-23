// CDTerminal.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDTerminal;

#import <Foundation/Foundation.h>

@interface CDTerminal : NSObject

typedef CDTerminal *(^CDTerminalFormatBlock)(NSString *format, ...); //NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION

// Exit codes.
typedef NS_ENUM(NSUInteger, CDTerminalExitCode) {
  // Standard.
    CDTerminalExitCodeOk = 0,
  CDTerminalExitCodeCancel = 1,
  CDTerminalExitCodeTimeout = 124,
  CDTerminalExitCodeInternal = 254,
  CDTerminalExitCodeUnknown = 255,

  // Template.
    CDTerminalExitCodeTemplateLoadFailure = 20,
  CDTerminalExitCodeTemplateRenderFailure = 21,

  // Control.
    CDTerminalExitCodeControlUnknown = 31,
  CDTerminalExitCodeControlFailure = 32,

  // Options
    CDTerminalExitCodeOptionInvalid = 51,
  CDTerminalExitCodeOptionRequired = 52,

};

typedef NS_OPTIONS(NSUInteger, CDTerminalLogLevel) {
  CDTerminalLogLevelNone = 0,
  CDTerminalLogLevelError = (1 << 0),
  CDTerminalLogLevelWarning = (1 << 1),
  CDTerminalLogLevelDebug = (1 << 2),
  CDTerminalLogLevelVerbose = (1 << 3),
  CDTerminalLogLevelDev = (1 << 4),
};

@property(strong) NSMutableArray *arguments;
@property(assign) CDTerminalLogLevel logLevel;

@property(readonly) NSUInteger colors;
@property(readonly) NSUInteger cols;
@property(readonly) NSDictionary <NSString *, NSString *> *environment;
@property(readonly) BOOL isCLI;
@property(readonly) BOOL supportsColor;
@property(readonly) NSFileHandle *fhErr;
@property(readonly) NSFileHandle *fhOut;
@property(readonly) NSFileHandle *fhIn;
@property(readonly) NSMutableDictionary *which;

+ (instancetype)sharedInstance;

- (NSUInteger)colsWithMinimum:(NSUInteger)minimum;
- (NSString *)execute:(NSString *)command withArguments:(NSArray *)arguments;
- (void)write:(NSString *)string;
- (void)writeLine:(NSString *)string;
- (void)writeNewLine;
- (void)writeError:(NSString *)string;
- (void)writeErrorLine:(NSString *)string;
- (void)writeErrorNewLine;
- (NSString *)which:(NSString *)command;

- (CDTerminalFormatBlock)debug;
- (CDTerminalFormatBlock)dev;
- (CDTerminalFormatBlock)error;
- (void *(^)(CDTerminalExitCode))exit;
- (CDTerminal *(^)(CDTerminalLogLevel))setLogLevel;
- (CDTerminalFormatBlock)verbose;
- (CDTerminalFormatBlock)warning;

@end
