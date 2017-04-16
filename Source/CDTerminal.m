#import "CDTerminal.h"

@implementation CDTerminal

#pragma mark - Public static methods
+ (instancetype) terminal {
    return [[[self alloc] init] autorelease];
}


#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        // Private properties.
        fhIn = [NSFileHandle fileHandleWithStandardInput];
        fhErr = [NSFileHandle fileHandleWithStandardError];
        fhOut = [NSFileHandle fileHandleWithStandardOutput];
        which = [NSMutableDictionary dictionary];

        // Public properties.
        _colors = [[self execute:[self which:@"tput"] withArguments:@[@"colors", @"2>/dev/null"]] integerValue];
        _cols = [[self execute:[self which:@"tput"] withArguments:@[@"cols", @"2>/dev/null"]] integerValue];
        _supportsColor = _cols > 8;
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
    [task release];
    NSData *dataRead = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *output = [[[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding] autorelease];
    output = [output stringByReplacingCharactersInSet:[NSCharacterSet newlineCharacterSet] withString:@""];
    return  output;
}

- (void) write:(NSString *)string {
    if (fhOut) {
        [fhOut writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void) writeError:(NSString *)string {
    if (fhErr) {
        [fhErr writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
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
    if (!which[command]) {
        which[command] = [self execute:@"/usr/bin/which" withArguments:@[command]];
    }
    return which[command];
}


@end
