


#import "CDCommon.h"

@interface CDPanel : CDCommon

@property IBOutlet NSPanel *panel;

- (void) addMinHeight:(CGFloat)height;
- (void)  addMinWidth:(CGFloat)width;

@property (readonly) NSSize findNewSize;
@property (readonly) BOOL needsResize;

- (void) resize;
- (void) setFloat;
- (void) setPanelEmpty;
- (void) setPosition;
- (void) setTitle;
- (void) setTitle:(NSString*)string;

@end
