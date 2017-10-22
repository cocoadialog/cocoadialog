// CDTemplate.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDTemplate.h"

@implementation CDTemplate

+ (instancetype)sharedInstance {
  static CDTemplate *sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[CDTemplate alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
    _templates = @{}.mutableCopy;
    _terminal = [CDTerminal sharedInstance];
  }
  return self;
}

- (NSString *(^)(NSString *name, id data))render {
  return ^NSString *(NSString *name, id data) {
    return [self render:name withData:data];
  };
}

- (GRMustacheTemplate *)load:(NSString *)name {
  GRMustacheTemplate *template = self.templates[name];
  if (!template) {
    NSError *parseError;
    template = [self.repository templateNamed:name error:&parseError];
    if (parseError) {
      self.terminal.error(@"%@", parseError.localizedDescription, nil).exit(CDTerminalExitCodeTemplateLoadFailure);
      template = [[GRMustacheTemplate alloc] init];
    }
    self.templates[name] = template;
  }
  return template;
}

- (NSString *)render:(NSString *)name withData:(id)data {
  NSError *renderError;
  NSString *rendered = [[self load:name] renderObject:data error:&renderError];
  if (renderError) {
    self.terminal.error(@"%@", renderError.localizedDescription, nil).exit(CDTerminalExitCodeTemplateRenderFailure);
  }

  return rendered;
}

@end
