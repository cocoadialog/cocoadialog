// CDColor.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDColor;

#import <Foundation/Foundation.h>

#ifndef CDColorEscape
#define CDColorEscape "\x1b["
#endif

#ifndef CDColorEscapeRegExp
#define CDColorEscapeRegExp "\\x1b\\["
#endif

typedef NS_ENUM(NSInteger, CDColorBg) {
  CDColorBgNone = -1,
  CDColorBgBlack = 40,
  CDColorBgRed,
  CDColorBgGreen,
  CDColorBgYellow,
  CDColorBgBlue,
  CDColorBgMagenta,
  CDColorBgCyan,
  CDColorBgWhite,
  CDColorBgDefault = 49,
};

typedef NS_ENUM(NSInteger, CDColorFg) {
  CDColorFgNone = -1,
  CDColorFgBlack = 30,
  CDColorFgRed,
  CDColorFgGreen,
  CDColorFgYellow,
  CDColorFgBlue,
  CDColorFgMagenta,
  CDColorFgCyan,
  CDColorFgWhite,
  CDColorFgDefault = 39,
  CDColorFgLightBlack = 90,
  CDColorFgLightRed,
  CDColorFgLightGreen,
  CDColorFgLightYellow,
  CDColorFgLightBlue,
  CDColorFgLightMagenta,
  CDColorFgLightCyan,
  CDColorFgLightWhite,
};

typedef NS_ENUM(NSInteger, CDColorStyle) {
  CDColorStyleNone = -1,
  CDColorStyleDefault = 0,
  CDColorStyleBold = 1,
  CDColorStyleDim = 2,
  CDColorStyleItalic = 3,
  CDColorStyleUnderline = 4,
  CDColorStyleBlink = 5,
  CDColorStyleSwap = 7,
};

@interface CDColor : NSObject

@property(nonatomic) CDColorBg bg;
@property(nonatomic) CDColorFg fg;
@property(readonly) BOOL isApplied;
@property(retain, readonly) NSMutableArray<NSNumber *> *styles;

+ (instancetype)color;
+ (instancetype)fg:(CDColorFg)fg;
+ (instancetype)fg:(CDColorFg)fg bg:(CDColorBg)bg;
+ (instancetype)fg:(CDColorFg)fg bg:(CDColorBg)bg style:(CDColorStyle)style;
+ (instancetype)fg:(CDColorFg)fg bg:(CDColorBg)bg styles:(NSArray<NSNumber *> *)styles;
+ (NSNumber *)style:(CDColorStyle)style;

- (void)addStyle:(CDColorStyle)style;
- (void)addStyles:(NSArray<NSNumber *> *)styles;
- (BOOL)hasStyle:(CDColorStyle)style;
- (BOOL)hasStyles:(NSArray<NSNumber *> *)styles;
- (void)merge:(CDColor *)color;
- (void)removeStyle:(CDColorStyle)style;
- (void)removeStyles:(NSArray<NSNumber *> *)styles;
- (void)removeAllStyles;
- (void)reset;

@end
