//
//  CDSlider.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/31/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDSlider.h"

@implementation CDSlider

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag                name:@"always-show-value"]];
    [options addOption:[CDOptionSingleString        name:@"empty-value"]];
    [options addOption:[CDOptionSingleNumber        name:@"max"]];
    [options addOption:[CDOptionSingleNumber        name:@"min"]];
    [options addOption:[CDOptionFlag                name:@"return-float"]];
    [options addOption:[CDOptionSingleNumber        name:@"ticks"]];
    [options addOption:[CDOptionSingleString        name:@"slider-label"]];
    [options addOption:[CDOptionFlag                name:@"sticky"]];
    [options addOption:[CDOptionSingleNumber        name:@"value"]];

    // Make the following options required.
    options[@"button1"].required = YES;
    options[@"max"].required = YES;
    options[@"min"].required = YES;

    return options;
}

- (BOOL) validateOptions {
    BOOL pass = [super validateOptions];

    min = option[@"min"].doubleValue;
    max = option[@"max"].doubleValue;

    // Determine the current value.
    if (option[@"value"].wasProvided) {
        value = option[@"value"].doubleValue;
        if (value < min || value > max) {
            [self warning:@"The provided value for the option --value cannot be smaller than --min or greater than --max. Using the --min value: %f", min, nil];
            value = min;
        }
    }
    else {
        value = min;
    }

    // Determine what constitutes an "empty" value.
    if (option[@"empty-value"].wasProvided) {
        emptyValue = option[@"empty-value"].doubleValue;
        if (emptyValue < min || emptyValue > max) {
            [self warning:@"The provided value for the option --empty-value cannot be smaller than --min or greater than --max. Using the --min value: %f", min, nil];
        }
    }
    else {
        emptyValue = min;
    }

    // Determine the number of ticks.
    double defaultTicks = max > 5 ? 5 : max;
    if (option[@"ticks"].wasProvided) {
        ticks = option[@"ticks"].unsignedIntegerValue;
        if (ticks < min || ticks > max) {
            [self warning:@"The provided value for the option --ticks cannot be smaller than --min or greater than --max. Using the default --ticks value: %f", defaultTicks, nil];
            ticks = defaultTicks;
        }
    }
    else {
        ticks = defaultTicks;
    }

    return pass;
}

- (BOOL)isReturnValueEmpty {
    return ([controlMatrix cellAtRow:0 column:0].doubleValue == emptyValue);
}

- (NSString *) returnValueEmptyText {
    return [NSString stringWithFormat:@"The value for the slider must be greater than: %i", [controlMatrix cellAtRow:0 column:0].intValue];
}

- (void) createControl {
    [self setTitleButtonsLabel:option[@"label"].stringValue];
}

