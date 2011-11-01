//
//  CDCommon.m
//  CocoaDialog
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


@end
