// NSString+CDString.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSNumber+CDNumber.h"
#import "NSString+CDString.h"
#import "CDLocale.h"

@implementation NSString (CDString)

#pragma mark - Properties
- (BOOL) boolValue {
    return [self isEqualToString:@"1"]
    || [self isEqualToStringCaseInsensitive:@"ON".localized]
    || [self isEqualToStringCaseInsensitive:@"TRUE".localized]
    || [self isEqualToStringCaseInsensitive:@"YES".localized];
}

- (NSString *) camelCase {
    NSMutableString *camelCase = [NSMutableString string];
    NSString *string = [self stringByReplacingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet] withString:@" "];
    NSArray<NSString *> *parts = [string componentsSeparatedByString:@" "];
    for (NSUInteger i = 0; i < parts.count; i++) {
        if (!parts[i].length) {
            continue;
        }
        if (i == 0) {
            [camelCase appendString:[parts[i] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[parts[i] substringToIndex:1].lowercaseString]];
        }
        else {
            [camelCase appendString:[parts[i] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[parts[i] substringToIndex:1].uppercaseString]];
        }
    }
    return camelCase;
}

- (NSData*) data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*) doubleQuote {
    return [NSString stringWithFormat:@"\"%@\"", self];
}

- (NSString*) localized {
    return [CDLocale.sharedInstance localize:self];
}

- (NSString* (^)(id arguments, ...)) arguments {
    return ^NSString* (id arguments, ...) {
        NSMutableArray *array = [NSMutableArray array];
        va_list va_args;
        va_start(va_args, arguments);
        NSString* arg;
        while ((arg = va_arg(va_args, id)) != nil) {
            [array addObject:arg];
        }
        // Prepend the first argument.
        [array insertObject:arguments atIndex:0];
        va_end(va_args);
        return [NSString stringWithFormat:self array:array];
    };
}

-(NSString *) localizedCapitalizedString {
    return self.localized.capitalizedString;
}

- (NSString *) localizedLowercaseString {
    return self.localized.lowercaseString;
}

-(NSString *) localizedUppercaseString {
    return self.localized.uppercaseString;
}

- (NSNumber *) numberValue {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;

    BOOL percent = [self hasSuffix:@"%"];
    NSString* string = percent ? [self substringWithRange:NSMakeRange(0, self.length - 1)] : self;
    NSNumber* number = [formatter numberFromString:string];
    if (number && percent) {
        number = [NSNumber numberWithDouble:number.doubleValue / 100];
    }
    return number ? number.percent(percent) : nil;
}

- (NSString *) optionFormat {
    return [NSMutableString prepend:@"--" toString:self];
}

- (NSString *) singleQuote {
    return [NSString stringWithFormat:@"'%@'", self];
}

- (NSString *) snakeCase {
    return [self stringByReplacingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet] withString:@"_"];
}

#pragma mark - Public static methods
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

#pragma mark - Private static methods
+ (NSMethodSignature *)vaListSignatureForArguments:(NSArray *)arguments {
    NSInteger count = [arguments count];
    NSInteger sizeptr = sizeof(void *);
    NSInteger sumArgInvoke = count + 3; //self + _cmd + (NSString *)format
    NSInteger offsetReturnType = sumArgInvoke * sizeptr;

    NSMutableString *mstring = [NSMutableString string];
    [mstring appendFormat:@"@%zd@0:%zd", offsetReturnType, sizeptr];
    for (NSInteger i = 2; i < sumArgInvoke; i++) {
        [mstring appendFormat:@"@%zd", sizeptr * i];
    }
    return [NSMethodSignature signatureWithObjCTypes:[mstring UTF8String]];
}

#pragma mark - Public instance methods
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

- (NSString *) replacePattern:(NSString *)aPattern withString:(NSString *)aString error:(NSError **)error {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:aPattern options:NSRegularExpressionCaseInsensitive error:error];
    return [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:aString];
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

-(NSArray *)splitOnChar:(char)ch {
    NSMutableArray *results = [NSMutableArray array];
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

- (NSString *) trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) trimTrailing {
    NSUInteger location = 0;
    NSCharacterSet* charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    unichar charBuffer[self.length];
    [self getCharacters:charBuffer];
    int i = 0;
    for (i = (int) self.length; i > 0; i--) {
        if(![charSet characterIsMember:charBuffer[i - 1]]) {
            break;
        }
    }
    return [self substringWithRange:NSMakeRange(location, i - location)];
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

#pragma mark - Public chainable methods
- (NSString *(^)(NSString *string)) append {
    return ^NSString *(NSString *string){
        return [self stringByAppendingString:string];
    };
}

- (NSString *(^)(NSString *string)) prepend {
    return ^NSString *(NSString *string){
        return [string stringByAppendingString:self];
    };
}

- (NSString *(^)(NSUInteger count)) repeat {
    return ^NSString *(NSUInteger count){
        NSString *string = self.copy;
        for (NSUInteger i = 0; i < count; i++) {
            string = string.append(self);
        }
        return string;
    };
}

@end

@implementation NSMutableString (CDString)

#pragma mark - Public static methods
+ (instancetype)prepend:(NSString *)prepend toString:(NSString *)string {
    NSMutableString *joined = [NSMutableString stringWithString:string];
    [joined prepend:prepend];
    return joined;
}

#pragma mark - Public instance methods
- (void)prepend:(NSString *)string {
    [self insertString:string atIndex:0];
}

@end
