//
//  main.m
//  relaunch
//
//  Created by Mark Whitaker on 10/12/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.


@import AppKit;
#import <unistd.h>

@interface Relaunch : NSObject {
@private
	NSString *executablePath;
    NSMutableArray *executableArguments;
}
@end

int main (int argc, const char * argv[]) {
  @autoreleasepool {
    id x = [NSApplication sharedApplication];
    [Relaunch new];
    [x run];
    
  }
	return EXIT_SUCCESS;
}

@implementation Relaunch

- init {

	if (!(self = super.init)) return nil;
  executableArguments = NSProcessInfo.processInfo.arguments.mutableCopy;
  // Remove the first three arguments
  if (executableArguments.count >= 2) {
      // Remove relaunch path
      [executableArguments removeObjectAtIndex:0];
      // Set and remove executablePath
      executablePath = executableArguments[0];
      [executableArguments removeObjectAtIndex:0];
      if ([executablePath.pathExtension isEqualToString:@""]) {
          NSTask *task = NSTask.new;
          task.launchPath = @"/usr/bin/arch";
          [executableArguments insertObject:executablePath atIndex:0];
#if defined __ppc__
          [executableArguments insertObject:@"-ppc" atIndex:0];
#elif defined __i368__
          [executableArguments insertObject:@"-i386" atIndex:0];
#elif defined __ppc64__
          [executableArguments insertObject:@"-ppc64" atIndex:0];
#elif defined __x86_64__
          [executableArguments insertObject:@"-x86_64" atIndex:0];
#endif
          [task setArguments:executableArguments];
          [task launch];
      }
      // Relaunch GUI application
      else
          [NSWorkspace.sharedWorkspace openFile:[NSFileManager.defaultManager stringWithFileSystemRepresentation:executablePath.UTF8String length:executablePath.length]];

      exit(0);
  }
	return self;
}

@end
