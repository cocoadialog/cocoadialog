/* KABubbleWindow from Colloquy (colloquy.info).
 * I think they got this from an old version of Growl (growl.info).
 */
#import "KABubbleWindow.h"

@implementation KABubbleWindow

- (instancetype)initWithContentRect:(NSRect)contentRect
				styleMask:(unsigned long)aStyle
				  backing:(NSBackingStoreType)bufferingType
					defer:(BOOL)flag {
	
	//use NSWindow to draw for us
	NSWindow* result = [super initWithContentRect:contentRect 
										styleMask:NSBorderlessWindowMask 
										  backing:NSBackingStoreBuffered 
											defer:NO];
	
	//set up our window
	[result setBackgroundColor: [NSColor clearColor]];
	[result setLevel: NSStatusWindowLevel];
	[result setAlphaValue:0.15];
	[result setOpaque:NO];
	[result setHasShadow: YES];
	[result setCanHide:NO ];
	
	return (id)result;
}

@end
