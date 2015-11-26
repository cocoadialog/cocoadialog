
#import "CDThreeButtonControl.h"

@implementation CDPopUpButtonControl

- (NSDictionary*) availableKeys
{
  NSNumber *vOne = @CDOptionsOneValue;
  NSNumber *vNone = @CDOptionsNoValues;
  NSNumber *vMul = @CDOptionsMultipleValues;

  return @{@"items": vMul,
           @"selected": vOne,
           @"exit-onchange": vNone,
           @"pulldown": vNone};
}

- (NSDictionary*) depreciatedKeys
{
  return @{@"text": @"label"};
}

- (BOOL) validateOptions {

  // Check that we're in the right sub-class
  if (![self isMemberOfClass:CDPopUpButtonControl.class] ||
      ![self isMemberOfClass:CDStandardPopUpButtonControl.class])
      return [self debug:@"This run-mode is not properly classed."], NO;

  // Check that at least button1 has been specified
  if (![self.options optValue:@"button1"] && ![self isMemberOfClass:CDStandardPopUpButtonControl.class])
    return [self debug:@"Must supply at least --button1"], NO;

  // Check that at least one item has been specified
  NSArray *items = [NSArray arrayWithArray:[self.options optValues:@"items"]];
  if (!items.count) return [self debug:@"Must supply at least one --items"], NO;

  // Load nib
  if (![NSBundle loadNibNamed:@"popup" owner:self]) return [self debug:@"Could not load popup.nib"], NO;

  // Everything passed
  return YES;
}

- (NSString*) controlNib {
  return @"popup";
}

- (void) createControl {
  [self.panel addMinWidth:self.popupControl.frame.size.width];
  [self.controlItems addObject:self.popupControl];
  [self.icon addControl:self.popupControl];
  // Setup the control
  [self.popupControl setKeyEquivalent:@" "];
  [self.popupControl setTarget:self];
  [self.popupControl setAction:@selector(selectionChanged:)];
  [self.popupControl removeAllItems];
  // Set popup/pulldown style
  [self.popupControl setPullsDown:[self.options hasOpt:@"pulldown"] ? YES : NO];
  // Populate menu
  NSArray *items = [NSArray arrayWithArray:[self.options optValues:@"items"]];
  if (items != nil && [items count]) {
    NSEnumerator *en = [items objectEnumerator];
    id obj;
    while (obj = [en nextObject]) {
      [self.popupControl addItemWithTitle:(NSString *)obj];
    }
    NSInteger selected = [self.options hasOpt:@"selected"] ? [[self.options optValue:@"selected"] integerValue] : 0;
    [self.popupControl selectItemAtIndex:selected];
  }
  [self setTitleButtonsLabel:[self.options optValue:@"label"]];
}

- (void) controlHasFinished:(int)button {

  [self.controlReturnValues addObject:[self.options hasOpt:@"string-output"]
                                     ? self.popupControl.titleOfSelectedItem
                                     : @(self.popupControl.indexOfSelectedItem).stringValue];
  [super controlHasFinished:button];
}

- (void) selectionChanged:sender {

  [self.popupControl synchronizeTitleAndSelectedItem];
  if ([self.options hasOpt:@"exit-onchange"]) {
    [self setValue:@4 forKey:@"controlExitStatus"];
    [self setValue:@"4" forKey:@"controlExitStatusString"];
    [self.controlReturnValues addObject:[self.options hasOpt:@"string-output"]
                                       ? self.popupControl.titleOfSelectedItem
                                       : @(self.popupControl.indexOfSelectedItem).stringValue];
    [self stopControl];
  }
}


@end
