#import <Foundation/Foundation.h>

// Category extensions.
#import "NSString+CocoaDialog.h"

@interface CDOption : NSObject {}

@property (nonatomic, readonly) NSString *category;
@property (nonatomic, readonly) NSString *helpText;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSNumber *type;
@property (nonatomic, assign) id value;

- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) init NS_UNAVAILABLE;
+ (instancetype) name:(NSString *)name;
+ (instancetype) name:(NSString *)name value:(id)value;
+ (instancetype) name:(NSString *)name category:(NSString *) category;
+ (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category;
+ (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category helpText:(NSString *)helpText;

@end


@interface CDOptionDeprecated : CDOption {}

+ (instancetype) from:(NSString *)from to:(NSString *)to;

@property (nonatomic, readonly) NSString *from;
@property (nonatomic, readonly) NSString *to;

@end

@interface CDOptionFlag : CDOption @end

// Single values.
@interface CDOptionSingleString : CDOption @end
@interface CDOptionSingleNumber : CDOption @end
@interface CDOptionSingleStringOrNumber : CDOption @end

// Boolean
@interface CDOptionBoolean : CDOptionSingleStringOrNumber @end

// Multiple values.
@interface CDOptionMultipleStrings : CDOption @end
@interface CDOptionMultipleNumbers : CDOption @end
@interface CDOptionMultipleStringsOrNumbers : CDOption @end
