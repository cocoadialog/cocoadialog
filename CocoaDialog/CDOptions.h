
@import AppKit;

#define CDOptionsNoValues       0
#define CDOptionsOneValue       1
#define CDOptionsMultipleValues 2

/*! Simple wrapper for commandline options. 
    Easily used with @c[CDOptions getOpts:NSProcessInfo.processInfo.arguments]
 */

@interface CDOptions : NSObject

/// availableKeys should be an `NSString` key, and an `NSNumber` int value using one of the constants defined above.

+ (instancetype) optionsWithDictionary:(NSDictionary*)d;

+ (instancetype) getOpts:(NSArray*)args availableKeys:(NSDictionary*)aks
                                      depreciatedKeys:(NSDictionary*)dks;

+ (void) printOpts:(NSArray*)availableOptions forRunMode:(NSString*)m;

- (BOOL)         hasOpt:(NSString*)key;
- (NSString*)  optValue:(NSString*)key;
- (NSArray*)  optValues:(NSString*)key;
-      optValueOrValues:(NSString*)key;

@property (readonly, copy) NSArray *allOptions, *allOptValues;

- (void) setOption:val forKey:(NSString*)key;

/// Subscript protocol, ie. @code CDOption *opt; id val = opt[@"key"]; opt[@"key"] = val;

- (void) setObject:val forKeyedSubscript:(id<NSCopying>)key;
- objectForKeyedSubscript:(id<NSCopying>)key;

@end
