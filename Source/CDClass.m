// CDClass.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDClass.h"
#import "CDTerminal.h"
#import "NSString+CDString.h"

@implementation CDClass

+ (CDClass *(^)(Class aClass))create {
  return ^CDClass *(Class aClass) {
    return [CDClass initWithClass:aClass];
  };
}

+ (instancetype)initWithClass:(Class)aClass {
  return [[self alloc] initWithClass:aClass];
}

- (instancetype)initWithClass:(Class)aClass {
  self = [self init];
  if (self) {
    _class = aClass;
  }
  return self;
}

- (CDClass *(^)(NSString *aProtocol))ensureProtocol {
  return ^CDClass *(NSString *aProtocol) {
    _protocol = NSProtocolFromString(aProtocol);
    if (!_protocol) {
      CDTerminal.sharedInstance.error(@"Unknown protocol %@.", aProtocol.doubleQuote, nil).exit(CDTerminalExitCodeInternal);
    }
    else if (![_class conformsToProtocol:_protocol]) {
      CDTerminal.sharedInstance.error(@"The class %@ does not conform to the protocol %@.", NSStringFromClass(_class).doubleQuote, aProtocol.doubleQuote, nil).exit(CDTerminalExitCodeInternal);
    }
    return self;
  };
}

- (NSArray *)argumentsToArray:(va_list)args {
  NSMutableArray *array = @[].mutableCopy;
  id arg;
  while ((arg = va_arg(args, id))) {
    [array addObject:arg];
  }
  va_end(args);
  return array;
}

- (id(^)(SEL aSelector, ...))methodForSelector {
  return ^id(SEL aSelector, ...) {
    va_list va_args;
    va_start(va_args, aSelector);
    NSArray *args = [self argumentsToArray:va_args];
    switch (args.count) {
      case 0:
        return ((id(*)(id, SEL)) [_class methodForSelector:aSelector])(_class, aSelector);
      case 1:
        return ((id(*)(id, SEL, id)) [_class methodForSelector:aSelector])(_class, aSelector, args[0]);
      case 2:
        return ((id(*)(id, SEL, id, id)) [_class methodForSelector:aSelector])(_class, aSelector, args[0], args[1]);
      case 3:
        return ((id(*)(id, SEL, id, id, id)) [_class methodForSelector:aSelector])(_class, aSelector, args[0], args[1], args[2]);
      default:
        CDTerminal.sharedInstance.error(@"Only a maximum of 3 arguments to be passed to a selector is currently supported.", nil).exit(CDTerminalExitCodeInternal);
        return self;
    }
  };
}

@end
