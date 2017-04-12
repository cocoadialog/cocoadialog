//
//  CDCommon.h
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDArguments.h"
#import "NSString+CDCommon.h"

@class NSObject;

@interface CDCommon : NSObject {
    NSFileHandle *fhErr;
    NSFileHandle *fhIn;
    NSFileHandle *fhOut;
    CDArguments *arguments;
}
@property (retain) CDArguments *arguments;

- (void) debug:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) error:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) fatalError:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (instancetype) initWithArguments:(CDArguments *)args;
- (void) verbose:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) warning:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) write:(NSString *)string;
- (void) writeLn:(NSString *)string;
- (void) writeNewLine;
- (void) write:(NSString *)string asError:(BOOL)error;
- (void) writeLn:(NSString *)string asError:(BOOL)error;
- (void) writeNewLineAsError:(BOOL)error;

@end
