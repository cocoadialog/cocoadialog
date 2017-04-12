#import <Foundation/Foundation.h>

// Category extensions.
#import "NSString+CDCommon.h"

// Options.
#import "CDOption.h"
#import "CDOptions.h"

@interface CDArguments : NSObject {}

@property (nonatomic, retain, readonly) NSMutableArray *arguments;
@property (nonatomic, retain, readonly) CDOptions *options;
@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOptionDeprecated *> *deprecatedOptions;
@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOption *> *missingOptions;
@property (nonatomic, retain, readonly) NSMutableArray <NSString *> *unknownOptions;

- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) init NS_UNAVAILABLE;

// Pubic static methods.
+ (instancetype) initWithAvailableOptions:(CDOptions *)options;

// Pubic instance methods.
- (NSString *) getArgument:(unsigned int) index;

@end
