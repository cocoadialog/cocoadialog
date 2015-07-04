//
//  CDCommon.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDCommon.h"

@implementation CDCommon

- (void) debug:(NSString *)message {

  if (NSFileHandle.fileHandleWithStandardError) // Output to stdErr
    [NSFileHandle.fileHandleWithStandardError writeData:[[NSString stringWithFormat:@"cocoaDialog Error: %@\n", message]
                                                         dataUsingEncoding:NSUTF8StringEncoding]];
}

- initWithOptions:(CDOptions *)opts { return self = super.init ? ({ if (opts) options = opts; }), self : nil; }

@end
