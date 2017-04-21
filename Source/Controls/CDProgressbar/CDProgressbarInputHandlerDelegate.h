// CDProgressbarInputHandlerDelegate.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@protocol CDProgressbarInputHandlerDelegate <NSObject>

-(void) updateProgress:(NSNumber*)newProgress;
-(void) updateLabel:(NSString*)newLabel;
-(void) setStopEnabled:(NSNumber*)enabled;
-(void) finish;

@end
