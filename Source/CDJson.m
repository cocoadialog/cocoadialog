#import "CDJson.h"

#pragma mark -
@implementation CDJson

#pragma mark - Public static methods
+ (NSString *) objectToJSON:(id)object {
    NSError *error = nil;
    NSString *json = nil;

    @try {
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        // If no errors, let's view the JSON
        if (data != nil && error == nil) {
            json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        }
    }
    @catch (NSException *exception) {
        json = [self objectToJSON:@{
                                    @"name": [NSString stringWithFormat:@"%@", exception.name],
                                    @"error": exception.reason,
                                    @"info": exception.userInfo ?: [NSNull null],
                                    }];
    }
    return json;
}

+ (NSString *) parseObject:(id)object {
    id value;
    if ([object conformsToProtocol:@protocol(CDJsonProtocol)]) {
        value = [object jsonValue];
        if (![NSJSONSerialization isValidJSONObject:value]) {
            value = [self parseObject:value];
        }
    }
    else {
        value = [object description];
    }
    if ([value isKindOfClass:[NSString class]]) {
        value = [value removeColor];
    }
    return value;
}

@end

#pragma mark -
@implementation NSArray (CDJson)

#pragma mark - Properties
- (id) jsonValue {
    NSMutableArray *array = [NSMutableArray array];
    for (id object in self) {
        [array addObject:[CDJson parseObject:object]];
    }
    return array;
}

- (NSString *) toJSONString {
    return [CDJson objectToJSON:self.jsonValue];
}

@end

#pragma mark -
@implementation NSDictionary (CDJson)

#pragma mark - Properties
- (id) jsonValue {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *name in self) {
        dictionary[name.camelCase] = [CDJson parseObject:self[name]];
    }
    return dictionary;
}

- (NSString *) toJSONString {
    return [CDJson objectToJSON:self.jsonValue];
}

@end
