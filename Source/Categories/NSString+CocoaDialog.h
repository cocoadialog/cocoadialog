#import <Foundation/Foundation.h>
#import "NSString+AnsiColors.h"

@interface NSString (CocoaDialog)

-(BOOL)contains:(NSString *)string;
-(BOOL)isBlank;
-(BOOL)isEqualToStringCaseInsensitive:(NSString *)string;
-(NSString *)indentNewlinesWith:(NSInteger)length;
-(NSArray *)splitOnChar:(char)ch;
-(NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)charSet withString:(NSString *)aString;
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
-(NSString *)stringByStrippingWhitespace;
-(NSString *)wrapToLength:(NSInteger)length;

@end
