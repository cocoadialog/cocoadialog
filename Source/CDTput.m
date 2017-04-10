#import "CDTput.h"

@implementation CDTput

+ (NSString *) executeWithArgs:(NSArray *)args {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *out = [NSPipe pipe];
    [task setLaunchPath:@"/usr/bin/tput"];
    [task setArguments:args];
    [task setStandardOutput:out];
    [task launch];
    [task waitUntilExit];
    [task release];
    NSData *dataRead = [[out fileHandleForReading] readDataToEndOfFile];
    NSString *output = [[[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding] autorelease];
    output = [output stringByReplacingCharactersInSet:[NSCharacterSet newlineCharacterSet] withString:@""];
    return  output;
}

+ (int) colors {
    return [[CDTput executeWithArgs:@[@"colors"]] intValue];
}

+ (int) cols {
    return [[CDTput executeWithArgs:@[@"cols"]] intValue];
}

+ (int) colsWithMinimum:(int)minimum {
    int cols = [CDTput cols];
    if (cols < minimum) {
        cols = minimum;
    }
    return cols;
}

+ (BOOL) supportsColor {
    return [CDTput colors] > 8;
}


@end
