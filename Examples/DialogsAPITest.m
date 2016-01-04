
@import Dialogs;

int main(int argc, const char * argv[]) { @autoreleasepool {

  printf("Available Controls:\n%s", CDControl.availableControls.description.UTF8String);

  CDOptions *opts = [CDOptions optionsWithDictionary:@{ @"button1": @"Button 1",
                                                          @"items": @[@"Checkbox 1 (index 0)"]}];
                                                          
  CDCheckboxControl *check = [CDCheckboxControl.alloc initWithOptions:opts];

//  [check runControl];

  opts                      = CDOptions.new;
  opts[@"button1"]          = @"ok";
  opts[@"text"]             = @"whatever";
  opts[@"informative-text"] = @"Enter your search term";

  [CDControl.availableControls enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

    printf("Instantiating a %s via the %s class\n", [key UTF8String], NSStringFromClass(obj).UTF8String);

    CDControl *i = [(CDControl*)[obj alloc] initWithOptions:opts];

    ![i validateOptions] ?: [i runControl];
  }];

//  CDInputboxControl *i = [CDInputboxControl.alloc initWithOptions:x];
//  CDTextboxControl  *j = [CDTextboxControl.alloc  initWithOptions:x];
//  CDInputboxControl *k = [CDInputboxControl.alloc initWithOptions:x];

//  [CDControl.availableControls en
//  [i runControl];
//  [j runControl];
//  [k runControl];

  //  [i validateOptions];
//  [i loadControlNib:i.controlNib];
  // Create the control
//  [i createControl];


//  [i.panel.panel makeKeyAndOrderFront:nil];
//  [NSApp activateIgnoringOtherApps:YES];

    // Initialize the timer, if one exists
    //        [i setTimeout];d    //      [AZSHAREDAPP activateIgnoringOtherApps:YES];
    // Run the control. The control is now responsible for terminating cocoaDialog, which should be invoked by calling the method [self stopControl] from the control's action method(s).
    //        [[i vFK:@"controlPanel"] makeKeyAndOrderFront:nil];
//    [AZSHAREDAPP activateIgnoringOtherApps:YES];



//    [[i valueForKey:@"controlPanel"] makeKeyAndOrderFront:nil];
//      [[i vFK:@"controlPanel"] setKey:nil]
//    [i print];
//    [i runControl];
    [NSApp run];


} return 0; }

//  CDProgressbarControl *p = [CDProgressbarControl.alloc initWithOptions:
//                              [CDOptions optionsWithDictionary:@{@"button1":@"Button 1", @"items": @[@"Checkbox 1 (index 0)"]}]];
//  [progressbar --percent 0 --stoppable --title $(basename $0) --text "Please wait..." < $PIPE &
  //    CDProgressbarControl *x = [CDProgressbarControl.alloc initWithOptions:nil];
