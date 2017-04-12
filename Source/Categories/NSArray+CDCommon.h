#import <Foundation/Foundation.h>
#import "NSString+CDCommon.h"

@interface NSArray (CocoaDialog)

@property (nonatomic, readonly) NSArray *sortedAlphabetically;

- (NSArray *) prependStringsWith:(NSString *)prefix;

@end
