//
//  CDCommon.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDCommon.h"

@implementation CDCommon
@synthesize options;

- (void) debug:(NSString *)message {
	NSString *output = [NSString stringWithFormat:@"cocoaDialog Error: %@\n", message]; 
    // Output to stdErr
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
	if (fh) {
		[fh writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
	}
}

- (id)init {
	return [self initWithOptions:nil];
}
- (id)initWithOptions:(CDOptions *)opts {
	self = [super init];
    [self setOptions:nil];
    if (opts != nil) {
        [self setOptions:opts];
    }
	return self;
}
- (NSRect) screen {
    NSRect screen = [[NSScreen mainScreen] frame];
    int screenNumber = 1;
    if ([options hasOpt:@"screen"]) {
        if (![[NSScanner scannerWithString:[options optValue:@"screen"]] scanInt:&screenNumber]) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"Unable to parse the --screen option"];
            }
            screenNumber = 1;
        }
        NSArray *screens = [NSScreen screens];
        if (screenNumber > (int)[screens count]) {
            screenNumber = (int)[screens count];
        }
        screen = [[screens objectAtIndex:screenNumber - 1] visibleFrame];
    }
    return screen;
}


@end
