#import "NSString+CocoaDialog.h"

@implementation NSString (CocoaDialog)

- (BOOL) contains:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

- (NSString *) endsWith:(NSString *)string {
    if (self.length > string.length) {
        NSUInteger location = self.length - string.length;
        NSUInteger length = self.length - location;
        NSRange range = NSMakeRange(location, length);
        NSString *substring = [self substringWithRange:range];
        if ([substring isEqualToStringCaseInsensitive:string]) {
            return NSStringFromRange(range);
        }
    }
    else if ([self isEqualToStringCaseInsensitive:string]) {
        return NSStringFromRange(NSMakeRange(0, 1));
    }
    return nil;
}

- (BOOL) isBlank {
    if([[self stringByStrippingWhitespace] isEqualToString:@""])
        return YES;
    return NO;
}

- (BOOL) isEqualToStringCaseInsensitive:(NSString *)string {
    return [self.lowercaseString isEqualToString:string.lowercaseString];
}

- (NSString *) indent:(NSInteger)length {
    NSMutableString *string = [NSMutableString stringWithString:self];
    [string prepend:[@"" stringByPaddingToLength:length withString:@" " startingAtIndex:0]];
    return string;

};

- (NSString *) indentNewlinesWith:(NSInteger)length {
    NSString *indent = [@"" stringByPaddingToLength:length withString:@" " startingAtIndex:0];
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:[@"" stringByAppendingFormat:@"\n%@", indent]];

};

- (NSString *) optionFormat {
    return [NSMutableString prepend:@"--" toString:self];
}

- (NSString *) doubleQuote {
    return [NSString stringWithFormat:@"\"%@\"", self];
}

- (NSString *) singleQuote {
    return [NSString stringWithFormat:@"'%@'", self];
}

- (NSString *) stringByReplacingCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString {
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

- (NSString *) stringByStrippingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// http://stackoverflow.com/a/35039384/1226717
+ (instancetype) stringWithFormat:(NSString *)format array:(NSArray *)arrayArguments {
    NSMethodSignature *methodSignature = [self vaListSignatureForArguments:arrayArguments];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];

    [invocation setTarget:self];
    [invocation setSelector:@selector(stringWithFormat:)];

    [invocation setArgument:&format atIndex:2];
    for (unsigned int i = 0; i < arrayArguments.count; i++) {
        id obj = arrayArguments[i];
        [invocation setArgument:(&obj) atIndex:i+3];
    }

    [invocation invoke];

    __autoreleasing NSString *string;
    [invocation getReturnValue:&string];

    return string;
}
+ (NSMethodSignature *)vaListSignatureForArguments:(NSArray *)arguments {
    NSInteger count = [arguments count];
    NSInteger sizeptr = sizeof(void *);
    NSInteger sumArgInvoke = count + 3; //self + _cmd + (NSString *)format
    NSInteger offsetReturnType = sumArgInvoke * sizeptr;

    NSMutableString *mstring = [[NSMutableString alloc] init];
    [mstring appendFormat:@"@%zd@0:%zd", offsetReturnType, sizeptr];
    for (NSInteger i = 2; i < sumArgInvoke; i++) {
        [mstring appendFormat:@"@%zd", sizeptr * i];
    }
    return [NSMethodSignature signatureWithObjCTypes:[mstring UTF8String]];
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

@implementation NSMutableString (CocoaDialog)

+ (instancetype)prepend:(NSString *)prepend toString:(NSString *)string {
    NSMutableString *joined = [NSMutableString stringWithString:string];
    [joined prepend:prepend];
    return joined;
}

- (void)prepend:(NSString *)string {
    [self insertString:string atIndex:0];
}

@end
