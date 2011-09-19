//
//  CDProgressbarInputHandler.h
//  CocoaDialog
//
//  Created by Alexey Ermakov on 19.09.2011.
//

#import <Foundation/Foundation.h>
#import "CDProgressbarControl.h"

#define CDProgressbarMAX 100.0
#define CDProgressbarMIN 0.0

@interface CDProgressbarInputHandler : NSOperation {
    CDProgressbarControl *delegate;

@private
    NSMutableData *buffer;
    BOOL finished;
    double currentProgress;
    NSString *currentLabel;
}

-(BOOL) parseString:(NSString*)str intoProgress:(double*)value;
-(void) setDelegate:(CDProgressbarControl*)newDelegate;
@end