//
//  CDSlider.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/31/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDSlider.h"

@implementation CDSlider

- (NSDictionary *) availableKeys
{
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
//	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    
	return [NSDictionary dictionaryWithObjectsAndKeys:
            vOne,   @"empty-value",
            vOne,   @"max",
            vOne,   @"min",
            vNone,  @"return-float",
            vOne,   @"ticks",
            vNone,  @"always-show-value",
            vOne,   @"slider-label",
            vOne,   @"value",
            nil];
}

- (BOOL) validateOptions {
    // Check that we're in the right sub-class
    if (![self isMemberOfClass:[CDSlider class]]) {
        if ([options hasOpt:@"debug"]) {
			[self debug:@"This run-mode is not properly classed."];
		}
        return NO;
    }
	// Check that at least button1 has been specified
	if (![options optValue:@"button1"])	{
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least --button1"];
		}
		return NO;
	}
    // Check that the --min value has been specified
	if (![options optValue:@"min"])	{
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply the --min value for the slider"];
		}
		return NO;
	}
    else {
        min = [[options optValue:@"min"] doubleValue];
    }
    // Check that the --max value has been specified
	if (![options optValue:@"max"])	{
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply the --max value for the slider"];
		}
		return NO;
	}
    else {
        max = [[options optValue:@"max"] doubleValue];
    }
    if ([options hasOpt:@"value"]) {
        value = [[options optValue:@"value"] doubleValue];
        if (value < min || value > max) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"The provided value for the option --value cannot be smaller than --min or greater than --max"];
            }
            return NO;
        }
    }
    else {
        value = min;
    }
    if ([options hasOpt:@"empty-value"]) {
        emptyValue = [[options optValue:@"empty-value"] doubleValue];
        if (emptyValue < min || emptyValue > max) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"The provided value for the option --empty-value cannot be smaller than --min or greater than --max"];
            }
            return NO;
        }
    }
    else {
        emptyValue = min;
    }
    if ([options hasOpt:@"ticks"]) {
        ticks = [[options optValue:@"ticks"] intValue];
        if (ticks < min || ticks > max) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"The provided value for the option --ticks cannot be smaller than --min or greater than --max"];
            }
            return NO;
        }
    }
    else {
        if (max > 5) {
            ticks = 5;
        }
        else {
            ticks = max;
        }
    }
    // Everything passed
    return YES;
}

- (BOOL)isReturnValueEmpty {
    return ([[controlMatrix cellAtRow:0 column:0] doubleValue] == emptyValue);
}

- (NSString *) returnValueEmptyText {
    return [NSString stringWithFormat:@"The value for the slider must be greater than: %i", [[controlMatrix cellAtRow:0 column:0] intValue]];
}

- (void) createControl {
	[self setTitleButtonsLabel:[options optValue:@"label"]];
}

