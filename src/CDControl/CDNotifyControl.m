//
//  CDNotifyControl.m
//  CocoaDialog
//
//  Created by Mark Carver on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDNotifyControl.h"

@implementation CDNotifyControl

// This must be overridden if you want local global options for your control
- (NSDictionary *) globalAvailableKeys {
    NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
    NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    return [[NSDictionary dictionaryWithObjectsAndKeys:
             // General
             vNone, @"help",
             vNone, @"debug",
             vNone, @"sticky",
             // Text
             vOne,  @"title",
             vOne,  @"description",
             vMul,  @"titles",
             vMul,  @"descriptions",
             // Icons
             vOne,  @"icon",
             vOne,  @"icon-bundle",
             vOne,  @"icon-file",
             vMul,  @"icons",
             vMul,  @"icon-bundles",
             vMul,  @"icon-files",
             // Click
             vOne,  @"click-path",
             vMul,  @"click-args",
             nil] autorelease];
}

@end
