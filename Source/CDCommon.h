
//  CDCommon.h cocoaDialog
//  Created by Mark Whitaker on 10/29/11. Copyright (c) 2011 __MyCompanyName__. All rights reserved.

#import "CDOptions.h"

@interface CDCommon : NSObject

@property CDOptions * options;

- (void) debug:(NSString*)message;

- initWithOptions:(CDOptions*)newOptions;

@end
