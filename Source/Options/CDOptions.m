#import "CDOptions.h"

@implementation CDOptions

- (instancetype) init {
    self = [super init];
    if (self) {
        _options = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype) options {
    return [[[self alloc] init] autorelease];
}

- (void)addOption:(CDOption *)option {
    if ([option isKindOfClass:[CDOptionDeprecated class]]) {
        [_deprecatedOptions addObject:(CDOptionDeprecated *)option];
    }
    else {
        [_options setObject:option forKey:option.name];
    }
}

- (CDOption *)objectForKeyedSubscript:(NSString *)key {
    return [_options objectForKey:key];
}

- (void)setObject:(CDOption *)option forKeyedSubscript:(NSString*)key {
    [_options setValue:option forKey:key];
}

- (void) dealloc {
	[super dealloc];
}

@end
