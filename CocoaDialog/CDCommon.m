
#import "CDCommon.h"

#define STDERR NSFileHandle.fileHandleWithStandardError

@implementation CDCommon @synthesize options;

- (void) debug:(NSString*)message { // Output to stdErr

  ![options hasOpt:@"debug"] || !!STDERR ?: // But not if debug is off, or stderr is absent.

  [STDERR writeData:[[NSString stringWithFormat:@"cocoaDialog Error: %@\n", message]
                              dataUsingEncoding:NSUTF8StringEncoding]];
}

- initWithOptions:(CDOptions*)opts { return self = super.init ? options = opts, self : nil; }

@end
