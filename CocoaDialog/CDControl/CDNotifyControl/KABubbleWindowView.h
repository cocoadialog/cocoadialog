/* KABubbleWindowView.h from Colloquy (colloquy.info).
 * Modified for cocoaDialog (cocoadialog.sf.net).
 * I think they got this from an old version of Growl (growl.info).
 */

@import AppKit;

@interface KABubbleWindowView : NSView
{
  NSAttributedString *_text;
//	SEL _action;
//	id _target;
//	CGFloat _darkColorFloat[4];   // Cache these rather than
//	CGFloat _lightColorFloat[4];  // calculating over and over.
//	NSColor *_darkColor;
//	NSColor *_lightColor;
//	NSColor *_textColor;
//	NSColor *_borderColor;
}
@property (nonatomic, copy) NSImage *icon;
@property (nonatomic, copy) NSString *title;

//- (void) setIcon:(NSImage*) icon;
//- (void) setTitle:(NSString*) title;
- (void) setAttributedText:(NSAttributedString*) text;
- (void) setText:(NSString*) text;

@property (readonly) CGFloat *darkColorFloat, *lightColorFloat; // returns { r, g, b, a }

@property (copy) NSColor *darkColor,*lightColor, *textColor, *borderColor;

@property (assign) id target;

@property  SEL action;

@end
