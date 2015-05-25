/* KABubbleWindowController.m from Colloquy <colloquy.info>.
 * Modified for cocoaDialog <cocoadialog.sf.net>.
 * I think they got this from an old version of Growl <growl.info>.
 */
#import "KABubbleWindowController.h"
#import "KABubbleWindowView.h"

static unsigned int bubbleWindowDepth = 0U;

@implementation KABubbleWindowController

#define TIMER_INTERVAL (1.0f / 30.0f)
#define FADE_INCREMENT 0.05f
#define KABubblePadding 10.0f

#pragma mark -

/* Some good default values:
		lightColor:[NSColor colorWithCalibratedRed:.93725 green:.96863 blue:.99216 alpha:.95]
		darkColor:[NSColor colorWithCalibratedRed:.69412 green:.83147 blue:.96078 alpha:.95]
		textColor:[NSColor controlTextColor]
		borderColor:[NSColor controlTextColor]
*/

+ (KABubbleWindowController *) bubbleWithTitle:(NSString *) title
	text:(id) text icon:(NSImage *) icon timeout:(float) timeout
	lightColor:(NSColor *)lightColor darkColor:(NSColor *)darkColor
	textColor:(NSColor *)textColor borderColor:(NSColor *)borderColor
							numExpectedBubbles:(int)numExpected
								bubblePosition:(unsigned int)position
{
	id ret = [[[self alloc] initWithTextColor:textColor darkColor:darkColor lightColor:lightColor borderColor:borderColor numExpectedBubbles:numExpected bubblePosition:position] autorelease];
	[ret setTitle:title];
	[ret setTimeout:timeout];
	if( [text isKindOfClass:[NSString class]] ) [ret setText:text];
	else if( [text isKindOfClass:[NSAttributedString class]] ) [ret setAttributedText:text];
	[ret setIcon:icon];
	return ret;
}

#if 0
extern unsigned int bubbleWindowDepth;
#endif /* 0 */

- (id) initWithTextColor:(NSColor *)textColor
			   darkColor:(NSColor *)darkColor
			  lightColor:(NSColor *)lightColor
			 borderColor:(NSColor *)borderColor
	  numExpectedBubbles:(int)numExpected
		  bubblePosition:(unsigned int)position
{
	NSPanel *panel = [[[NSPanel alloc] initWithContentRect:NSMakeRect(0.0f, 0.0f, 270.0f, 65.0f)
                                                 styleMask:NSBorderlessWindowMask
                                                   backing:NSBackingStoreBuffered
                                                     defer:NO] autorelease];
	[panel setBecomesKeyOnlyIfNeeded:YES];
	[panel setHidesOnDeactivate:NO];
	[panel setBackgroundColor:[NSColor clearColor]];
	[panel setLevel:NSStatusWindowLevel];
	[panel setAlphaValue:0.0f];
	[panel setOpaque:NO];
	[panel setHasShadow:YES];
	[panel setCanHide:NO];
	[panel setReleasedWhenClosed:YES];
	[panel setDelegate:self];

	KABubbleWindowView *view = [[[KABubbleWindowView alloc] initWithFrame:[panel frame]] autorelease];
	[view setTarget:self];
	[view setAction:@selector( _bubbleClicked: )];
	[view setDarkColor:darkColor];
	[view setLightColor:lightColor];
	[view setTextColor:textColor];
	[view setBorderColor:borderColor];

	[panel setContentView:view];

	NSRect screen = [[NSScreen mainScreen] visibleFrame];

	float leftPoint = 0.0f;
	float topPoint = 0.0f;
	// Find left position for bubble:
	if (position & BUBBLE_HORIZ_LEFT) {
		leftPoint = (float)(NSMinX(screen) + KABubblePadding);
	} else if (position & BUBBLE_HORIZ_CENTER) {
		leftPoint = (float)(((NSWidth(screen) - NSWidth([panel frame]))
                             / 2.0f) - KABubblePadding);
	} else if (position & BUBBLE_HORIZ_RIGHT) {
		leftPoint = (float)(NSWidth(screen) - NSWidth([panel frame])
                            - KABubblePadding);
	}
	// Find top position for bubble:
	if (position & BUBBLE_VERT_TOP) {
		topPoint = (float)(NSMaxY(screen) - KABubblePadding
                           - (NSHeight([panel frame])
                              * bubbleWindowDepth));
	} else if (position & BUBBLE_VERT_CENTER) {
		topPoint = (float)((NSMaxY(screen) / 1.8f)
                           - (NSHeight([panel frame]) * bubbleWindowDepth)
                           + ((NSHeight([panel frame]) * numExpected)
                              / 2.0f));
	} else if (position & BUBBLE_VERT_BOTTOM) {
		topPoint = (float)(NSMinY(screen) + KABubblePadding
                           + (NSHeight([panel frame])
                              * (bubbleWindowDepth + 1)));
	}

	[panel setFrameTopLeftPoint:NSMakePoint(leftPoint, topPoint)];

	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self
                                                                     selector:@selector(_applicationDidSwitch:)
                                                                         name:NSApplicationDidBecomeActiveNotification
                                                                       object:[NSApplication sharedApplication]];
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self
                                                                     selector:@selector(_applicationDidSwitch:)
                                                                         name:NSApplicationDidHideNotification
                                                                       object:[NSApplication sharedApplication]];

    self = [super initWithWindow:panel];

	_depth = ++bubbleWindowDepth;
	_autoFadeOut = YES;
	_delegate = nil;
	_target = nil;
	_representedObject = nil;
	_action = NULL;
    _clickContext = nil;
	_animationTimer = nil;

	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[_target release];
	[_representedObject release];
	[_animationTimer invalidate];
	[_animationTimer release];

    _clickContext = nil;
	_target = nil;
	_representedObject = nil;
	_delegate = nil;
	_animationTimer = nil;

	if (_depth == bubbleWindowDepth) bubbleWindowDepth = 0;

	[super dealloc];
}

