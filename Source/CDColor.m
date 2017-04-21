// CDColor.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDColor.h"

@implementation CDColor

#pragma mark - Public static methods
+ (instancetype) color {
    return [[[self alloc] init] autorelease];
}

+ (instancetype) fg:(CDColorFg)fg {
    return [self fg:fg bg:CDColorBgNone styles:@[]];
}

+ (instancetype) fg:(CDColorFg)fg bg:(CDColorBg)bg {
    return [self fg:fg bg:bg styles:@[]];
}

+ (instancetype) fg:(CDColorFg)fg bg:(CDColorBg)bg style:(CDColorStyle)style {
    return [self fg:fg bg:bg styles:@[[CDColor style:style]]];
}

+ (instancetype) fg:(CDColorFg)fg bg:(CDColorBg)bg styles:(NSArray<NSNumber *> *)styles {
    CDColor *instance = [[[self alloc] init] autorelease];
    if (instance) {
        instance.fg = fg;
        instance.bg = bg;
        [instance addStyles:styles];
    }
    return instance;
}

+ (NSNumber *) style:(CDColorStyle)style {
    return [NSNumber numberWithInt:style];
}

#pragma mark - Properties
- (BOOL) isApplied {
    return _fg != CDColorFgNone || _bg != CDColorBgNone || _styles.count;
}

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void) dealloc {
    [_styles release];
    [super dealloc];
}

- (void) addStyle:(CDColorStyle)style {
    if (style != CDColorStyleNone && ![self hasStyle:style]) {
        [_styles addObject:[NSNumber numberWithInt:style]];
    }
}

- (void) addStyles:(NSArray<NSNumber *> *)styles {
    for (unsigned int i = 0; i < styles.count; i++) {
        CDColorStyle style = [styles[i] intValue];
        [self addStyle: style];
    }
}

- (BOOL) hasStyle:(CDColorStyle)style {
    for (unsigned int i = 0; i < _styles.count; i++) {
        if (style == [_styles[i] intValue]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) hasStyles:(NSArray<NSNumber *> *)styles {
    BOOL hasStyles = YES;
    for (unsigned int i = 0; i < styles.count; i++) {
        CDColorStyle style = [styles[i] intValue];
        if (![self hasStyle: style]) {
            hasStyles = NO;
            break;
        }
    }
    return hasStyles;
}

- (void)merge:(CDColor *)color {
    _fg = color.fg;
    _bg = color.bg;
    [self addStyles:color.styles];
}

- (void) removeStyle:(CDColorStyle)style {
    int index = -1;
    for (unsigned int i = 0; i < _styles.count; i++) {
        if (style == [_styles[i] intValue]) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        [_styles removeObjectAtIndex:index];
    }
}

- (void) removeStyles:(NSArray<NSNumber *> *)styles {
    for (unsigned int i = 0; i < styles.count; i++) {
        CDColorStyle style = [styles[i] intValue];
        [self removeStyle: style];
    }
}

- (void)removeAllStyles {
    _styles = [NSMutableArray array];
}

- (void) reset {
    _fg = CDColorFgNone;
    _bg = CDColorBgNone;
    _styles = [NSMutableArray array];
}

@end
