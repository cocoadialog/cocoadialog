#import <Foundation/Foundation.h>
#import "NSString+CocoaDialog.h"
#import "CDJson.h"
#import "CDOption.h"

@interface CDOptions : NSDictionary <CDJsonProtocol>

#pragma mark - Properties
@property (nonatomic, copy) void (^getOptionCallback)(CDOption *opt);
@property (nonatomic, copy) void (^getOptionOnceCallback)(CDOption *opt);
@property (nonatomic, copy) void (^setOptionCallback)(CDOption *opt, NSString *key);
@property (nonatomic, retain) NSMutableArray <NSString *> *seenOptions;

#pragma mark - Properties (readonly)
@property (nonatomic, copy, readonly) NSArray *allKeys;
@property (nonatomic, copy, readonly) NSArray *allValues;
@property (nonatomic, retain, readonly) NSMutableArray *arguments;
@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOptionDeprecated *> *deprecatedOptions;
@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOption *> *missingOptions;
@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOption *> *options;
@property (nonatomic, retain, readonly) NSDictionary <NSString *, CDOptions *> *groupByCategories;
@property (nonatomic, retain, readonly) NSMutableDictionary <NSString *, CDOption *> *requiredOptions;
@property (nonatomic, retain, readonly) NSMutableArray <NSString *> *unknownOptions;

#pragma mark - Pubic static methods
+ (instancetype) options;

#pragma mark - Pubic instance methods
- (void) addOption:(CDOption *) opt;
- (NSString *) getArgument:(unsigned int) index;
- (CDOptions *) processArguments;

#pragma mark - Enumeration
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len;
- (CDOption *) objectForKey:(NSString *)key;
- (CDOption *) objectForKeyedSubscript:(NSString *)key;
- (void) setObject:(CDOption *)opt forKey:(NSString*)key;
- (void) setObject:(CDOption *)opt forKeyedSubscript:(NSString*)key;

@end
