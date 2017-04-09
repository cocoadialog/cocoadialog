#import "CDOption.h"

@implementation CDOption

+ (instancetype) name:(NSString *)name {
    return [[[self alloc] name:name value:nil category:nil helpText:nil] autorelease];
}

+ (instancetype) name:(NSString *)name value:(id)value {
    return [[[self alloc] name:name value:value category:nil helpText:nil] autorelease];
}

+ (instancetype) name:(NSString *)name category:(NSString *) category {
    return [[[self alloc] name:name value:nil category:category helpText:nil] autorelease];
}

+ (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category {
    return [[[self alloc] name:name value:value category:category helpText:nil] autorelease];
}

+ (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category helpText:(NSString *)helpText {
    return [[[self alloc] name:name value:value category:category helpText:helpText] autorelease];
}

- (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category helpText:(NSString *)helpText {
    self = [super init];
    if (self) {
        _name = name;
        _value = value;

        if (category != nil) {
            _category = NSLocalizedString(category, nil);
        }

        if (helpText == nil) {
            NSCharacterSet *nonAlphanumericSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
            NSMutableString *autoHelpText = [NSMutableString string];
            if (category != nil) {
                [autoHelpText appendString:[category.uppercaseString stringByReplacingCharactersInSet:nonAlphanumericSet withString:@"_"]];
            }
            else {
                [autoHelpText appendString:[NSLocalizedString(@"USAGE_CATEGORY_CONTROL", nil).uppercaseString stringByReplacingCharactersInSet:nonAlphanumericSet withString:@"_"]];
            }
            [autoHelpText appendString:@"_"];
            [autoHelpText appendString:[name.uppercaseString stringByReplacingCharactersInSet:nonAlphanumericSet withString:@"_"]];
            _helpText = NSLocalizedString(autoHelpText, nil);
        }
        else {
            _helpText = NSLocalizedString(helpText, nil);
        }
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@", [_value description]];
}

@end

@implementation CDOptionDeprecated

- (instancetype) from:(NSString *)from to:(NSString *)to {
    _from = from;
    _to = to;
    return self;
}

+ (instancetype) from:(NSString *)from to:(NSString *)to {
    return [[[CDOptionDeprecated alloc] from:from to:to] autorelease];
}

@end

@implementation CDOptionFlag @end
@implementation CDOptionSingleString @end
@implementation CDOptionSingleNumber @end
@implementation CDOptionSingleStringOrNumber @end
@implementation CDOptionMultipleStrings @end
@implementation CDOptionMultipleNumbers @end
@implementation CDOptionMultipleStringsOrNumbers @end
