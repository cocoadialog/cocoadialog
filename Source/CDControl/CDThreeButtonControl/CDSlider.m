//
//  CDSlider.m
//  CocoaDialog
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
            vNone,  @"ticks-sticky",
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
        if (!(value >= min) && !(value <= max)) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"The provided value for the option --value cannot be smaller than --min and greater than --max"];
            }
            return NO;
        }
    }
    else {
        value = min;
    }
    if ([options hasOpt:@"empty-value"]) {
        emptyValue = [[options optValue:@"empty-value"] doubleValue];
        if (!(emptyValue >= min) && !(emptyValue <= max)) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"The provided value for the option --empty-value cannot be smaller than --min and greater than --max"];
            }
            return NO;
        }
    }
    else {
        emptyValue = min;
    }
    if ([options hasOpt:@"ticks"]) {
        ticks = [[options optValue:@"ticks"] intValue];
        if (!(ticks >= min) && !(ticks <= max)) {
            if ([options hasOpt:@"debug"]) {
                [self debug:@"The provided value for the option --ticks cannot be smaller than --min and greater than --max"];
            }
            return NO;
        }
    }
    else {
        ticks = (int)(max - min);
        if (ticks == max)
            ticks++;
    }
    // Everything passed
    return YES;
}

- (BOOL)isReturnValueEmpty {
    return ([[controlMatrix cellAtRow:1 column:0] doubleValue] == emptyValue);
}

- (NSString *) returnValueEmptyText {
    return [NSString stringWithFormat:@"The value for the slider must be greater than: %i", [[controlMatrix cellAtRow:1 column:0] intValue]];
}

- (void) createControl {
	[self setTitleButtonsLabel:[options optValue:@"label"]];
}

- (void) controlHasFinished:(int)button {
    if ([options hasOpt:@"return-float"]) {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%.2f", [[controlMatrix cellAtRow:1 column:0] doubleValue]]];
    }
    else {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%i", [[controlMatrix cellAtRow:1 column:0] intValue]]];
    }
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {
    // Set other attributes of matrix
    [controlMatrix setCellSize:NSMakeSize([controlMatrix frame].size.width, 22.0f)];
    [controlMatrix renewRows:2 columns:1];
    [controlMatrix setAutosizesCells:NO];
    [controlMatrix setMode:NSTrackModeMatrix];
    [controlMatrix setAllowsEmptySelection:YES];
    
    NSTextField *sliderLabel = [[[NSTextField alloc] init] autorelease];
    [sliderLabel setBezeled:NO];
    [sliderLabel setDrawsBackground:NO];
    [sliderLabel setEditable:NO];
    [sliderLabel setSelectable:NO];
    [sliderLabel setAlignment:NSRightTextAlignment];
    [sliderLabel setFont:[NSFont fontWithName:[[sliderLabel font] fontName] size:10.0f]];
    [controlMatrix putCell:[sliderLabel cell] atRow:0 column:0];

    NSSlider *slider = [[[NSSlider alloc] init] autorelease];
    [slider setMinValue:min];
    [slider setMaxValue:max];
    [slider setDoubleValue:value];
    [slider setNumberOfTickMarks:ticks];
    [slider setTarget:self];
    [slider setAction:@selector(updateLabel)];
    if (ticks > 0 && [options hasOpt:@"ticks-sticky"]) {
        [slider setAllowsTickMarkValuesOnly:YES];
    }
    [controlMatrix putCell:[slider cell] atRow:1 column:0];

    [self updateLabel];
}

- (void) updateLabel {
    NSString *label = @"";
    if ([options hasOpt:@"return-float"]) {
        label = [NSString stringWithFormat:@"%.2f", [[controlMatrix cellAtRow:1 column:0] doubleValue]];
    }
    else {
        label = [NSString stringWithFormat:@"%i", [[controlMatrix cellAtRow:1 column:0] intValue]];
    }
    [[controlMatrix cellAtRow:0 column:0] setTitle:label];    
}


@end
