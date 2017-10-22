// CDSliderView.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDSliderView.h"

IB_DESIGNABLE

@implementation CDSliderView

- (void)initView {
  [super initView];

//    NSString *_sliderLabel = @"OPTION_SLIDER_DEFAULT_LABEL".localized;
//    if (option[@"slider-label"].wasProvided && ![option[@"slider-label"].stringValue isBlank]) {
//        _sliderLabel = option[@"slider-label"].stringValue;
//    }
//    sliderLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, cmFrame.size.width, 14.0f)];
//    [sliderLabel setBezeled:NO];
//    [sliderLabel setDrawsBackground:NO];
//    [sliderLabel setEditable:NO];
//    [sliderLabel setSelectable:NO];
//    sliderLabel.alignment = NSLeftTextAlignment;
//    sliderLabel.stringValue = _sliderLabel;
//    [sliderView addSubview:sliderLabel];
//
//    valueLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, cmFrame.size.width, 14.0f)];
//    [valueLabel setBezeled:NO];
//    [valueLabel setDrawsBackground:NO];
//    [valueLabel setEditable:NO];
//    [valueLabel setSelectable:NO];
//    valueLabel.alignment = NSRightTextAlignment;
//    valueLabel.font = [NSFont fontWithName:valueLabel.font.fontName size:10.0f];
//    if (!option[@"always-show-value"].wasProvided) {
//        [valueLabel setHidden:YES];
//    }
//    [sliderView addSubview:valueLabel];
//
//    [self.panel.contentView addSubview:sliderView];
//
//
//    self.slider.alwaysShowValue = option[@"always-show-value"].boolValue;
//    self.slider.delegate = self;
//    slider.valueLabel = valueLabel;
//    slider.minValue = min;
//    slider.maxValue = max;
//    slider.doubleValue = value;
//    slider.numberOfTickMarks = ticks;
//    slider.sticky = option[@"sticky"].boolValue;
//    [slider setContinuous:YES];
//    slider.target = self;
//    slider.action = @selector(sliderChanged);
//
//    [self.controlView addSubview:slider];
//
//    // Save self.controlView height
//    CGFloat oldHeight = cmFrame.size.height;
//    cmFrame = self.controlView.frame;
//
//    if (ticks > 0) {
//        NSView *tickView = [[NSView alloc] initWithFrame:NSMakeRect(0.0f, cmFrame.origin.y - (cmFrame.size.height - oldHeight) - 17.0f, self.panel.frame.size.width, 18.0f)];
//        tickView.autoresizingMask = NSViewMinYMargin;
//
//        NSUInteger count = slider.numberOfTickMarks;
//        for (NSUInteger i = 0; i < count; i++) {
//            CGFloat  length=cmFrame.size.width-2*10;
//            CGFloat  position=floor((count==1)?length/2:i*(length/(count-1)));
//            NSTextField *tickLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(cmFrame.origin.x + 10.0f + position, 0, 0, 0)];
//            [tickLabel setBezeled:NO];
//            [tickLabel setDrawsBackground:NO];
//            [tickLabel setEditable:NO];
//            [tickLabel setSelectable:NO];
//            tickLabel.stringValue = [NSString stringWithFormat:@"%i", (int)[slider tickMarkValueAtIndex:i]];
//            tickLabel.font = [NSFont fontWithName:tickLabel.font.fontName size:10.0f];
//            [tickLabel sizeToFit];
//            // Center the label on the tick
//            NSPoint labelOrigin = tickLabel.frame.origin;
//            labelOrigin.x -= floor(tickLabel.frame.size.width / 2.0f);
//            [tickLabel setFrameOrigin:labelOrigin];
//            [tickView addSubview:tickLabel];
//        }
//        [self.panel.contentView addSubview:tickView];
//
//        // Move matrix to make room for tickView
//        cmOrigin = cmFrame.origin;
//        cmOrigin.y += tickView.frame.size.height + 4.0f;
//        [matrix setFrameOrigin:cmOrigin];
//
//        // Add the tickView to the panel height
//        panelSize = self.panel.contentView.frame.size;
//        panelSize.height += tickView.frame.size.height + 4.0f;
//        [self.panel setContentSize:panelSize];
//        [self resize];
//    }

  [self sliderChanged];
}

- (void)sliderChanged {
//    CDSliderCell *slider = [matrix cellAtRow:0 column:0];
//    // Update the label
//    NSString *label = @"";
//    if (option[@"return-float"].wasProvided) {
//        label = [NSString stringWithFormat:@"%.2f", slider.doubleValue];
//    }
//    else {
//        label = [NSString stringWithFormat:@"%i", slider.intValue];
//    }
//    valueLabel.stringValue = label;
}

@end

@implementation CDSliderCell

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
  if (!self.alwaysShowValue)
    [self.valueLabel setHidden:NO];
  return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
  if (self.numberOfTickMarks > 0)
    self.tracking = YES;
  return [super startTrackingAt:startPoint inView:controlView];
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint
                  inView:(NSView *)controlView {
  if (self.tracking && self.sticky) {
    NSUInteger count = (NSUInteger) self.numberOfTickMarks;
    CGFloat snapFlexibility = (100 / count) / 2;
    for (NSUInteger i = 0; i < count; i++) {
      NSRect tickMarkRect = [self rectOfTickMarkAtIndex:i];
      if (ABS(tickMarkRect.origin.x - currentPoint.x) <= snapFlexibility) {
        [self setAllowsTickMarkValuesOnly:YES];

      }
      else if (ABS(tickMarkRect.origin.x - currentPoint.x) >= snapFlexibility &&
        ABS(tickMarkRect.origin.x - currentPoint.x) <= snapFlexibility * 2) {
        [self setAllowsTickMarkValuesOnly:NO];
      }
    }
  }
  else {
    [self setAllowsTickMarkValuesOnly:NO];
  }

  // Fix "may cause leak" warning.
  // @see http://stackoverflow.com/a/20058585/1226717
  if (self.delegate) {
    IMP imp = [self.delegate methodForSelector:self.action];
    void (*func)(id, SEL) = (void *) imp;
    func(self.delegate, self.action);
  }

  return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
  if (!self.alwaysShowValue)
    [self.valueLabel setHidden:YES];
  [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}


@end
