#import <Foundation/Foundation.h>

// Category extensions.
#import "NSString+CocoaDialog.h"

// Options.
#import "CDOption.h"
#import "CDOptions.h"

@interface CDArguments : NSObject {}

@property (nonatomic, retain, readonly) NSMutableArray *arguments;
@property (nonatomic, retain, readonly) CDOptions *options;
@property (nonatomic, retain, readonly) NSMutableArray *deprecatedOptions;
@property (nonatomic, retain, readonly) NSMutableArray *unknownOptions;

- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) init NS_UNAVAILABLE;

// Pubic static methods.
+ (instancetype) initWithAvailableOptions:(CDOptions *)options;

// Pubic instance methods.
- (NSString *) getArgument:(unsigned int) index;
- (BOOL) hasOption:(NSString *)key;
- (id) getOption:(NSString *)key;
- (NSArray *) optionAsArray:(NSString *)key;
- (BOOL) optionAsBoolean:(NSString *)key;
- (int) optionAsInt:(NSString *)key;
- (NSNumber *) optionAsNumber:(NSString *)key;
- (NSString *) optionAsString:(NSString *)key;
- (void) setOption:(NSString *)key value:(id)value;

@end
