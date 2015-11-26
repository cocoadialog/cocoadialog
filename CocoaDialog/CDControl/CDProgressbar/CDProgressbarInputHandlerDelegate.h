

@import Foundation;

@protocol CDProgressbarInputHandlerDelegate <NSObject>

-(void) updateProgress:(NSNumber*)newProgress;
-(void) updateLabel:(NSString*)newLabel;
-(void) setStopEnabled:(NSNumber*)enabled;
-(void) finish;

@end
