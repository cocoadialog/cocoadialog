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

- (NSString *) argumentToString:(NSString *)arg lineColor:(CDColor *)lineColor argumentColor:(CDColor *)argumentColor {
    NSMutableString *string = [NSMutableString stringWithString:[arg applyColor:argumentColor]];
    [string appendString:[@"" applyColor:lineColor]];
    return string;
}

- (NSMutableArray *) argumentsToArray:(va_list)args lineColor:(CDColor *)lineColor argumentColor:(CDColor *)argumentColor {
    NSMutableArray *array = [NSMutableArray array];
    id arg;
    while ((arg = va_arg(args, id))) {
        if ([arg isKindOfClass:[NSString class]]) {
            [array addObject:[self argumentToString:arg lineColor:lineColor argumentColor:argumentColor]];
        }
        else {
            [array addObject:arg];
        }
    }
    va_end(args);
    return array;
}

- (void) debug:(NSString *)format, ... {
    if (arguments && arguments.options[@"debug"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgMagenta];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_DEBUG", nil) toString:format] applyColor:lineColor].stop;
        [self writeLn:[NSString stringWithFormat:format array:args]];
    }
}

- (void) error:(NSString *)format, ... {
    CDColor *lineColor = [CDColor fg:CDColorFgRed bg:CDColorBgNone style:CDColorStyleBold];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_ERROR", nil) toString:format] applyColor:lineColor].stop;
    [self writeLn:[NSString stringWithFormat:format array:args] asError:YES];
}


- (void) fatalError:(NSString *)format, ... {
    CDColor *lineColor = [CDColor fg:CDColorFgRed bg:CDColorBgNone style:CDColorStyleBold];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_ERROR", nil) toString:format] applyColor:lineColor].stop;
    [self writeLn:[NSString stringWithFormat:format array:args] asError:YES];
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
    if (arguments && arguments.options[@"verbose"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgCyan];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_VERBOSE", nil) toString:format] applyColor:lineColor].stop;
        [self writeLn:[NSString stringWithFormat:format array:args]];
    }
}

- (void) warning:(NSString *)format, ... {
    if (!arguments || !arguments.options[@"no-warnings"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgYellow];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_WARNING", nil) toString:format] applyColor:lineColor].stop;
        [self writeLn:[NSString stringWithFormat:format array:args] asError:YES];
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
