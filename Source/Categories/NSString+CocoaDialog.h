// NSString+CocoaDialog.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSString+CDColor.h"

@interface NSString (CocoaDialog)

#pragma mark - Properties
@property (nonatomic, readonly) NSString *camelCase;
@property (nonatomic, readonly) NSString *doubleQuote;
@property (nonatomic, readonly) NSString *optionFormat;
@property (nonatomic, readonly) NSString *singleQuote;

#pragma mark - Public static methods
+ (instancetype)stringWithFormat:(NSString *)format array:(NSArray *)arrayArguments;

#pragma mark - Public instance methods
- (BOOL) contains:(NSString *)string;
- (NSString *) endsWith:(NSString *)string;
- (BOOL) isBlank;
- (BOOL) isEqualToStringCaseInsensitive:(NSString *)string;
- (NSString *) indent:(NSInteger)length;
- (NSString *) indentNewlinesWith:(NSInteger)length;
- (NSArray *) splitOnChar:(char)ch;
- (NSString *) stringByReplacingCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString;
- (NSString *) substringFrom:(NSInteger)from to:(NSInteger)to;
- (NSString *) stringByStrippingWhitespace;
- (NSString *) wrapToLength:(NSInteger)length;

@end

@interface NSMutableString (CocoaDialog)

#pragma mark - Public static methods
+ (instancetype)prepend:(NSString *)prepend toString:(NSString *)string;

#pragma mark - Public instance methods
- (void)prepend:(NSString *)string;

@end
