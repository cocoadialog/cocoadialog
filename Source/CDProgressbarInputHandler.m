// CDProgressbarInputHandler.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.
//
// Created by Alexey Ermakov on 19.09.2011.

#import "CDProgressbarInputHandler.h"

@implementation CDProgressbarInputHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        buffer = [[NSMutableData alloc] initWithCapacity:2048];
    }

    return self;
}

-(BOOL) getLastNewlinePosition:(NSUInteger *)position inData:(NSData *)data
{
	BOOL found = NO;

	const char* current	= data.bytes;
	NSUInteger length = data.length;
	for (NSUInteger i = 0; i < length; i++) {
		if (*current++ == '\n') {
			found = YES;
			*position = i;
		}
	}

	return found;
}

-(NSString *) readLines:(NSFileHandle *)fileHandle
{
    // Read a chunk of data from the file handle into the buffer and see if we have at least one complete string.
    // As newline takes one byte in UTF-8, we just scan for the last occurrence of it in the buffer, return everything up to it
    // as an NSString and leave the rest in the buffer.
    for (;;) {
        NSData* chunk = fileHandle.availableData;
        if (chunk.length == 0) {
            finished = YES;
            return nil;
        } else {
            [buffer appendData:chunk];
            NSUInteger lastNewline;
            if ([self getLastNewlinePosition:&lastNewline inData:buffer]) {
#ifdef CD_HEAD
                NSData* readStrings = [buffer subdataWithRange:NSMakeRange(0, lastNewline + 1)];
                NSData* rest = [buffer subdataWithRange:NSMakeRange(lastNewline + 1, buffer.length - (lastNewline + 1))];
                buffer = [[NSMutableData alloc] initWithData:rest];

                NSString* result = [[NSString alloc] initWithData:readStrings encoding:NSUTF8StringEncoding];
#else
                NSData *readStrings = [buffer subdataWithRange:NSMakeRange(0, (lastNewline + 1))];
                NSData *rest = [buffer subdataWithRange:NSMakeRange((lastNewline + 1),
                                                                    ([buffer length] - (lastNewline + 1)))];
                [buffer release];
                buffer = [[NSMutableData alloc] initWithData:rest];

                NSString *result = [[[NSString alloc] initWithData:readStrings
                                                          encoding:NSUTF8StringEncoding] autorelease];
#endif
                return result;
            }
        }
    }
}

-(BOOL) parseString:(NSString *)str intoProgress:(double *)value
{
    if (str == nil) {
        return NO;
    } else {
        NSScanner *scanner = [NSScanner scannerWithString:str];
        double result = 0.0;
        if ([scanner scanDouble:&result]) {
            if (result >= CDProgressbarMIN && result <= CDProgressbarMAX) {
                *value = result;
                return YES;
            }
        }
        return NO;
    }
}

-(void) invokeOnMainQueueWithTarget:(id)target selector:(SEL)selector object:(id)object
{
	NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:target
                                                                            selector:selector
                                                                              object:object];
	[mainQueue addOperation:operation];
}

-(void) updateProgress:(double)newProgress
{
    if (currentProgress != newProgress) {
        currentProgress = newProgress;
#ifdef CD_HEAD
        [self invokeOnMainQueueWithTarget:delegate selector:@selector(updateProgress:) object:@(newProgress)];
#else
        [self invokeOnMainQueueWithTarget:delegate
                                 selector:@selector(updateProgress:)
                                   object:[NSNumber numberWithDouble:newProgress]];
#endif
    }
}

-(void) updateLabel:(NSString *)newLabel
{
    if (![currentLabel isEqualToString:newLabel]) {
        currentLabel = newLabel;

        [self invokeOnMainQueueWithTarget:delegate
                                 selector:@selector(updateLabel:)
                                   object:newLabel];
    }
}

-(void) parseLines:(NSString *)str
{
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *lines = [str componentsSeparatedByString:@"\n"];

    for (NSUInteger i = 0; i < lines.count; i++) {
        NSString *line = lines[i];
        if (line.length != 0) {
            if ([line isEqualToString:@"stop enable"]) {
#ifdef CD_HEAD
                [self invokeOnMainQueueWithTarget:delegate selector:@selector(setStopEnabled:) object:@YES];
#else
                [self invokeOnMainQueueWithTarget:delegate
                                         selector:@selector(setStopEnabled:)
                                           object:[NSNumber numberWithBool:YES]];
#endif
            } else if ([line isEqualToString:@"stop disable"]) {
#ifdef CD_HEAD
                [self invokeOnMainQueueWithTarget:delegate selector:@selector(setStopEnabled:) object:@NO];
#else
                [self invokeOnMainQueueWithTarget:delegate
                                         selector:@selector(setStopEnabled:)
                                           object:[NSNumber numberWithBool:NO]];
#endif
            } else {
                NSScanner *scanner = [NSScanner scannerWithString:line];

                NSString *percent = NULL;
                [scanner scanUpToCharactersFromSet:whitespaceSet
                                        intoString:&percent];

                double progressValue;
                if ([self parseString:percent intoProgress:&progressValue]) {
                    [self updateProgress:progressValue];
                    NSString *newLabel = [line substringFromIndex:scanner.scanLocation];
                    if (newLabel.length != 0) {
                        [self updateLabel:newLabel];
                    }
                }
            }
        }
    }
}

-(void) setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

-(void) main
{
    NSFileHandle *stdinFH = [NSFileHandle fileHandleWithStandardInput];

    while (!finished) {
#ifdef CD_HEAD
        @autoreleasepool {
            NSString* lines = [self readLines:stdinFH];
            [self parseLines:lines];
        }
#else
        pool = [[NSAutoreleasePool alloc] init];
        NSString *lines = [self readLines:stdinFH];
        [self parseLines:lines];
        [pool drain];
#endif
    }

    [self invokeOnMainQueueWithTarget:delegate
                             selector:@selector(finish)
                               object:nil];
}

@end

/* EOF */
