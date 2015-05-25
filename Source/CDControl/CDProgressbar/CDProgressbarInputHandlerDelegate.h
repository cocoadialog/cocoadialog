//
//  CDProgressbarInputHandlerDelegate.h
//  cocoaDialog
//
//  Created by Alexey Ermakov on 22.09.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CDProgressbarInputHandlerDelegate <NSObject>

-(void) updateProgress:(NSNumber *)newProgress;
-(void) updateLabel:(NSString *)newLabel;
-(void) setStopEnabled:(NSNumber *)enabled;
-(void) finish;

@end

/* EOF */
