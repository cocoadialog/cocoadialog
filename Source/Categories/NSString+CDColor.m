// NSString+CDColor.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSString+CDColor.h"

// Global variable for determining if color should be used.
BOOL NSStringCDColor = YES;

@implementation NSString (CDColor)

#pragma mark - Storage
- (void) setColor:(CDColor *)color {
    objc_setAssociatedObject(self, @selector(color), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CDColor *) color {
    CDColor *color = objc_getAssociatedObject(self, @selector(color));
    if (color == nil) {
        color = [[[CDColor alloc] init] autorelease];
        self.color = color;
    }
    return color;
}

- (void) setOriginalString:(NSString *)originalString {
    objc_setAssociatedObject(self, @selector(originalString), originalString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *) originalString {
    return objc_getAssociatedObject(self, @selector(originalString));
}

#pragma mark - Background colors
- (NSString *) onBlack      { self.color.bg = CDColorBgBlack;                   return self.formattedString; }
- (NSString *) onRed        { self.color.bg = CDColorBgRed;                     return self.formattedString; }
- (NSString *) onGreen      { self.color.bg = CDColorBgGreen;                   return self.formattedString; }
- (NSString *) onYellow     { self.color.bg = CDColorBgYellow;                  return self.formattedString; }
- (NSString *) onBlue       { self.color.bg = CDColorBgBlue;                    return self.formattedString; }
- (NSString *) onMagenta    { self.color.bg = CDColorBgMagenta;                 return self.formattedString; }
- (NSString *) onCyan       { self.color.bg = CDColorBgCyan;                    return self.formattedString; }
- (NSString *) onWhite      { self.color.bg = CDColorBgWhite;                   return self.formattedString; }

#pragma mark - Foreground colors
- (NSString *) black        { self.color.fg = CDColorFgBlack;                   return self.formattedString; }
- (NSString *) red          { self.color.fg = CDColorFgRed;                     return self.formattedString; }
- (NSString *) green        { self.color.fg = CDColorFgGreen;                   return self.formattedString; }
- (NSString *) yellow       { self.color.fg = CDColorFgYellow;                  return self.formattedString; }
- (NSString *) blue         { self.color.fg = CDColorFgBlue;                    return self.formattedString; }
- (NSString *) magenta      { self.color.fg = CDColorFgMagenta;                 return self.formattedString; }
- (NSString *) cyan         { self.color.fg = CDColorFgCyan;                    return self.formattedString; }
- (NSString *) white        { self.color.fg = CDColorFgWhite;                   return self.formattedString; }
- (NSString *) lightBlack   { self.color.fg = CDColorFgLightBlack;              return self.formattedString; }
- (NSString *) lightRed     { self.color.fg = CDColorFgLightRed;                return self.formattedString; }
- (NSString *) lightGreen   { self.color.fg = CDColorFgLightGreen;              return self.formattedString; }
- (NSString *) lightYellow  { self.color.fg = CDColorFgLightYellow;             return self.formattedString; }
- (NSString *) lightBlue    { self.color.fg = CDColorFgLightBlue;               return self.formattedString; }
- (NSString *) lightMagenta { self.color.fg = CDColorFgLightMagenta;            return self.formattedString; }
- (NSString *) lightCyan    { self.color.fg = CDColorFgLightCyan;               return self.formattedString; }
- (NSString *) lightWhite   { self.color.fg = CDColorFgLightWhite;              return self.formattedString; }

#pragma mark - Styles
- (NSString *) bold         { [self.color addStyle:CDColorStyleBold];           return self.formattedString; }
- (NSString *) dim          { [self.color addStyle:CDColorStyleDim];            return self.formattedString; }
- (NSString *) italic       { [self.color addStyle:CDColorStyleItalic];         return self.formattedString; }
- (NSString *) underline    { [self.color addStyle:CDColorStyleUnderline];      return self.formattedString; }
- (NSString *) blink        { [self.color addStyle:CDColorStyleBlink];          return self.formattedString; }
- (NSString *) swap         { [self.color addStyle:CDColorStyleSwap];           return self.formattedString; }

#pragma mark - Clearing
- (NSString *) clearBg      { self.color.bg = CDColorBgNone;                    return self.formattedString; }
- (NSString *) clearFg      { self.color.fg = CDColorFgNone;                    return self.formattedString; }
- (NSString *) clearStyles  { [self.color removeAllStyles];                     return self.formattedString; }
- (NSString *) clearAll     { [self.color reset];                               return self.formattedString; }

- (NSString *)removeColor {
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:@"%@[^m]+m", @CDColorEscapeRegExp];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *stripped = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
    return error == nil ? stripped : self;
}

#pragma mark - Stopping
- (NSString *) stop {
    if (!NSStringCDColor) {
        return self;
    }
    NSMutableString *string = [NSMutableString stringWithString:self];
    [string appendString:[NSString stringWithFormat:@"%@0m", @CDColorEscape]];
    return string;
}

#pragma mark - Private instance methods
- (CDColor *) colorAncestry {
    CDColor *color = [CDColor color];
    if (self.originalString) {
        color.fg = self.originalString.colorAncestry.fg;
        color.bg = self.originalString.colorAncestry.bg;
        [color addStyles:self.originalString.colorAncestry.styles];
    }
    color.fg = self.color.fg;
    color.bg = self.color.bg;
    [color addStyles:self.color.styles];
    return color;
}

- (NSMutableString *) formattedString {
    if (!NSStringCDColor) {
        return [NSMutableString stringWithString:self];
    }

    NSMutableString *formattedString = [NSMutableString string];
    [formattedString appendString:@CDColorEscape];

    CDColor *color = self.colorAncestry;

    // Apply.
    if (color.isApplied) {
        // Append foreground.
        if (color.fg != CDColorFgNone) {
            [formattedString appendString:[NSString stringWithFormat:@"%i;", color.fg]];
        }

        // Add background.
        if (color.bg != CDColorBgNone) {
            [formattedString appendString:[NSString stringWithFormat:@"%i;", color.bg]];
        }

        // Append styles.
        for (unsigned int i = 0; i < color.styles.count; i++) {
            NSNumber *style = color.styles[i];
            [formattedString appendString:[NSString stringWithFormat:@"%i;", [style intValue]]];
        }

        // Append termination.
        [formattedString appendString:@"m"];

        // Append content.
        [formattedString appendString:self.originalString ?: self];
    }
    // Reset.
    else {
        [formattedString appendString:@CDColorEscape];
        [formattedString appendString:@"0m"];
        [formattedString appendString:self.originalString];
    }

    // Set current values on new string for chainability.
    formattedString.originalString = self;
    formattedString.color = color;

    return formattedString;
}

#pragma mark - Public instance methods
- (NSString *) applyColor:(CDColor *)color {
    [self.color merge:color];
    return self.formattedString;
}

- (NSString *) stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex ignoreColor:(BOOL)ignoreColor {
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:@"%@[^m]+m", @CDColorEscapeRegExp];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    if (ignoreColor && matches.count) {
        NSMutableString *stripped = [NSMutableString stringWithString:[self.removeColor stringByPaddingToLength:newLength withString:padString startingAtIndex:padIndex]];
        for (unsigned int i = 0; i < matches.count; i++) {
            NSTextCheckingResult *match = matches[i];
            [stripped insertString:[self substringWithRange:match.range] atIndex:match.range.location];
        }
        return stripped;
}
    return [self stringByPaddingToLength:newLength withString:padString startingAtIndex:padIndex];
}


@end
