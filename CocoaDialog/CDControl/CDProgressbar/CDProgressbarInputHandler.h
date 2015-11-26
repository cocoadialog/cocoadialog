
@import Foundation;
#import "CDProgressbarInputHandlerDelegate.h"

#define CDProgressbarMAX 100.0
#define CDProgressbarMIN 0.0

@interface CDProgressbarInputHandler : NSOperation {
    id delegate;

@private
    NSMutableData *buffer;
    BOOL finished;
    double currentProgress;
    NSString *currentLabel;
}

-(BOOL) parseString:(NSString*)str intoProgress:(double*)value;
-(void) setDelegate:(id)newDelegate;
@end