- (void) controlHasFinished:(int)button {
    if (option[@"return-float"].wasProvided) {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%.2f", [controlMatrix cellAtRow:0 column:0].doubleValue]];
    }
    else {
        [controlReturnValues addObject:[NSString stringWithFormat:@"%i", [controlMatrix cellAtRow:0 column:0].intValue]];
    }
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {
    NSWindow *_panel = panel.panel;
    NSRect cmFrame = controlMatrix.frame;
    
    NSView *sliderView = [[[NSView alloc] initWithFrame:NSMakeRect(cmFrame.origin.x, (cmFrame.origin.y + cmFrame.size.height) - 17.0f, cmFrame.size.width, 14.0f)] autorelease];
    sliderView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin;

    NSString *_sliderLabel = NSLocalizedString(@"SLIDER_DEFAULT_LABEL", nil);
    if (option[@"slider-label"].wasProvided && ![option[@"slider-label"].stringValue isBlank]) {
        _sliderLabel = option[@"slider-label"].stringValue;
    }
    sliderLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, cmFrame.size.width, 14.0f)] autorelease];
    [sliderLabel setBezeled:NO];
    [sliderLabel setDrawsBackground:NO];
    [sliderLabel setEditable:NO];
    [sliderLabel setSelectable:NO];
    sliderLabel.alignment = NSLeftTextAlignment;
    sliderLabel.stringValue = _sliderLabel;
    [sliderView addSubview:sliderLabel];

    valueLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, cmFrame.size.width, 14.0f)] autorelease];
    [valueLabel setBezeled:NO];
    [valueLabel setDrawsBackground:NO];
    [valueLabel setEditable:NO];
    [valueLabel setSelectable:NO];
    valueLabel.alignment = NSRightTextAlignment;
    valueLabel.font = [NSFont fontWithName:valueLabel.font.fontName size:10.0f];
    if (!option[@"always-show-value"].wasProvided) {
        [valueLabel setHidden:YES];
    }
    [sliderView addSubview:valueLabel];
    
    [_panel.contentView addSubview:sliderView];
    
    // Move controlMatrix to make room for valueView
    NSPoint cmOrigin = cmFrame.origin;
    cmOrigin.y -= sliderView.frame.size.height - 8.0f;
    [controlMatrix setFrameOrigin:cmOrigin];
    
    // Add the valueView to the panel height
    NSSize panelSize = panel.panel.contentView.frame.size;
    panelSize.height += sliderView.frame.size.height + 4.0f;
    [panel.panel setContentSize:panelSize];
    [panel resize];
    
    // Set other attributes of matrix
    controlMatrix.cellSize = NSMakeSize(cmFrame.size.width, 22.0f);
    [controlMatrix renewRows:1 columns:1];
    [controlMatrix setAutosizesCells:NO];
    controlMatrix.mode = NSTrackModeMatrix;
    [controlMatrix setAllowsEmptySelection:YES];
    
    CDSliderCell *slider = [[[CDSliderCell alloc] init] autorelease];
    slider.alwaysShowValue = option[@"always-show-value"].boolValue;
    slider.delegate = self;
    slider.valueLabel = valueLabel;
    slider.minValue = min;
    slider.maxValue = max;
    slider.doubleValue = value;
    slider.numberOfTickMarks = ticks;
    slider.sticky = option[@"sticky"].boolValue;
    [slider setContinuous:YES];
    slider.target = self;
    slider.action = @selector(sliderChanged);
    [controlMatrix putCell:slider atRow:0 column:0];
    
    // Save controlMatrix height
    CGFloat oldHeight = cmFrame.size.height;

    // Resize controlMatrix
    [controlMatrix sizeToCells];
    cmFrame = controlMatrix.frame;
        
    if (ticks > 0) {
        NSView *tickView = [[[NSView alloc] initWithFrame:NSMakeRect(0.0f, cmFrame.origin.y - (cmFrame.size.height - oldHeight) - 17.0f, _panel.frame.size.width, 18.0f)] autorelease];
        tickView.autoresizingMask = NSViewMinYMargin;
            
        NSUInteger count = slider.numberOfTickMarks;
        for (NSUInteger i = 0; i < count; i++) {
            CGFloat  length=cmFrame.size.width-2*10;
            CGFloat  position=floor((count==1)?length/2:i*(length/(count-1)));
            NSTextField *tickLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(cmFrame.origin.x + 10.0f + position, 0, 0, 0)] autorelease];
            [tickLabel setBezeled:NO];
            [tickLabel setDrawsBackground:NO];
            [tickLabel setEditable:NO];
            [tickLabel setSelectable:NO];
            tickLabel.stringValue = [NSString stringWithFormat:@"%i", (int)[slider tickMarkValueAtIndex:i]];
            tickLabel.font = [NSFont fontWithName:tickLabel.font.fontName size:10.0f];
            [tickLabel sizeToFit];
            // Center the label on the tick
            NSPoint labelOrigin = tickLabel.frame.origin;
            labelOrigin.x -= floor(tickLabel.frame.size.width / 2.0f);
            [tickLabel setFrameOrigin:labelOrigin];
            [tickView addSubview:tickLabel];
        }
        [_panel.contentView addSubview:tickView];
        
        // Move controlMatrix to make room for tickView
        cmOrigin = cmFrame.origin;
        cmOrigin.y += tickView.frame.size.height + 4.0f;
        [controlMatrix setFrameOrigin:cmOrigin];
        
        // Add the tickView to the panel height
        panelSize = panel.panel.contentView.frame.size;
        panelSize.height += tickView.frame.size.height + 4.0f;
        [panel.panel setContentSize:panelSize];
        [panel resize];
    }

    [self sliderChanged];
}

- (void) sliderChanged {
    CDSliderCell *slider = [controlMatrix cellAtRow:0 column:0];
    // Update the label
    NSString *label = @"";
    if (option[@"return-float"].wasProvided) {
        label = [NSString stringWithFormat:@"%.2f", slider.doubleValue];
    }
    else {
        label = [NSString stringWithFormat:@"%i", slider.intValue];
    }
    valueLabel.stringValue = label;    
}

@end

@implementation CDSliderCell
@synthesize alwaysShowValue;
@synthesize delegate;
@synthesize sticky;
@synthesize valueLabel;

- (void)dealloc {
    [delegate release];
    [valueLabel release];
    [super dealloc];
}

- (BOOL) trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
    if (!alwaysShowValue)
        [valueLabel setHidden:NO];
    return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
    if (self.numberOfTickMarks > 0)
        tracking = YES;
    return [super startTrackingAt:startPoint inView:controlView];
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint
                  inView:(NSView *)controlView {
    if (tracking && sticky) {
        NSUInteger count = self.numberOfTickMarks;
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
    else {
        [self setAllowsTickMarkValuesOnly:NO];
    }
    [delegate performSelector:self.action];
    return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
    if (!alwaysShowValue)
        [valueLabel setHidden:YES];
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}


@end
