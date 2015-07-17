//
//  CDCommon.h
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDOptions.h"
@class NSObject;

@interface CDCommon : NSObject {
    CDOptions *options;
}
@property (strong) CDOptions *options;

- (void) debug:(NSString *)message;
- (instancetype) initWithOptions:(CDOptions *)newOptions NS_DESIGNATED_INITIALIZER;

@end
