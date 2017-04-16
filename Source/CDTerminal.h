#import <Foundation/Foundation.h>
#import "NSString+CocoaDialog.h"

@interface CDTerminal : NSObject {
    NSFileHandle        *fhErr;
    NSFileHandle        *fhOut;
    NSFileHandle        *fhIn;
    NSMutableDictionary *which;
}

#pragma mark - Properties
@property (nonatomic, readonly) NSUInteger colors;
@property (nonatomic, readonly) NSUInteger cols;
@property (nonatomic, readonly) BOOL supportsColor;

#pragma mark - Public static methods
+ (instancetype) terminal;

#pragma mark - Public instance methods
- (NSUInteger) colsWithMinimum:(NSUInteger)minimum;
- (NSString *) execute:(NSString *)command withArguments:(NSArray *)arguments;
- (void) write:(NSString *)string;
- (void) writeLine:(NSString *)string;
- (void) writeNewLine;
- (void) writeError:(NSString *)string;
- (void) writeErrorLine:(NSString *)string;
- (void) writeErrorNewLine;
- (NSString *) which:(NSString *)command;

@end
