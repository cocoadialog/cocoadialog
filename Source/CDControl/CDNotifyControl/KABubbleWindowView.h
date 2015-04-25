/* KABubbleWindowView.h from Colloquy (colloquy.info).
 * Modified for cocoaDialog (cocoadialog.sf.net).
 * I think they got this from an old version of Growl (growl.info).
 */
@interface KABubbleWindowView : NSView {
	NSImage *_icon;
	NSString *_title;
	NSAttributedString *_text;
	SEL _action;
	id _target;
	CGFloat _darkColorFloat[4];   // Cache these rather than
	CGFloat _lightColorFloat[4];  // calculating over and over.
	NSColor *_darkColor;
	NSColor *_lightColor;
	NSColor *_textColor;
	NSColor *_borderColor;
}
- (void) setIcon:(NSImage *) icon;
- (void) setTitle:(NSString *) title;
- (void) setAttributedText:(NSAttributedString *) text;
- (void) setText:(NSString *) text;

@property (readonly) const CGFloat *darkColorFloat; // returns { r, g, b, a }
@property (readonly) const CGFloat *lightColorFloat; // returns { r, g, b, a }
@property (copy) NSColor *darkColor;
@property (copy) NSColor *lightColor;
@property (copy) NSColor *textColor;
@property (copy) NSColor *borderColor;

@property (assign) id target;

@property  SEL action;

@end
