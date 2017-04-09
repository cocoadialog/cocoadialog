#import "CDString.h"

@implementation NSString (CocoaDialog)

-(BOOL)contains:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

-(BOOL)isBlank {
    if([[self stringByStrippingWhitespace] isEqualToString:@""])
        return YES;
    return NO;
}

- (BOOL)isEqualToStringCaseInsensitive:(NSString *)string {
    return [self caseInsensitiveCompare:string] == NSOrderedSame;
}

-(NSString *)indentNewlinesWith:(NSInteger)length {
    NSString *indent = [@"" stringByPaddingToLength:length withString:@" " startingAtIndex:0];
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:[@"" stringByAppendingFormat:@"\n%@", indent]];

};

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString {
    NSMutableString *s = [NSMutableString stringWithCapacity:self.length];
    for (NSUInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![charSet characterIsMember:c]) {
            [s appendFormat:@"%C", c];
        } else {
            [s appendString:aString];
        }
    }
    return s;
}

-(NSString *)stringByStrippingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSArray *)splitOnChar:(char)ch {
    NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
    int start = 0;
    for(int i=0; i < (int) [self length]; i++) {

        BOOL isAtSplitChar = [self characterAtIndex:i] == ch;
        BOOL isAtEnd = i == (int) [self length] - 1;

        if(isAtSplitChar || isAtEnd) {
            //take the substring &amp; add it to the array
            NSRange range;
            range.location = start;
            range.length = i - start + 1;

            if(isAtSplitChar)
                range.length -= 1;

            [results addObject:[self substringWithRange:range]];
            start = i + 1;
        }

        //handle the case where the last character was the split char.  we need an empty trailing element in the array.
        if(isAtEnd && isAtSplitChar)
            [results addObject:@""];
    }

    return results;
}

-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to {
    return [[self substringFromIndex:from] substringToIndex:to-from];
}

-(NSString *)wrapToLength:(NSInteger)length {
    NSMutableString *replacement = [NSMutableString string];

    NSArray *lines = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    NSEnumerator *linesEnumerator = lines.objectEnumerator;

    int i = 0;
    NSString *line;
    while ((line = [linesEnumerator nextObject]) != nil) {
        NSArray *words = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        NSEnumerator *wordsEnumerator = words.objectEnumerator;
        NSString *word;
        NSMutableString *currentLine = [NSMutableString string];
        while ((word = [wordsEnumerator nextObject]) != nil) {
            int currentLength = (int) currentLine.length;
            int wordLength = (int) word.length;
            if (currentLength + wordLength > length) {
                [currentLine appendString:@"\n"];
                [replacement appendString:currentLine];
                currentLine = [NSMutableString string];
            }
            [currentLine appendString:word];
            [currentLine appendString:@" "];
        }

        // Append any remaining words.
        [replacement appendString:currentLine];

        // Only append new lines if not the last line being processed.
        if (i < (int) lines.count - 1) {
            [replacement appendString:@"\n"];
        }

        i++;
    }

    return replacement;
}

@end
