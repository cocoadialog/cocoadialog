
@import Dialogs;

#include <stdio.h>

int main(int argc, const char * argv[]) { @autoreleasepool {

  [NSApplication sharedApplication];

  printf("Available Controls:\n");

  for (id x  in CDControl.availableControls)
    printf("%s\n",[x description].UTF8String);


  //    CDProgressbarControl *x = [CDProgressbarControl.alloc initWithOptions:nil];
  CDOptions *x = CDOptions.new;
  x[@"button1"] = @"ok";
  x[@"text"] = @"whatever";
  x[@"informative-text"] = @"Enter your search term";
  CDInputboxControl *i = [CDInputboxControl.alloc initWithOptions:x];
  CDTextboxControl  __unused *j = [CDTextboxControl.alloc  initWithOptions:x];
  CDInputboxControl __unused *k = [CDInputboxControl.alloc initWithOptions:x];

  [i validateOptions];
  [i loadControlNib:i.controlNib];

  // Create the control
  [i createControl];
  [NSApp activateIgnoringOtherApps:YES];

    // Initialize the timer, if one exists
    //        [i setTimeout];d    //      [AZSHAREDAPP activateIgnoringOtherApps:YES];
    // Run the control. The control is now responsible for terminating cocoaDialog, which should be invoked by calling the method [self stopControl] from the control's action method(s).
    //        [[i vFK:@"controlPanel"] makeKeyAndOrderFront:nil];
//    [AZSHAREDAPP activateIgnoringOtherApps:YES];


    [i runControl];
    [[i valueForKey:@"controlPanel"] makeKeyAndOrderFront:nil];
//      [[i vFK:@"controlPanel"] setKey:nil]
//    [i print];
//    [i runControl];
    [NSApp run];


} return 0; }
