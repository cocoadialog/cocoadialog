// CDLocale.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

// Heavily inspried by https://medium.com/@dcordero/a-different-way-to-deal-with-localized-strings-in-swift-3ea0da4cd143

#import "CDLocale.h"
#import "NSArray+CDArray.h"
#import "NSString+CDString.h"

@implementation CDLocale

#pragma mark - Public static methods

+ (instancetype) sharedInstance {
    static CDLocale* sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CDLocale alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        _terminal = [CDTerminal sharedInstance];
        NSString* file = [[NSBundle mainBundle] pathForResource:@"Locale" ofType:@"plist"];
        NSURL* url = [NSURL fileURLWithPath:file];

        if (@available(macOS 10.13, *)) {
            NSError* error;
            _dictionary = [NSMutableDictionary dictionaryWithContentsOfURL:url error:&error];
            [_terminal writeError:error.localizedDescription];
        }
        else {
            _dictionary = [NSMutableDictionary dictionaryWithContentsOfURL:url];
        }
        if (!_dictionary.count) {
            [_terminal writeError:@"Unable to read Locale.plist."];
        }
    }
    return self;
}

- (NSString *) localize:(NSString *)key {
    NSDictionary* item = self.dictionary[key];
    NSString* value = item ? self.dictionary[key][@"value"] : nil;
    if (!item || !value) {
        self.terminal.dev(@"Missing translation for: %@", key.doubleQuote, nil);
        if (self.terminal.logLevel & CDTerminalLogLevelDev) {
            return key.addColor([CDColor fg:CDColorFgYellow bg:CDColorBgRed]).stop;
        }
        else {
            return key;
        }
    }
    return value;
}

@end
