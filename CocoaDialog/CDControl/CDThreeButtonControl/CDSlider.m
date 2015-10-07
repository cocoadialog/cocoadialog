//
//  CDSlider.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/31/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDSlider.h"

@implementation CDSlider

- (NSDictionary*) availableKeys
{
  NSNumber *vNone = @CDOptionsNoValues;
  NSNumber *vOne = @CDOptionsOneValue;
  //	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];

  return @{@"empty-value": vOne,
           @"max": vOne,
           @"min": vOne,
           @"return-float": vNone,
           @"ticks": vOne,
           @"always-show-value": vNone,
           @"slider-label": vOne,
           @"value": vOne};
}

- (BOOL) validateOptions {
  // Check that we're in the right sub-class
  if (![self isMemberOfClass:[CDSlider class]]) {
    if ([self.options hasOpt:@"debug"]) {
      [self debug:@"This run-mode is not properly classed."];
    }
    return NO;
  }
  // Check that at least button1 has been specified
  if (![self.options optValue:@"button1"])	{
    if ([self.options hasOpt:@"debug"]) {
      [self debug:@"Must supply at least --button1"];
    }
    return NO;
  }
  // Check that the --min value has been specified
  if (![self.options optValue:@"min"])	{
    if ([self.options hasOpt:@"debug"]) {
      [self debug:@"Must supply the --min value for the slider"];
    }
    return NO;
  }
  else {
    min = [[self.options optValue:@"min"] doubleValue];
  }
  // Check that the --max value has been specified
  if (![self.options optValue:@"max"])	{
    if ([self.options hasOpt:@"debug"]) {
      [self debug:@"Must supply the --max value for the slider"];
    }
    return NO;
  }
  else {
    max = [[self.options optValue:@"max"] doubleValue];
  }
  if ([self.options hasOpt:@"value"]) {
    value = [[self.options optValue:@"value"] doubleValue];
    if (value < min || value > max) {
      if ([self.options hasOpt:@"debug"]) {
        [self debug:@"The provided value for the option --value cannot be smaller than --min or greater than --max"];
      }
      return NO;
    }
  }
  else {
    value = min;
  }
  if ([self.options hasOpt:@"empty-value"]) {
    emptyValue = [[self.options optValue:@"empty-value"] doubleValue];
    if (emptyValue < min || emptyValue > max) {
      if ([self.options hasOpt:@"debug"]) {
        [self debug:@"The provided value for the option --empty-value cannot be smaller than --min or greater than --max"];
      }
      return NO;
    }
  }
  else {
    emptyValue = min;
  }
  if ([self.options hasOpt:@"ticks"]) {
    ticks = [[self.options optValue:@"ticks"] intValue];
    if (ticks < min || ticks > max) {
      if ([self.options hasOpt:@"debug"]) {
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

- (NSString*) returnValueEmptyText {
  return [NSString stringWithFormat:@"The value for the slider must be greater than: %i", [[controlMatrix cellAtRow:0 column:0] intValue]];
}

- (void) createControl {
  [self setTitleButtonsLabel:[self.options optValue:@"label"]];
}

- (void) controlHasFinished:(int)button {

  [self.options hasOpt:@"return-float"]
  ? [controlReturnValues addObject:[NSString stringWithFormat:@"%.2f", [[controlMatrix cellAtRow:0 column:0] doubleValue]]]
  : [controlReturnValues addObject:[NSString stringWithFormat:@"%i", [[controlMatrix cellAtRow:0 column:0] intValue]]];
  [super controlHasFinished:button];
}

- (void) setControl:(id)sender {

  NSWindow *_panel = self.panel.panel;
  NSRect cmFrame = controlMatrix.frame;

  NSView *sliderView = [NSView.alloc initWithFrame:NSMakeRect(cmFrame.origin.x, (cmFrame.origin.y + cmFrame.size.height) - 17.0f, cmFrame.size.width, 14.0f)];
  [sliderView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin];

  NSString *_sliderLabel = @"Choose a value:";
  if ([self.options hasOpt:@"slider-label"] && ![[self.options optValue:@"slider-label"] isEqualToString:@""]) {
    _sliderLabel = [self.options optValue:@"slider-label"];
  }
  sliderLabel = [NSTextField.alloc initWithFrame:NSMakeRect(0, 0, cmFrame.size.width, 14.0f)];
  [sliderLabel setBezeled:NO];
  [sliderLabel setDrawsBackground:NO];
  [sliderLabel setEditable:NO];
  [sliderLabel setSelectable:NO];
  [sliderLabel setAlignment:NSLeftTextAlignment];
  [sliderLabel setStringValue:_sliderLabel];
  [sliderView addSubview:sliderLabel];

  valueLabel = [NSTextField.alloc initWithFrame:NSMakeRect(0, 0, cmFrame.size.width, 14.0f)];
  [valueLabel setBezeled:NO];
  [valueLabel setDrawsBackground:NO];
  [valueLabel setEditable:NO];
  [valueLabel setSelectable:NO];
  [valueLabel setAlignment:NSRightTextAlignment];
  [valueLabel setFont:[NSFont fontWithName:[[valueLabel font] fontName] size:10.0f]];
  if (![self.options hasOpt:@"always-show-value"])
    [valueLabel setHidden:YES];
  [sliderView addSubview:valueLabel];

  [[_panel contentView] addSubview:sliderView];

  // Move controlMatrix to make room for valueView
  NSPoint cmOrigin = cmFrame.origin;
  cmOrigin.y -= [sliderView frame].size.height - 8.0f;
  [controlMatrix setFrameOrigin:cmOrigin];

  // Add the valueView to the panel height
  NSSize panelSize = [self.panel.panel.contentView frame].size;
  panelSize.height += [sliderView frame].size.height + 4.0f;
  [self.panel.panel setContentSize:panelSize];
  [self.panel resize];

  // Set other attributes of matrix
  [controlMatrix setCellSize:NSMakeSize(cmFrame.size.width, 22.0f)];
  [controlMatrix renewRows:1 columns:1];
  [controlMatrix setAutosizesCells:NO];
  [controlMatrix setMode:NSTrackModeMatrix];
  [controlMatrix setAllowsEmptySelection:YES];

  CDSliderCell *slider = CDSliderCell.new;
  [slider setAlwaysShowValue:[self.options hasOpt:@"always-show-value"]];
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

  if (ticks > 0) {
    NSView *tickView = [NSView.alloc initWithFrame:NSMakeRect(0.0f, cmFrame.origin.y - (cmFrame.size.height - oldHeight) - 17.0f, [_panel frame].size.width, 18.0f)];
    [tickView setAutoresizingMask:NSViewMinYMargin];

    NSUInteger count = [slider numberOfTickMarks];
    for (NSUInteger i = 0; i < count; i++) {
      CGFloat  length=cmFrame.size.width-2*10;
      CGFloat  position=floor((count==1)?length/2:i*(length/(count-1)));
      NSTextField *tickLabel = [NSTextField.alloc initWithFrame:NSMakeRect(cmFrame.origin.x + 10.0f + position, 0, 0, 0)];
      [tickLabel setBezeled:NO];
      [tickLabel setDrawsBackground:NO];
      [tickLabel setEditable:NO];
      [tickLabel setSelectable:NO];
      [tickLabel setStringValue:[NSString stringWithFormat:@"%i", (int)[slider tickMarkValueAtIndex:i]]];
      [tickLabel setFont:[NSFont fontWithName:[[tickLabel font] fontName] size:10.0f]];
      [tickLabel sizeToFit];
      // Center the label on the tick
      NSPoint labelOrigin = [tickLabel frame].origin;
      labelOrigin.x -= floor([tickLabel frame].size.width / 2.0f);
      [tickLabel setFrameOrigin:labelOrigin];
      [tickView addSubview:tickLabel];
    }
    [[_panel contentView] addSubview:tickView];

    // Move controlMatrix to make room for tickView
    cmOrigin = cmFrame.origin;
    cmOrigin.y += [tickView frame].size.height + 4.0f;
    [controlMatrix setFrameOrigin:cmOrigin];

    // Add the tickView to the panel height
    panelSize = [self.panel.panel.contentView frame].size;
    panelSize.height += [tickView frame].size.height + 4.0f;
    [self.panel.panel setContentSize:panelSize];
    [self.panel resize];
  }

  [self sliderChanged];
}

- (void) sliderChanged {
  NSSlider *slider = [controlMatrix cellAtRow:0 column:0];
  // Update the label
  NSString *label = @"";
  if ([self.options hasOpt:@"return-float"]) {
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

- (BOOL) trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView*)controlView untilMouseUp:(BOOL)flag {
  if (!alwaysShowValue)
    [valueLabel setHidden:NO];
  return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView*)controlView {
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

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView*)controlView mouseIsUp:(BOOL)flag {
  if (!alwaysShowValue)
    [valueLabel setHidden:YES];
  [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}


@end