// CDTemplate.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDTemplate.h"

@implementation CDTemplate

+ (instancetype) load:(NSString *)templateName data:(id)data error:(NSError **)error {
    return [[self alloc] initTemplate:templateName withData:data error:error];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        NSError *error = nil;
        _repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
        _tpl = [GRMustacheTemplate templateFromString:@"" error:&error];
    }
    return self;
}

- (instancetype) initTemplate:(NSString *)templateName withData:(id)data error:(NSError **)error {
    self = [self init];
    if (self) {
        self.data = data;
        self.tpl = [self.repository templateNamed:templateName error:error];
    }
    return self;
}

- (NSString *) renderError:(NSError **)error {
    return [self.tpl renderObject:self.data error:error];
}

- (void) setStringValue:(NSString *)stringValue {
    NSError *error = nil;
    self.tpl = [GRMustacheTemplate templateFromString:stringValue error:&error];
    [super setStringValue:stringValue];
}

@end

