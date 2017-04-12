#import "CDOptions.h"

@implementation CDOptions

@synthesize deprecatedOptions = _deprecatedOptions;
@synthesize requiredOptions = _requiredOptions;

- (instancetype) init {
    self = [super init];
    if (self) {
        _options = [NSMutableDictionary dictionary];
        _deprecatedOptions = [NSMutableDictionary dictionary];
        _requiredOptions = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype) options {
    return [[[self alloc] init] autorelease];
}

- (void)addOption:(CDOption *)option {
    if ([option isKindOfClass:[CDOptionDeprecated class]]) {
        CDOptionDeprecated *deprecated = (CDOptionDeprecated *)option;
        [_deprecatedOptions setObject:deprecated forKey:deprecated.from];
    }
    else {
        if (option.required) {
            [_requiredOptions setObject:option forKey:option.name];
        }
        [_options setObject:option forKey:option.name];
    }
}

- (NSMutableDictionary<NSString *,CDOptionDeprecated *> *)deprecatedOptions {
    NSMutableDictionary<NSString *,CDOptionDeprecated *> *deprecatedOptions = [NSMutableDictionary dictionaryWithDictionary:_deprecatedOptions];
    for (NSString *name in _options) {
        CDOption *option = _options[name];
        if ([option isKindOfClass:[CDOptionDeprecated class]]) {
            [deprecatedOptions setObject:(CDOptionDeprecated *)option forKey:name];
        }
    }
    return deprecatedOptions;
}

- (NSMutableDictionary<NSString *,CDOption *> *)requiredOptions {
    NSMutableDictionary<NSString *,CDOption *> *requiredOptions = [NSMutableDictionary dictionaryWithDictionary:_requiredOptions];
    for (NSString *name in _options) {
        CDOption *option = _options[name];
        if (option.required) {
            [requiredOptions setObject:option forKey:name];
        }
    }
    return requiredOptions;
}

- (CDOption *)objectForKeyedSubscript:(NSString *)key {
    return [_options objectForKey:key];
}

- (void)setObject:(CDOption *)option forKeyedSubscript:(NSString*)key {
    [_options setValue:option forKey:key];
}

@end
