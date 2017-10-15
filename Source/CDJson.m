// CDJson.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDJson.h"

#import "NSArray+CDArray.h"
#import "NSString+CDString.h"

#pragma mark -
@implementation CDJson

#pragma mark - Public static methods
+ (NSString *) objectToJSON:(id)object {
    NSError *error = nil;
    NSString *json = nil;

    @try {
        NSUInteger sortKeys = (1UL << 1); // NSJSONWritingSortedKeys in 10.13 sdk;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted | sortKeys error:&error];
        // If no errors, let's view the JSON
        if (data != nil && error == nil) {
            json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            // Remove unnecessary space before colon in key/value pairs.
            json = [json replacePattern:@"(\"[^\"]*\")\\s:\\s" withString:@"$1: " error:nil];

            // Remove extraneous spaces in empty arrays and objects.
            json = [json replacePattern:@"\\[(?:\\s|\n)+\\]" withString:@"[]" error:nil];
            json = [json replacePattern:@"\\{(?:\\s|\n)+\\}" withString:@"{}" error:nil];
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
    id parsed = object;

    // Let objects that specify they have a specific JSON value be invoked.
    if (parsed != nil && [parsed conformsToProtocol:@protocol(CDJsonValueProtocol)]) {
        parsed = [parsed jsonValue];
    }

    // Convert nil values to null.
    if (parsed == nil) {
        parsed = [NSNull null];
    }

    // The [NSJSONSerialization isValidJSONObject:] method cannot be used here because this method may be recursively
    // parsing child properties and thus fall outside the scope of its requirements (non-array and non-dictionary types
    // must be nested within one of those types).
    if (
        ![parsed isKindOfClass:[NSArray class]] &&
        ![parsed isKindOfClass:[NSDictionary class]] &&
        ![parsed isKindOfClass:[NSNumber class]] &&
        ![parsed isKindOfClass:[NSNull class]] &&
        ![parsed isKindOfClass:[NSString class]]
    ) {
        parsed = [parsed description];
    }

    return parsed;
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
    NSArray *sortedKeys = self.allKeys.sortedAlphabetically;
    for (NSString *name in sortedKeys) {
        dictionary[name.camelCase] = [CDJson parseObject:self[name]];
    }
    return dictionary;
}

- (NSString *) toJSONString {
    return [CDJson objectToJSON:self.jsonValue];
}

@end

#pragma mark -
@implementation NSString (CDJson)

#pragma mark - Properties
- (NSString *) jsonValue {
    return self.removeColor;
}

@end
