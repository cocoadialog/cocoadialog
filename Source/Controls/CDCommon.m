//
//  CDCommon.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDCommon.h"

@implementation CDCommon
@synthesize arguments;


- (void) debug:(NSString *)format, ... {
    if (arguments && [arguments hasOption:@"debug"]) {
        va_list args;
        va_start(args, format);
        [self writeLn:[NSString stringWithFormat:@"[%@]: %@", NSLocalizedString(@"DEBUG", nil), [[[NSString alloc] initWithFormat:format arguments:args] autorelease]]];
    }
}

- (void) error:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [self writeLn:[NSString stringWithFormat:@"[%@]: %@", NSLocalizedString(@"ERROR", nil), [[[NSString alloc] initWithFormat:format arguments:args] autorelease]] asError:YES];
}


- (void) fatalError:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [self writeLn:[NSString stringWithFormat:@"[%@]: %@", NSLocalizedString(@"FATAL", nil), [[[NSString alloc] initWithFormat:format arguments:args] autorelease]] asError:YES];
    exit(255);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        fhIn = [NSFileHandle fileHandleWithStandardInput];
        fhErr = [NSFileHandle fileHandleWithStandardError];
        fhOut = [NSFileHandle fileHandleWithStandardOutput];
    }
    return self;
}

- (instancetype)initWithArguments:(CDArguments *)args {
    self = [self init];
    if (self) {
        self.arguments = args;
    }
    return self;
}

- (void) verbose:(NSString *)format, ... {
    if (arguments && [arguments hasOption:@"verbose"]) {
        va_list args;
        va_start(args, format);
        [self writeLn:[NSString stringWithFormat:@"[%@]: %@", NSLocalizedString(@"VERBOSE", nil), [[[NSString alloc] initWithFormat:format arguments:args] autorelease]]];
    }
}

- (void) warning:(NSString *)format, ... {
    if (!arguments || ![arguments hasOption:@"no-warnings"]) {
        va_list args;
        va_start(args, format);
        [self writeLn:[NSString stringWithFormat:@"[%@]: %@", NSLocalizedString(@"WARNING", nil), [[[NSString alloc] initWithFormat:format arguments:args] autorelease]]];
    }
}

- (void) write:(NSString *)string {
    [self write:string asError:NO];
}

- (void) write:(NSString *)string asError:(BOOL)error {
    if (error && fhErr) {
        [fhErr writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if (fhOut) {
        [fhOut writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void) writeLn:(NSString *)string {
    [self write:string];
    [self write:@"\n"];
}

- (void) writeLn:(NSString *)string asError:(BOOL)error {
    [self write:string asError:error];
    [self write:@"\n" asError:error];
}

@end
