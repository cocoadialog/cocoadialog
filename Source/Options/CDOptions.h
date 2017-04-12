#import <Foundation/Foundation.h>

// Category extensions.
#import "NSString+CDCommon.h"

#import "CDOption.h"

@interface CDOptions : NSObject {}

@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOption *> *options;
@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOptionDeprecated *> *deprecatedOptions;
@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOption *> *requiredOptions;

+ (instancetype) options;
- (void) addOption:(CDOption *) option;

- (CDOption *) objectForKeyedSubscript:(NSString *)key;
- (void) setObject:(CDOption *)option forKeyedSubscript:(NSString*)key;

@end
