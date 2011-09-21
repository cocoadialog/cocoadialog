//
//  CDCheckboxControl.h
//  CocoaDialog
//
//  Created by Mark Carver on 9/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDThreeButtonControl.h"

@interface CDCheckboxControl : CDThreeButtonControl {
    IBOutlet NSView * controlView;
    NSMutableArray * checkboxes;
}

@end
