// CDProgressbarInputHandler.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.
//
// Created by Alexey Ermakov on 19.09.2011.

@class CDProgressbarInputHandler;

#define CDProgressbarMAX 100.0f
#define CDProgressbarMIN 0.0f

@interface CDProgressbarInputHandler : NSOperation {
    id delegate;

@private
    NSMutableData *buffer;
    BOOL finished;
    double currentProgress;
    NSString *currentLabel;
}

-(BOOL) parseString:(NSString *)str intoProgress:(double *)value;
-(void) setDelegate:(id)newDelegate;
-(void) updateProgress:(double)newProgress;
@end

/* EOF */
