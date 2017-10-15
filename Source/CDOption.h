// CDOption.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDOption;

// Classes.
#import "CDColor.h"
#import "CDJson.h"
#import "CDControl.h"

#pragma mark - Type definitions
typedef id (^CDOptionAutomaticValueBlock)(void);
typedef void (^CDOptionProcessBlock)(CDControl *control);

typedef NS_ENUM(NSUInteger, CDOptionValueType) {
    CDString = 0,
    CDNumber,
    CDStringOrNumber,
    CDBoolean,
};

#pragma mark -
@interface CDOption : NSObject <CDJsonOutputProtocol, CDJsonValueProtocol>

#pragma mark - Properties
// @todo actually restrict & warn when user provides value that isn't allowed.
@property (nonatomic, strong)   NSString*                                   deprecatedTo;
@property (nonatomic, strong)   NSNumber*                                   deprecatedValueIndex;
@property (nonatomic, assign)   BOOL                                        hidden;
@property (nonatomic, strong)   NSNumber*                                   maximumValues;
@property (nonatomic, strong)   NSNumber*                                   minimumValues;
@property (nonatomic, strong)   NSString*                                   parent;
@property (nonatomic, strong)   CDOption*                                   parentOption;
@property (nonatomic, assign)   BOOL                                        required;
@property (nonatomic, assign)   BOOL                                        wasProvided;
@property (nonatomic, strong)   NSMutableArray*                             values;

#pragma mark - Properties (readonly)
@property (nonatomic, readonly) NSMutableArray*                             allowedValues;
@property (nonatomic, readonly) NSArray*                                    arrayValue;
@property (nonatomic, readonly) NSArray<NSNumber*>*                         arrayOfNumbers;
@property (nonatomic, readonly) NSArray<NSString*>*                         arrayOfStrings;
@property (nonatomic, readonly) NSArray*                                    arrayOfStringOrNumbers;
@property (nonatomic, readonly) BOOL                                        boolValue;
@property (copy, readonly)      id                                          defaultValue;
@property (nonatomic, readonly) NSMutableArray <CDOption*>*                 deprecatedOptions;
@property (nonatomic, readonly) NSString*                                   displayValue;
@property (nonatomic, readonly) double                                      doubleValue;
@property (nonatomic, readonly) float                                       floatValue;
@property (nonatomic, readonly) BOOL                                        hasAutomaticDefaultValue;
@property (nonatomic, readonly) int                                         intValue;
@property (nonatomic, readonly) NSInteger                                   integerValue;
@property (nonatomic, readonly) BOOL                                        isPercent;
@property (nonatomic, readonly) NSString*                                   label;
@property (nonatomic, readonly) NSString*                                   name;
@property (nonatomic, readonly) NSMutableArray<NSString*>*                  notes;
@property (nonatomic, readonly) NSNumber*                                   numberValue;
@property (nonatomic, readonly) NSNumber*                                   percentValue;
@property (nonatomic, readonly) NSMutableArray <CDOptionProcessBlock>*      processBlocks;
@property (nonatomic, readonly) NSString*                                   scope;
@property (nonatomic, readonly) NSString*                                   stringValue;
@property (nonatomic, readonly) CDColor*                                    typeColor;
@property (nonatomic, readonly) NSString*                                   typeLabel;
@property (nonatomic, readonly) unsigned int                                unsignedIntValue;
@property (nonatomic, readonly) NSUInteger                                  unsignedIntegerValue;
@property (nonatomic, readonly) CDOptionValueType                           valueType;
@property (nonatomic, readonly) NSMutableArray<NSString*>*                  warnings;

#pragma mark - Public static methods
+ (instancetype) type:(CDOptionValueType)type name:(NSString *)name;
+ (CDOption *(^)(CDOptionValueType type, NSString* name)) create;

#pragma mark - Public instance methods
- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithType:(CDOptionValueType)type name:(NSString *)name NS_DESIGNATED_INITIALIZER;
- (float) percentageOf:(float)value;
- (void) setValue:(id)value atIndex:(NSUInteger)index;

#pragma mark - Public chainable methods
- (CDOption *(^)(NSString*)) addNote;
- (CDOption *(^)(NSString*)) addWarning;
- (CDOption *(^)(NSArray*)) allow;
- (CDOption *(^)(NSString*)) dependsOn;
- (CDOption *(^)(NSArray<CDOption*>*)) deprecates;
- (CDOption *(^)(BOOL)) hide;
- (CDOption *(^)(NSUInteger)) toValueIndex;
- (CDOption *(^)(NSInteger)) max;
- (CDOption *(^)(NSInteger)) min;
- (CDOption *(^)(NSArray*)) overrideValues;
- (CDOption *(^)(CDOptionProcessBlock)) process;
- (CDOption *(^)(BOOL)) provided;
- (CDOption *(^)(NSString*)) rawValue;
- (CDOption *(^)(BOOL)) require;
- (CDOption *(^)(id)) setDefaultValue;
- (CDOption *(^)(NSString*)) setScope;

@end
