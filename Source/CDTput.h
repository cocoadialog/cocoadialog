#import <Foundation/Foundation.h>
#import "NSString+CDCommon.h"

@interface CDTput : NSObject

+ (int) colors;
+ (int) cols;
+ (int) colsWithMinimum:(int)minimum;
+ (BOOL) supportsColor;

@end
