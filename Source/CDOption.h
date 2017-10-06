// CDOption.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

// Category extensions.
#import "NSArray+CDArray.h"
#import "NSString+CDString.h"

// Classes.
#import "CDJson.h"
#import "CDTextField.h"

#pragma mark - Type definitions
typedef id (^CDOptionAutomaticDefaultValue)(void);
typedef BOOL (^CDOptionConditionalRequirement)(void);

#pragma mark -
@interface CDOption : NSObject <CDJsonOutputProtocol, CDJsonValueProtocol> {
    BOOL       _isPercent;
}

#pragma mark - Properties
// @todo actually restrict & warn when user provides value that isn't allowed.
@property (nonatomic, retain) NSMutableArray *allowedValues;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSMutableArray* conditionalRequirements;
@property (nonatomic, copy) id defaultValue;
@property (nonatomic, retain) NSString *deprecatedTo;
@property (nonatomic, assign) NSNumber *deprecatedValueIndex;
@property (nonatomic, retain) NSString *helpText;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, retain) NSNumber *maximumValues;
@property (nonatomic, retain) NSNumber *minimumValues;
@property (nonatomic, retain) NSMutableArray<NSString *> *notes;
@property (nonatomic, retain) CDOption *parentOption;
@property (nonatomic, retain) NSMutableArray<NSString *> *warnings;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, retain) id value;
@property (nonatomic, assign) BOOL wasProvided;

#pragma mark - Properties (readonly)
@property (nonatomic, readonly) NSArray* arrayValue;
@property (nonatomic, readonly) BOOL boolValue;
@property (nonatomic, readonly) BOOL hasAutomaticDefaultValue;
@property (nonatomic, readonly) NSString *displayValue;
@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly) float floatValue;
@property (nonatomic, readonly) int intValue;
@property (nonatomic, readonly) NSInteger integerValue;
@property (nonatomic, readonly) BOOL isPercent;
@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSNumber* numberValue;
@property (nonatomic, readonly) NSNumber* percentValue;
@property (nonatomic, readonly) NSMutableArray* providedValues;
@property (nonatomic, readonly) NSString* stringValue;
@property (nonatomic, readonly) CDColor *typeColor;
@property (nonatomic, readonly) NSString *typeLabel;
@property (nonatomic, readonly) unsigned int unsignedIntValue;
@property (nonatomic, readonly) NSUInteger unsignedIntegerValue;

#pragma mark - Public static methods
+ (instancetype) name:(NSString *)name;
+ (instancetype) name:(NSString *)name category:(NSString *) category;
+ (instancetype) name:(NSString *)name replacedBy:(NSString *)replacement;
+ (instancetype) name:(NSString *)name replacedBy:(NSString *)replacement valueIndex:(NSUInteger)valueIndex;

#pragma mark - Public instance methods
- (void) addConditionalRequirement:(CDOptionConditionalRequirement)block;
- (void) overrideValue:(NSString *)value;
- (float) percentageOf:(float)value;
- (void) setValue:(id)value atIndex:(NSInteger)index;
- (void) setValues:(NSArray<NSString *> *)values;

@end

#pragma mark - Single values
@interface CDOptionSingleString : CDOption @end
@interface CDOptionSingleNumber : CDOption @end
@interface CDOptionSingleStringOrNumber : CDOption @end


#pragma mark - Multiple values
@interface CDOptionMultipleStrings : CDOption @end
@interface CDOptionMultipleNumbers : CDOption @end
@interface CDOptionMultipleStringsOrNumbers : CDOption @end

#pragma mark - Boolean
@interface CDOptionBoolean : CDOptionSingleStringOrNumber

#pragma mark - Public static methods
+ (BOOL) boolFromString:(NSString *)string;

@end
