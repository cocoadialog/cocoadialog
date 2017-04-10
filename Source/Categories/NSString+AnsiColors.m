#import "NSString+AnsiColors.h"

// Global variable for determining if color should be used.
BOOL NSStringAnsiColors = YES;

#define NSStringAnsiColorsEscape "\x1b["
#define NSStringAnsiColorsEscapeRegExp "\\x1b\\["

@implementation NSString (AnsiColors)

// Private helper method for adding a style to the property array.
- (NSString *) addAnsiStyle:(AnsiStyle)style {
    [self.ansiStyles addObject:[NSNumber numberWithInt:style]];
    return self;
}

- (NSString *) clearAnsiStyles {
    self.ansiStyles = [NSMutableArray array];
    return self;
}

// Storage.
- (void) setAnsiBg:(AnsiBg)ansiBg {
    NSNumber *ansiBgNumber = [NSNumber numberWithInt:ansiBg];
    objc_setAssociatedObject(self, @selector(ansiBg), ansiBgNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AnsiBg) ansiBg {
    NSNumber *ansiBg = objc_getAssociatedObject(self, @selector(ansiBg));
    return ansiBg != nil ? ansiBg.intValue : -1;
}

- (void) setAnsiFg:(AnsiFg)ansiFg {
    NSNumber *ansiFgNumber = [NSNumber numberWithInt:ansiFg];
    objc_setAssociatedObject(self, @selector(ansiFg), ansiFgNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AnsiFg) ansiFg {
    NSNumber *ansiFg = objc_getAssociatedObject(self, @selector(ansiFg));
    return ansiFg != nil ? ansiFg.intValue : -1;
}

- (void) setAnsiStyles:(NSArray *)ansiStyle {
    objc_setAssociatedObject(self, @selector(ansiStyle), ansiStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *) ansiStyles {
    NSMutableArray *ansiStyles = objc_getAssociatedObject(self, @selector(ansiStyle));
    if (ansiStyles == nil) {
        ansiStyles = [NSMutableArray array];
        self.ansiStyles = ansiStyles;
    }
    return ansiStyles;
}

- (void) setAnsiOriginal:(NSString *)ansiOriginal {
    objc_setAssociatedObject(self, @selector(ansiOriginal), ansiOriginal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *) ansiOriginal {
    NSString *original = objc_getAssociatedObject(self, @selector(ansiOriginal));
    if (original != nil) {
        return original;
    }
    return self;
}


// Background colors.
- (NSString *) onBlack      { self.ansiBg = AnsiBgBlack;                return self.applyAnsi; }
- (NSString *) onRed        { self.ansiBg = AnsiBgRed;                  return self.applyAnsi; }
- (NSString *) onGreen      { self.ansiBg = AnsiBgGreen;                return self.applyAnsi; }
- (NSString *) onYellow     { self.ansiBg = AnsiBgYellow;               return self.applyAnsi; }
- (NSString *) onBlue       { self.ansiBg = AnsiBgBlue;                 return self.applyAnsi; }
- (NSString *) onMagenta    { self.ansiBg = AnsiBgMagenta;              return self.applyAnsi; }
- (NSString *) onCyan       { self.ansiBg = AnsiBgCyan;                 return self.applyAnsi; }
- (NSString *) onWhite      { self.ansiBg = AnsiBgWhite;                return self.applyAnsi; }

// Foreground colors.
- (NSString *) black        { self.ansiFg = AnsiFgBlack;                return self.applyAnsi; }
- (NSString *) red          { self.ansiFg = AnsiFgRed;                  return self.applyAnsi; }
- (NSString *) green        { self.ansiFg = AnsiFgGreen;                return self.applyAnsi; }
- (NSString *) yellow       { self.ansiFg = AnsiFgYellow;               return self.applyAnsi; }
- (NSString *) blue         { self.ansiFg = AnsiFgBlue;                 return self.applyAnsi; }
- (NSString *) magenta      { self.ansiFg = AnsiFgMagenta;              return self.applyAnsi; }
- (NSString *) cyan         { self.ansiFg = AnsiFgCyan;                 return self.applyAnsi; }
- (NSString *) white        { self.ansiFg = AnsiFgWhite;                return self.applyAnsi; }
- (NSString *) lightBlack   { self.ansiFg = AnsiFgLightBlack;           return self.applyAnsi; }
- (NSString *) lightRed     { self.ansiFg = AnsiFgLightRed;             return self.applyAnsi; }
- (NSString *) lightGreen   { self.ansiFg = AnsiFgLightGreen;           return self.applyAnsi; }
- (NSString *) lightYellow  { self.ansiFg = AnsiFgLightYellow;          return self.applyAnsi; }
- (NSString *) lightBlue    { self.ansiFg = AnsiFgLightBlue;            return self.applyAnsi; }
- (NSString *) lightMagenta { self.ansiFg = AnsiFgLightMagenta;         return self.applyAnsi; }
- (NSString *) lightCyan    { self.ansiFg = AnsiFgLightCyan;            return self.applyAnsi; }
- (NSString *) lightWhite   { self.ansiFg = AnsiFgLightWhite;           return self.applyAnsi; }

// Styles.
- (NSString *) bold         { [self addAnsiStyle:AnsiStyleBold];        return self.applyAnsi; }
- (NSString *) dim          { [self addAnsiStyle:AnsiStyleDim];         return self.applyAnsi; }
- (NSString *) italic       { [self addAnsiStyle:AnsiStyleItalic];      return self.applyAnsi; }
- (NSString *) underline    { [self addAnsiStyle:AnsiStyleUnderline];   return self.applyAnsi; }
- (NSString *) blink        { [self addAnsiStyle:AnsiStyleBlink];       return self.applyAnsi; }
- (NSString *) swap         { [self addAnsiStyle:AnsiStyleSwap];        return self.applyAnsi; }

// Clearing.
- (NSString *) clearBg      { self.ansiBg = -1;                         return self.applyAnsi; }
- (NSString *) clearFg      { self.ansiFg = -1;                         return self.applyAnsi; }
- (NSString *) clearStyles  { [self clearAnsiStyles];                   return self.applyAnsi; }
- (NSString *) clearAll     {
    self.ansiBg = -1;
    self.ansiFg = -1;
    [self clearAnsiStyles];
    return self.applyAnsi;
}

- (NSString *)removeAnsi {
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:@"%@[^m]+m", @NSStringAnsiColorsEscapeRegExp];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *stripped = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
    return error == nil ? stripped : self;
}

// Stopping.
- (NSString *) stopAnsi {
    if (!NSStringAnsiColors) {
        return self;
    }
    NSMutableString *string = [NSMutableString stringWithString:self];
    [string appendString:[NSString stringWithFormat:@"%@0m", @NSStringAnsiColorsEscape]];
    return string;
}

// Primary method used to wrap the string with ANSI colors.
- (NSMutableString *) applyAnsi {
    if (!NSStringAnsiColors) {
        return [NSMutableString stringWithString:self];
    }

    int bg = self.ansiBg;
    int fg = self.ansiFg;
    NSMutableArray *styles = self.ansiStyles;

    NSMutableString *ansi = [NSMutableString string];
    [ansi appendString:@NSStringAnsiColorsEscape];

    BOOL apply = fg != -1 || bg != -1 || styles.count;

    // Apply.
    if (apply) {
        // Append foreground.
        if (fg != -1) {
            [ansi appendString:[NSString stringWithFormat:@"%i;", fg]];
        }

        // Add background.
        if (bg != -1) {
            [ansi appendString:[NSString stringWithFormat:@"%i;", bg]];
        }

        // Append styles.
        for (unsigned int i = 0; i < styles.count; i++) {
            NSNumber *style = styles[i];
            [ansi appendString:[NSString stringWithFormat:@"%i;", [style intValue]]];
        }

        // Append termination.
        [ansi appendString:@"m"];

        // Append content.
        [ansi appendString:self.ansiOriginal];
    }
    // Reset.
    else {
        [ansi appendString:@NSStringAnsiColorsEscape];
        [ansi appendString:@"0m"];
        [ansi appendString:self.ansiOriginal];
    }

    // Set current values on new string for chainability.
    ansi.ansiOriginal = self;
    ansi.ansiBg = bg;
    ansi.ansiFg = fg;
    ansi.ansiStyles = styles;

    return ansi;
}

-(NSString *)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex ignoreAnsi:(BOOL)ignoreAnsi {
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:@"%@[^m]+m", @NSStringAnsiColorsEscapeRegExp];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    if (ignoreAnsi && matches.count) {
        NSMutableString *stripped = [NSMutableString stringWithString:[self.removeAnsi stringByPaddingToLength:newLength withString:padString startingAtIndex:padIndex]];
        for (unsigned int i = 0; i < matches.count; i++) {
            NSTextCheckingResult *match = matches[i];
            [stripped insertString:[self substringWithRange:match.range] atIndex:match.range.location];
        }
        return stripped;
}
    return [self stringByPaddingToLength:newLength withString:padString startingAtIndex:padIndex];
}


@end
