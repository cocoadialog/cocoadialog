/* KABubbleWindow from Colloquy (colloquy.info).
 * I think they got this from an old version of Growl (growl.info).
 */

#import <Cocoa/Cocoa.h>

@interface KABubbleWindow : NSWindow
{
	NSPoint startingPoint;
}

- (instancetype)initWithContentRect:(NSRect)contentRect
				styleMask:(unsigned long)aStyle
				  backing:(NSBackingStoreType)bufferingType
					defer:(BOOL)flag NS_DESIGNATED_INITIALIZER;
@end
