
#import "CDOptions.h"

@interface CDCommon : NSObject

@property CDOptions * options;

- (void) debug:(NSString*)message;

- initWithOptions:(CDOptions*)newOptions;

@end
