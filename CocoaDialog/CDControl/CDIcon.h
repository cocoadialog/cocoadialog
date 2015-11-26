


#import "CDCommon.h"
#import "CDPanel.h"

@interface CDIcon : CDCommon

@property NSImageView *control;
@property CDPanel *panel;

- (void) addControl:control;

@property (readonly, copy) NSArray *controls;
@property (readonly, copy) NSImage *icon, *iconWithDefault;
@property (readonly, copy) NSData *iconData, *iconDataWithDefault;

- (NSImage*) iconFromFile:(NSString*)file;
- (NSImage*) iconFromName:(NSString*)name;

- (void) setIconFromOptions;
@end
