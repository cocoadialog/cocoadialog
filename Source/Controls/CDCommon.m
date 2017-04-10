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
        NSMutableString *output = [NSMutableString string];
        [output appendString:[NSString stringWithFormat:@"[%@]: ", NSLocalizedString(@"DEBUG", nil)].magenta.dim];
        [output appendString:[[[NSString alloc] initWithFormat:format arguments:args] autorelease].white];
        [self writeLn:output.stopAnsi];
    }
}

- (void) error:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSMutableString *output = [NSMutableString string];
    [output appendString:[NSString stringWithFormat:@"[%@]: ", NSLocalizedString(@"ERROR", nil)].red];
    [output appendString:[[[NSString alloc] initWithFormat:format arguments:args] autorelease].white];
    [self writeLn:output.stopAnsi asError:YES];
}


- (void) fatalError:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSMutableString *output = [NSMutableString string];
    [output appendString:[NSString stringWithFormat:@"[%@]: ", NSLocalizedString(@"ERROR", nil)].red];
    [output appendString:[[[NSString alloc] initWithFormat:format arguments:args] autorelease]];
    [self writeLn:output.stopAnsi asError:YES];
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
        format = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
        NSMutableString *output = [NSMutableString string];
        [output appendString:[NSString stringWithFormat:@"[%@]: ", NSLocalizedString(@"VERBOSE", nil)].cyan];
        [output appendString:format];
        [self writeLn:output.stopAnsi];
    }
}

- (void) warning:(NSString *)format, ... {
    if (!arguments || ![arguments hasOption:@"no-warnings"]) {
        va_list args;
        va_start(args, format);
        format = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
        NSMutableString *output = [NSMutableString string];
        [output appendString:[NSString stringWithFormat:@"[%@]: ", NSLocalizedString(@"WARNING", nil)].yellow];
        [output appendString:format];
        [self writeLn:output.stopAnsi asError:YES];
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
    [self writeNewLine];
}

- (void) writeNewLine {
    [self write:@"\n"];
}

- (void) writeLn:(NSString *)string asError:(BOOL)error {
    [self write:string asError:error];
    [self writeNewLineAsError:error];
}

- (void) writeNewLineAsError:(BOOL)error {
    [self write:@"\n" asError:error];
}

@end
