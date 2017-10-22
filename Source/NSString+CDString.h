// NSString+CDString.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <Foundation/Foundation.h>

#import "NSString+CDColor.h"

@interface NSString (CDString)

@property(readonly) BOOL boolValue;
@property(readonly) NSString *camelCase;
@property(readonly) NSData *data;
@property(readonly) NSString *doubleQuote;
@property(readonly) NSString *localized;
@property(readonly) NSNumber *numberValue;
@property(readonly) NSString *optionFormat;
@property(readonly) NSString *singleQuote;
@property(readonly) NSString *snakeCase;

- (NSString *(^)(id arguments, ...))arguments;

+ (instancetype)stringWithFormat:(NSString *)format array:(NSArray *)arrayArguments;

- (BOOL)contains:(NSString *)string;
- (NSString *)endsWith:(NSString *)string;
- (BOOL)isBlank;
- (BOOL)isEqualToStringCaseInsensitive:(NSString *)string;
- (NSString *)indent:(NSUInteger)length;
- (NSString *)indentNewlinesWith:(NSUInteger)length;
- (NSString *)replacePattern:(NSString *)aPattern withString:(NSString *)aString error:(NSError **)error;
- (NSArray *)splitOnChar:(char)ch;
- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString;
- (NSString *)substringFrom:(NSUInteger)from to:(NSUInteger)to;
- (NSString *)trim;
- (NSString *)trimTrailing;
- (NSString *)stringByStrippingWhitespace;
- (NSString *)wrapToLength:(NSUInteger)length;

- (NSString *(^)(NSString *string))append;
- (NSString *(^)(NSString *string))prepend;
- (NSString *(^)(NSUInteger count))repeat;

@end

@interface NSMutableString (CDString)

+ (instancetype)prepend:(NSString *)prepend toString:(NSString *)string;

- (void)prepend:(NSString *)string;

@end
