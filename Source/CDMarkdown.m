// CDMarkdown.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDMarkdown.h"

@implementation CDMarkdown

+ (instancetype) markdown {
    return [[self alloc] init];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _newFontWeights = (&NSFontWeightUltraLight != NULL);
        _hasLinks = NO;
        _enabled = YES;
        _headerFontSizeMultiplier = 1.5;
        _headerFontWeight = _newFontWeights ? NSFontWeightUltraLight : NSFontWeightRegular;
        _minimumHeaderFontSize = 18;
        _parser = [TSMarkdownParser standardParser];
    }
    return self;
}

- (NSAttributedString *) parseString:(NSString *)string {
    // Immediately return if not enabled.
    if (!self.enabled) {
        return [[NSAttributedString alloc] initWithString:string];
    }

    // Parse markdown into attributed text.
    NSMutableAttributedString *value = [[NSMutableAttributedString alloc] initWithAttributedString:[self.parser attributedStringFromMarkdown:string]];
    NSRange range = NSMakeRange(0, value.length);

    // Indicate whether or not there are clickable links.
    [value enumerateAttribute:NSLinkAttributeName inRange:range options:0 usingBlock:^(id  _Nullable link, NSRange aRange, BOOL * _Nonnull stop) {
        self.hasLinks = self.hasLinks || link != nil;
    }];

    // Restore font size.
    [value enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange aRange, BOOL * _Nonnull stop) {
        NSFont *font = [attrs objectForKey:NSFontAttributeName];
        if (!font) {
            return;
        }

        // If font size is greater than 18, make it 32 and thin (header).
        if (font.pointSize >= self.minimumHeaderFontSize) {
            [value removeAttribute:NSFontAttributeName range:aRange];
            font = [NSFont systemFontOfSize:(font.pointSize * self.headerFontSizeMultiplier) weight:self.headerFontWeight];
            [value addAttribute:NSFontAttributeName value:font range:aRange];
            if (self.headerColor) {
                [value removeAttribute:NSForegroundColorAttributeName range:aRange];
                [value addAttribute:NSForegroundColorAttributeName value:self.headerColor range:aRange];
            }
        }
    }];

    return value;
}

@end
