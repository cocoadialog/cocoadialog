
@import AppKit;
@import Dialogs;

int main(int argc, const char * argv[]) {
  @autoreleasepool {


  for (id x  in CDControl.availableControls)
    NSLog(@"%@",x);

  }
    return 0;
}
