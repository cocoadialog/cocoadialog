#import <Foundation/Foundation.h>
#import "NSString+CDColor.h"

@interface NSString (CocoaDialog)

@property (nonatomic, readonly) NSString *optionFormat;
@property (nonatomic, readonly) NSString *doubleQuote;
@property (nonatomic, readonly) NSString *singleQuote;

+ (instancetype)stringWithFormat:(NSString *)format array:(NSArray *)arrayArguments;

-(BOOL)contains:(NSString *)string;
-(BOOL)isBlank;
-(BOOL)isEqualToStringCaseInsensitive:(NSString *)string;
-(NSString *)indent:(NSInteger)length;
-(NSString *)indentNewlinesWith:(NSInteger)length;
-(NSArray *)splitOnChar:(char)ch;
-(NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString;
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
-(NSString *)stringByStrippingWhitespace;
-(NSString *)wrapToLength:(NSInteger)length;

@end

@interface NSMutableString (CocoaDialog)

+ (instancetype)prepend:(NSString *)prepend toString:(NSString *)string;

- (void)prepend:(NSString *)string;

@end
