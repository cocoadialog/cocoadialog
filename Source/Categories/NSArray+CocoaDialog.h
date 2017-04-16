#import <Foundation/Foundation.h>
#import "NSString+CocoaDialog.h"

@interface NSArray (CocoaDialog)

#pragma mark - Properties
@property (nonatomic, readonly) NSArray *sortedAlphabetically;

#pragma mark - Public instance methods
- (NSArray *) prependStringsWith:(NSString *)prefix;

@end
