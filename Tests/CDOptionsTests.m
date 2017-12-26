// CDOptionsTest.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <XCTest/XCTest.h>
#import "CDOptions.h"

@interface CDOptions (Test)
- (CDOptions *(^)(void))reset;
@end

@implementation CDOptions (Test)
- (CDOptions *(^)(void))reset {
  return ^CDOptions *() {
    return [CDOptions options].addOptions(_options.allValues);
  };
}
@end

@interface CDOptionsTests : XCTestCase

@property CDOptions *global;

@end

@implementation CDOptionsTests

- (void)setUp {
  [super setUp];
  _global = [CDControl availableOptions];
}

- (void)testDebug {
  // Flag.
  XCTAssertEqual(_global.reset().processArguments(@[@"--debug"])[@"debug"].wasProvided, YES);

  // False.
  XCTAssertEqual(_global.reset().processArguments(@[@"--debug", @"0"])[@"debug"].wasProvided, NO);
  XCTAssertEqual(_global.reset().processArguments(@[@"--debug", @"no"])[@"debug"].wasProvided, NO);
  XCTAssertEqual(_global.reset().processArguments(@[@"--debug", @"false"])[@"debug"].wasProvided, NO);

  // True.
  XCTAssertEqual(_global.reset().processArguments(@[@"--debug", @"1"])[@"debug"].wasProvided, YES);
  XCTAssertEqual(_global.reset().processArguments(@[@"--debug", @"yes"])[@"debug"].wasProvided, YES);
  XCTAssertEqual(_global.reset().processArguments(@[@"--debug", @"true"])[@"debug"].wasProvided, YES);
}

@end
