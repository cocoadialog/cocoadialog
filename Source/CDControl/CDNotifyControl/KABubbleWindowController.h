/* KABubbleWindowController.h from Colloquy (colloquy.info).
 * Modified for CocoaDialog (cocoadialog.sf.net).
 * I think they got this from an old version of Growl (growl.info).
 */

#define BUBBLE_HORIZ_LEFT   0
#define BUBBLE_HORIZ_CENTER 1
#define BUBBLE_HORIZ_RIGHT  2

#define BUBBLE_VERT_TOP     4
#define BUBBLE_VERT_CENTER  8
#define BUBBLE_VERT_BOTTOM  16

@interface KABubbleWindowController : NSWindowController <NSWindowDelegate> {
	id _delegate;
	NSTimer *_animationTimer;
	unsigned int _depth;
	BOOL _autoFadeOut;
	SEL _action;
    id _clickContext;
	id _target;
	id _representedObject;
	float _timeout;
}

- (id) initWithTextColor:(NSColor *)textColor 
			   darkColor:(NSColor *)darkColor 
			  lightColor:(NSColor *)lightColor 
			 borderColor:(NSColor *)borderColor
	  numExpectedBubbles:(int)numExpected 
		  bubblePosition:(unsigned int)position;

// position is a bitmask of the BUBBLE_* defines
+ (KABubbleWindowController *) bubbleWithTitle:(NSString *) title
                                          text:(id) text
                                          icon:(NSImage *) icon
                                       timeout:(float) timeout
                                    lightColor:(NSColor *) lightColor
                                     darkColor:(NSColor *) darkColor
                                     textColor:(NSColor *) textColor
                                   borderColor:(NSColor *) borderColor
							numExpectedBubbles:(int)numExpected
								bubblePosition:(unsigned int)position;

- (void) startFadeIn;
- (void) startFadeOut;

- (BOOL) automaticallyFadesOut;
- (void) setAutomaticallyFadesOut:(BOOL) autoFade;

- (id) target;
- (void) setTarget:(id) object;

- (SEL) action;
- (void) setAction:(SEL) selector;

- (id) clickContext;
- (void) setClickContext:(id) object;

- (id) representedObject;
- (void) setRepresentedObject:(id) object;

- (id) delegate;
- (void) setDelegate:(id) delegate;

- (void) setTimeout:(float) timeout;
- (float) timeout;

@end

@interface NSObject (KABubbleWindowControllerDelegate)
- (void) bubbleWasClicked:(id)clickContext;

- (void) bubbleWillFadeIn:(KABubbleWindowController *) bubble;
- (void) bubbleDidFadeIn:(KABubbleWindowController *) bubble;

- (void) bubbleWillFadeOut:(KABubbleWindowController *) bubble;
- (void) bubbleDidFadeOut:(KABubbleWindowController *) bubble;
@end