- (void) controlHasFinished:(int)button {
    if ([options hasOpt:@"return-float"]) {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%.2f", [[controlMatrix cellAtRow:0 column:0] doubleValue]]];
    }
    else {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%i", [[controlMatrix cellAtRow:0 column:0] intValue]]];
    }
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {    
    NSWindow *_panel = [panel panel];
    NSRect cmFrame = [controlMatrix frame];
    
    NSView *sliderView = [[NSView alloc] initWithFrame:NSMakeRect(cmFrame.origin.x, (cmFrame.origin.y + cmFrame.size.height) - 17.0f, cmFrame.size.width, 14.0f)];
    [sliderView setAutoresizingMask:NSViewMinYMargin|NSViewWidthSizable];
    
    NSString *_sliderLabel = @"Choose value:";
    if ([options hasOpt:@"slider-label"] && ![[options optValue:@"slider-label"] isEqualToString:@""]) {
        _sliderLabel = [options optValue:@"slider-label"];
    }
    sliderLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, cmFrame.size.width, 14.0f)] autorelease];
    [sliderLabel setBezeled:NO];
    [sliderLabel setDrawsBackground:NO];
    [sliderLabel setEditable:NO];
    [sliderLabel setSelectable:NO];
    [sliderLabel setAlignment:NSLeftTextAlignment];
    [sliderLabel setStringValue:_sliderLabel];
    [sliderLabel setAutoresizingMask:NSViewMinYMargin|NSViewWidthSizable];
    [sliderView addSubview:sliderLabel];
    
    valueLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, cmFrame.size.width, 14.0f)] autorelease];
    [valueLabel setBezeled:NO];
    [valueLabel setDrawsBackground:NO];
    [valueLabel setEditable:NO];
    [valueLabel setSelectable:NO];
    [valueLabel setAlignment:NSRightTextAlignment];
    [valueLabel setFont:[NSFont fontWithName:[[valueLabel font] fontName] size:10.0f]];
    [valueLabel setAutoresizingMask:NSViewMinYMargin|NSViewWidthSizable];
    if (![options hasOpt:@"always-show-value"])
        [valueLabel setHidden:YES];
    [sliderView addSubview:valueLabel];
    
    [[_panel contentView] addSubview:sliderView];    
    
    // Set other attributes of matrix
    [controlMatrix setCellSize:NSMakeSize(cmFrame.size.width, 22.0f)];
    [controlMatrix renewRows:1 columns:1];
    [controlMatrix setAutosizesCells:YES];
    [controlMatrix setMode:NSTrackModeMatrix];
    [controlMatrix setAllowsEmptySelection:YES];
    
    CDSliderCell *slider = [[[CDSliderCell alloc] init] autorelease];
    [slider setAlwaysShowValue:[options hasOpt:@"always-show-value"]];
    [slider setDelegate:self];
    [slider setValueLabel:valueLabel];
    [slider setMinValue:min];
    [slider setMaxValue:max];
    [slider setDoubleValue:value];
    [slider setNumberOfTickMarks:ticks];
    [slider setContinuous:YES];
    [slider setTarget:self];
    [slider setAction:@selector(sliderChanged)];
    [controlMatrix putCell:slider atRow:0 column:0];
    
    // Save controlMatrix height
    CGFloat oldHeight = cmFrame.size.height;

    // Resize controlMatrix
    [controlMatrix sizeToCells];
    cmFrame = [controlMatrix frame];
    
    [icon addControl:sliderView];
    [icon addControl:controlMatrix];
        
    if (ticks > 0) {
        NSView *tickView = [[NSView alloc] initWithFrame:NSMakeRect(cmFrame.origin.x, cmFrame.origin.y - (cmFrame.size.height - oldHeight) - 17.0f, cmFrame.size.width, 18.0f)];
        [tickView setAutoresizesSubviews:YES];
        [tickView setAutoresizingMask:NSViewMinYMargin|NSViewWidthSizable];
            
        NSUInteger count = [slider numberOfTickMarks];
        for (NSUInteger i = 0; i < count; i++) {
            CGFloat  length=cmFrame.size.width-2*6;
            CGFloat  position=floor((count==1)?length/2:i*(length/(count-1)));
            NSTextField *tickLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(6.0f + position, 0, 0, 0)] autorelease];
            [tickLabel setBezeled:NO];
            [tickLabel setDrawsBackground:NO];
            [tickLabel setEditable:NO];
            [tickLabel setSelectable:NO];
            [tickLabel setStringValue:[NSString stringWithFormat:@"%i", (int)[slider tickMarkValueAtIndex:i]]];
            [tickLabel setFont:[NSFont fontWithName:[[tickLabel font] fontName] size:10.0f]];
            [tickLabel setAlignment:NSRightTextAlignment];
            [tickLabel sizeToFit];
            // Center the label on the tick
            NSPoint labelOrigin = [tickLabel frame].origin;
            if (i == 0) {
                labelOrigin.x = 6.0f;
                [tickLabel setAutoresizingMask:NSViewMinYMargin];
            }
            else if (i == (count - 1)) {
                labelOrigin.x = [tickView frame].size.width - [tickLabel frame].size.width - 6.0f;
                [tickLabel setAutoresizingMask:NSViewWidthSizable];
            }
            else {
                labelOrigin.x -= floor([tickLabel frame].size.width / 2.0f);
                [tickLabel setAutoresizingMask:NSViewMinXMargin|NSViewMaxXMargin];
            }
            [tickLabel setFrameOrigin:labelOrigin];
            [tickView addSubview:tickLabel];
        }
        [icon addControl:tickView];
        [[_panel contentView] addSubview:tickView];
                
    }

    [self sliderChanged];
}

- (void) sliderChanged {
    NSSlider *slider = [controlMatrix cellAtRow:0 column:0];
    // Update the label
    NSString *label = @"";
    if ([options hasOpt:@"return-float"]) {
        label = [NSString stringWithFormat:@"%.2f", [slider doubleValue]];
    }
    else {
        label = [NSString stringWithFormat:@"%i", [slider intValue]];
    }
    [valueLabel setStringValue:label];    
}

@end

@implementation CDSliderCell
@synthesize alwaysShowValue;
@synthesize delegate;
@synthesize valueLabel;

- (BOOL) trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
    if (!alwaysShowValue)
        [valueLabel setHidden:NO];
    return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
    if ([self numberOfTickMarks] > 0)
        tracking = YES;
    return [super startTrackingAt:startPoint inView:controlView];
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint 
                  inView:(NSView *)controlView {
    if (tracking) {
        NSUInteger count = [self numberOfTickMarks];
        CGFloat snapFlexibility = (100 / count) / 2;
        for (NSUInteger i = 0; i < count; i++) {
            NSRect tickMarkRect = [self rectOfTickMarkAtIndex:i];
            if (ABS(tickMarkRect.origin.x - currentPoint.x) <= snapFlexibility) {
                [self setAllowsTickMarkValuesOnly:YES];
                
            } else if (ABS(tickMarkRect.origin.x - currentPoint.x) >= snapFlexibility &&
                       ABS(tickMarkRect.origin.x - currentPoint.x) <= snapFlexibility * 2) {
                [self setAllowsTickMarkValuesOnly:NO];
            }
        }
    }
    [delegate performSelector:[self action]];
    return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
    if (!alwaysShowValue)
        [valueLabel setHidden:YES];
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}


@end
