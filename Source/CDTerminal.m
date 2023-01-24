// CDTerminal.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDTerminal.h"

#import "NSArray+CDArray.h"
#import "NSString+CDString.h"

@implementation CDTerminal

#pragma mark - Public static methods
+ (instancetype) sharedInstance {
    static CDTerminal *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CDTerminal alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Private instance methods
- (NSString *) argumentToString:(NSString *)arg lineColor:(CDColor *)lineColor argumentColor:(CDColor *)argumentColor {
    NSMutableString *string = [NSMutableString stringWithString:arg.addColor(argumentColor)];
    return string.append(@"".addColor(lineColor));
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

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        // Private properties.
        _fhIn = [NSFileHandle fileHandleWithStandardInput];
        _fhErr = [NSFileHandle fileHandleWithStandardError];
        _fhOut = [NSFileHandle fileHandleWithStandardOutput];
        _which = @{}.mutableCopy;

        // Retrieve the process arguments, starting after the command path.
        _arguments = [[NSProcessInfo processInfo].arguments sliceFrom:1].mutableCopy;

        [self writeLine:_arguments.join(@" ")];

        // Get the process environment.
        _environment = [NSProcessInfo processInfo].environment;

        // Determine if running inside a terminal.
        _isCLI = !!(_environment[@"TERM_PROGRAM"] && !_environment[@"TERM_PROGRAM"].isBlank);

        // The "tput" command will throw an error if there is no "TERM" environment variable set.
        // If not, assume terminal is not interactive.
        if (!_isCLI || !_environment[@"TERM"] || _environment[@"TERM"].isBlank) {
            _colors = 0;
            _cols = 0;
        }
        else {
            _colors = [[self execute:[self which:@"tput"] withArguments:@[@"colors"]] integerValue];
            _cols = [[self execute:[self which:@"tput"] withArguments:@[@"cols"]] integerValue];
        }
        _supportsColor = _colors >= 8;

        // Default NSStringCDColor to terminal support.
        NSStringCDColor = _supportsColor;
    }
    return self;
}

- (NSUInteger) colsWithMinimum:(NSUInteger)minimum {
    if (_cols < minimum) {
        return minimum;
    }
    return _cols;
}

- (NSString *) execute:(NSString *)command withArguments:(NSArray *)arguments {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    [task setLaunchPath:command];
    [task setArguments:arguments];
    [task setStandardOutput:pipe];
    [task launch];
    [task waitUntilExit];
    NSData *dataRead = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    output = [output stringByReplacingCharactersInSet:[NSCharacterSet newlineCharacterSet] withString:@""];
    return  output;
}

- (void) write:(NSString *)string {
    if (!self.fhOut) {
        return;
    }
    [self.fhOut writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeError:(NSString *)string {
    if (!self.fhErr) {
        return;
    }
    [self.fhErr writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeLine:(NSString *)string {
    [self write:string];
    [self writeNewLine];
}

- (void) writeNewLine {
    [self write:@"\n"];
}

- (void) writeErrorLine:(NSString *)string{
    [self writeError:string];
    [self writeErrorNewLine];
}

- (void) writeErrorNewLine {
    [self writeError:@"\n"];
}

- (NSString *) which:(NSString *)command {
    if (!self.which[command]) {
        self.which[command] = [self execute:@"/usr/bin/which" withArguments:@[command]];
    }
    return self.which[command];
}

#pragma mark - Public chainable methods
- (CDTerminal *(^)(NSString*, ...)) debug {
    return ^CDTerminal *(NSString* format, ...) {
        // Immediately return current log level is not sufficent.
        if (!(self.logLevel & CDTerminalLogLevelDebug)) {
            return self;
        }

        CDColor *lineColor = [CDColor fg:CDColorFgMagenta];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = format.prepend(@"LOG_DEBUG".localized).addColor(lineColor).stop;
        [self writeErrorLine:[NSString stringWithFormat:format array:args]];
        return self;
    };
}

- (CDTerminal *(^)(NSString*, ...)) dev {
    return ^CDTerminal *(NSString* format, ...) {
        // Immediately return current log level is not sufficent.
        if (!(self.logLevel & CDTerminalLogLevelDev)) {
            return self;
        }

        CDColor *lineColor = [CDColor fg:CDColorFgYellow bg:CDColorBgRed];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        // Inject the invoking method.
        NSArray* callStack = [NSThread callStackSymbols].parseCallStackSymbols;
        format = format.prepend(@"<%@> [%@ %@] ".arguments(callStack[2], callStack[3], callStack[4], nil)).addColor(lineColor).stop;
        [self writeErrorLine:[NSString stringWithFormat:format array:args]];
        return self;
    };
}

- (CDTerminal *(^)(NSString *, ...)) error {
    return ^CDTerminal *(NSString* format, ...) {
        // Immediately return current log level is not sufficent.
        if (!(self.logLevel & CDTerminalLogLevelError)) {
            return self;
        }

        CDColor *lineColor = [CDColor fg:CDColorFgRed bg:CDColorBgNone style:CDColorStyleBold];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = format.prepend(@"LOG_ERROR".localized).addColor(lineColor).stop;
        [self writeErrorLine:[NSString stringWithFormat:format array:args]];
        return self;
    };
}

- (void *(^)(CDTerminalExitCode)) exit {
    return ^void *(CDTerminalExitCode exitCode) {
        exit((int) exitCode);
    };
}

- (CDTerminal *(^)(CDTerminalLogLevel)) setLogLevel {
    return ^CDTerminal *(CDTerminalLogLevel level) {
        self.logLevel = level;
        return self;
    };
}

- (CDTerminal *(^)(NSString*, ...)) verbose {
    return ^CDTerminal *(NSString* format, ...) {
        // Immediately return current log level is not sufficent.
        if (!(self.logLevel & CDTerminalLogLevelVerbose)) {
            return self;
        }

        CDColor *lineColor = [CDColor fg:CDColorFgCyan];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = format.prepend(@"LOG_VERBOSE".localized).addColor(lineColor).stop;
        [self writeErrorLine:[NSString stringWithFormat:format array:args]];
        return self;
    };
}

- (CDTerminal *(^)(NSString*, ...)) warning {
    return ^CDTerminal *(NSString* format, ...) {
        // Immediately return current log level is not sufficent.
        if (!(self.logLevel & CDTerminalLogLevelWarning)) {
            return self;
        }

        CDColor *lineColor = [CDColor fg:CDColorFgYellow];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = format.prepend(@"LOG_WARNING".localized).addColor(lineColor).stop;
        [self writeErrorLine:[NSString stringWithFormat:format array:args]];
        return self;
    };
}

@end
