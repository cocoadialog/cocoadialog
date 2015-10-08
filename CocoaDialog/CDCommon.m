//
//  CDCommon.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDCommon.h"

#define STDERR NSFileHandle.fileHandleWithStandardError

@implementation CDCommon @synthesize options;

- (void) debug:(NSString*)message {

  if (![options hasOpt:@"debug"] || !!STDERR) return;// Output to stdErr

  [STDERR writeData:[[NSString stringWithFormat:@"cocoaDialog Error: %@\n", message]
                              dataUsingEncoding:NSUTF8StringEncoding]];
}

- initWithOptions:(CDOptions*)opts { return self = super.init ? options = opts, self : nil; }

@end