#pragma mark -

- (void) _stopTimer {
	[_animationTimer invalidate];
	[_animationTimer release];
	_animationTimer = nil;
}

- (void) _waitBeforeFadeOut {
	[self _stopTimer];
	_animationTimer = [[NSTimer scheduledTimerWithTimeInterval:_timeout target:self selector:@selector( startFadeOut ) userInfo:nil repeats:NO] retain];
}

- (void) _fadeIn:(NSTimer *) inTimer {
	if ([[self window] alphaValue] < 1.0f) {
		[[self window] setAlphaValue:[[self window] alphaValue] + FADE_INCREMENT];
	} else if (_autoFadeOut) {
		if ([_delegate respondsToSelector:@selector(bubbleDidFadeIn:)])
			[_delegate bubbleDidFadeIn:self];
		[self _waitBeforeFadeOut];
	}
}

- (void) _fadeOut:(NSTimer *) inTimer {
	if ([[self window] alphaValue] > 0.0f) {
		[[self window] setAlphaValue:[[self window] alphaValue] - FADE_INCREMENT];
	} else {
		[self _stopTimer];
		if ([_delegate respondsToSelector:@selector(bubbleDidFadeOut:)]) {
			[_delegate bubbleDidFadeOut:self];
        }
		[self close];
		[self autorelease]; // Relase, we retained when we faded in.
	}
}

- (void) _applicationDidSwitch:(NSNotification *) notification {
	// We are ifdef-ing this out for cocoaDialog, since this gets
	// called immediately after we fire it up, due to our
	// non-standard way of running the app:
#if 0
	[self startFadeOut];
#endif /* 0 */
}

- (void) _bubbleClicked:(id) sender {
    if ((_clickContext != nil) && [_delegate respondsToSelector:@selector(bubbleWasClicked:)]) {
        [_delegate bubbleWasClicked:_clickContext];
    }
	[self startFadeOut];
}

#pragma mark -

- (void) startFadeIn {
	if( [_delegate respondsToSelector:@selector(bubbleWillFadeIn:)])
		[_delegate bubbleWillFadeIn:self];
	[self retain]; // Retain, after fade out we release.
	[self showWindow:nil];
	[self _stopTimer];
	_animationTimer = [[NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                        target:self
                                                      selector:@selector(_fadeIn:)
                                                      userInfo:nil
                                                       repeats:YES] retain];
}

- (void) startFadeOut {
	if ([_delegate respondsToSelector:@selector(bubbleWillFadeOut:)]) {
        [_delegate bubbleWillFadeOut:self];
    }
	[self _stopTimer];
	_animationTimer = [[NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                        target:self
                                                      selector:@selector(_fadeOut:)
                                                      userInfo:nil
                                                       repeats:YES] retain];
}

#pragma mark -

- (BOOL) automaticallyFadesOut {
	return _autoFadeOut;
}

- (void) setAutomaticallyFadesOut:(BOOL) autoFade {
	_autoFadeOut = autoFade;
}

#pragma mark -

- (id) target {
	return _target;
}

- (void) setTarget:(id) object {
	[_target autorelease];
	_target = [object retain];
}

#pragma mark -

- (SEL) action {
	return _action;
}

- (void) setAction:(SEL) selector {
	_action = selector;
}

#pragma mark -

- (id) clickContext {
	return _clickContext;
}

- (void) setClickContext:(id) object {
	_clickContext = object;
}

#pragma mark -

- (id) representedObject {
	return _representedObject;
}

- (void) setRepresentedObject:(id) object {
	[_representedObject autorelease];
	_representedObject = [object retain];
}

#pragma mark -

- (id) delegate {
	return _delegate;
}

- (void) setDelegate:(id) delegate {
	_delegate = delegate;
}

#pragma mark -

- (BOOL) respondsToSelector:(SEL) selector {
	if ([[[self window] contentView] respondsToSelector:selector]) return YES;
	else return [super respondsToSelector:selector];
}

- (void) forwardInvocation:(NSInvocation *) invocation {
	if ([[[self window] contentView] respondsToSelector:[invocation selector]])
		[invocation invokeWithTarget:[[self window] contentView]];
	else [super forwardInvocation:invocation];
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL) selector {
	if ([[[self window] contentView] respondsToSelector:selector])
		return [(NSObject *)[[self window] contentView] methodSignatureForSelector:selector];
	else return [super methodSignatureForSelector:selector];
}


#pragma mark -
- (void) setTimeout:(float) timeout
{
	_timeout = timeout;
}
- (float) timeout
{
	return _timeout;
}

@end

/* EOF */
