// NSString+CDString.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSString+CDColor.h"

@interface NSString (CDString)

#pragma mark - Properties
@property (readonly) BOOL       boolValue;
@property (readonly) NSString*  camelCase;
@property (readonly) NSData*    data;
@property (readonly) NSString*  doubleQuote;
@property (readonly) NSString*  localized;
@property (readonly) NSNumber*  numberValue;
@property (readonly) NSString*  optionFormat;
@property (readonly) NSString*  singleQuote;
@property (readonly) NSString*  snakeCase;

#pragma mark - Public chainable methods
- (NSString *(^)(id arguments, ...)) arguments;

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

#pragma mark - Public chainable methods
- (NSString *(^)(NSString* string)) append;
- (NSString *(^)(NSString* string)) prepend;
- (NSString *(^)(NSUInteger count)) repeat;

@end

@interface NSMutableString (CDString)

#pragma mark - Public static methods
+ (instancetype)prepend:(NSString *)prepend toString:(NSString *)string;

#pragma mark - Public instance methods
- (void)prepend:(NSString *)string;

@end
