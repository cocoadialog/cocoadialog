// NSString+CDString.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSString+CDColor.h"

@interface NSString (CDString)

#pragma mark - Properties
@property (readonly) NSString *camelCase;
@property (readonly) NSData   *data;
@property (readonly) NSString *doubleQuote;
@property (readonly) NSString *optionFormat;
@property (readonly) NSString *singleQuote;

#pragma mark - Public static methods
+ (instancetype)stringWithFormat:(NSString *)format array:(NSArray *)arrayArguments;

#pragma mark - Public instance methods
- (BOOL) contains:(NSString *)string;
- (NSString *) endsWith:(NSString *)string;
- (BOOL) isBlank;
- (BOOL) isEqualToStringCaseInsensitive:(NSString *)string;
- (NSString *) indent:(NSInteger)length;
- (NSString *) indentNewlinesWith:(NSInteger)length;
- (NSString *) replacePattern:(NSString *)aPattern withString:(NSString *)aString error:(NSError **)error;
- (NSArray *) splitOnChar:(char)ch;
- (NSString *) stringByReplacingCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString;
- (NSString *) substringFrom:(NSInteger)from to:(NSInteger)to;
- (NSString *) trim;
- (NSString *) trimTrailing;
- (NSString *) stringByStrippingWhitespace;
- (NSString *) wrapToLength:(NSInteger)length;

@end

@interface NSMutableString (CDString)

#pragma mark - Public static methods
+ (instancetype)prepend:(NSString *)prepend toString:(NSString *)string;

#pragma mark - Public instance methods
- (void)prepend:(NSString *)string;

@end
