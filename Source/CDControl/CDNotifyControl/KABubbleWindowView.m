/* KABubbleWindowView.m from Colloquy <colloquy.info>.
 * Modified for cocoaDialog <cocoadialog.sf.net>.
 * I think they got this from an old version of Growl <growl.info>.
 */
#import "KABubbleWindowView.h"

// info needs to be a KABubbleWindowView with rgb+alpha set:
void KABubbleShadeInterpolate(void *info, CGFloat const *inData, CGFloat *outData) {
	// These 2 will always return an array of 4 floats:
	const CGFloat *dark = [(KABubbleWindowView *)info darkColorFloat];
	const CGFloat *light = [(KABubbleWindowView *)info lightColorFloat];
	CGFloat a = inData[0];
	int i = 0;

	for (i = 0; i < 4; i++) {
		outData[i] = (((1.0f - a) * dark[i]) + (a * light[i]));
    }
}

#pragma mark -

@implementation KABubbleWindowView
- (id) initWithFrame:(NSRect) frame {
	if (self == [super initWithFrame:frame]) {
		_icon = nil;
		_title = nil;
		_text = nil;
		_target = nil;
		_action = NULL;
		_darkColor = nil;
		_lightColor = nil;
		_textColor = nil;
		_borderColor = nil;
	}
	return self;
}

- (void) dealloc {
	[_icon release];
	[_title release];
	[_text release];
	[_darkColor release];
	[_lightColor release];
	[_textColor release];
	[_borderColor release];

	_icon = nil;
	_title = nil;
	_text = nil;
	_target = nil;
	_darkColor = nil;
	_lightColor = nil;
	_textColor = nil;
	_borderColor = nil;

	[super dealloc];
}

- (void) drawRect:(NSRect) rect {
	[[NSColor clearColor] set];
	NSRectFill([self frame]);

	float lineWidth = 4.0f;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path setLineWidth:lineWidth];

	float radius = 9.0f;
	NSRect irect = NSInsetRect([self bounds], (radius + lineWidth),
                               (radius + lineWidth));
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(irect),
                                                        NSMinY(irect))
                                     radius:radius
                                 startAngle:180.0f
                                   endAngle:270.0f];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(irect),
                                                        NSMinY(irect))
                                     radius:radius
                                 startAngle:270.0f
                                   endAngle:360.0f];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(irect),
                                                        NSMaxY(irect))
                                     radius:radius
                                 startAngle:0.0f
                                   endAngle:90.0f];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(irect),
                                                        NSMaxY(irect))
                                     radius:radius
                                 startAngle:90.0f
                                   endAngle:180.0f];
	[path closePath];

	[[NSGraphicsContext currentContext] saveGraphicsState];

	[path setClip];

	struct CGFunctionCallbacks callbacks = {
        0U, (CGFunctionEvaluateCallback)KABubbleShadeInterpolate,
        (CGFunctionReleaseInfoCallback)NULL
    };
	CGFunctionRef function = CGFunctionCreate(self, 1, NULL, 4, NULL,
                                              &callbacks);
	CGColorSpaceRef cspace = CGColorSpaceCreateDeviceRGB();

	float srcX = (float)NSMinX([self bounds]);
    float srcY = (float)NSMinY([self bounds]);
	float dstX = (float)NSMinX([self bounds]);
    float dstY = (float)NSMaxY([self bounds]);
	CGShadingRef shading = CGShadingCreateAxial(cspace,
                                                CGPointMake(srcX, srcY),
                                                CGPointMake(dstX, dstY),
                                                function, false, false);

	CGContextDrawShading([[NSGraphicsContext currentContext] graphicsPort],
                         shading);

	CGShadingRelease(shading);
	CGColorSpaceRelease(cspace);
	CGFunctionRelease(function);

	[[NSGraphicsContext currentContext] restoreGraphicsState];

	[[self borderColor] set];
	[path stroke];

	[_title drawAtPoint:NSMakePoint(55.0f, 40.0f)
         withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:13.0f], NSFontAttributeName, [self textColor], NSForegroundColorAttributeName, nil]];
	[_text drawInRect:NSMakeRect(55.0f, 10.0f, 200.0f, 30.0f)];

	if (([_icon size].width > 32.0f) || ([_icon size].height > 32.0f)) { // Assume a square image:
		NSImageRep *sourceImageRep = [_icon bestRepresentationForDevice:nil];
		[_icon autorelease];
		_icon = [[NSImage alloc] initWithSize:NSMakeSize(32.0f, 32.0f)];
		[_icon lockFocus];
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		[sourceImageRep drawInRect:NSMakeRect(0.0f, 0.0f, 32.0f, 32.0f)];
		[_icon unlockFocus];
	}

	[_icon compositeToPoint:NSMakePoint(15.0f, 20.0f)
                  operation:NSCompositeSourceAtop
                   fraction:1.0f];

	[[self window] invalidateShadow];
}

#pragma mark -

- (void) setIcon:(NSImage *) icon {
	[_icon autorelease];
	_icon = [icon retain];
	[self setNeedsDisplay:YES];
}

- (void) setTitle:(NSString *) title {
	[_title autorelease];
	_title = [title copy];
	[self setNeedsDisplay:YES];
}

- (void) setAttributedText:(NSAttributedString *) text {
	[_text autorelease];
	_text = [text copy];
	[self setNeedsDisplay:YES];
}

// Either use setAttributedText, or setTextColor THEN setText (in order)
- (void) setText:(NSString *) text {
	[_text autorelease];
	NSColor *color = nil;
	if ([self textColor] != nil) {
		color = [self textColor];
	} else {
		color = [NSColor controlTextColor];
	}
	_text = [[NSAttributedString alloc] initWithString:text
                                            attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont messageFontOfSize:11.0f], NSFontAttributeName, color, NSForegroundColorAttributeName, nil]];
	[self setNeedsDisplay:YES];
}

- (void) setDarkColor:(NSColor *)color
{
	[color retain];
	[_darkColor release];
	_darkColor = color;

	CGFloat r, g, b, alpha;
	NSColor *rgb = [_darkColor colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"];
	[rgb getRed:&r green:&g blue:&b alpha:&alpha];
	_darkColorFloat[0] = r;
	_darkColorFloat[1] = g;
	_darkColorFloat[2] = b;
	_darkColorFloat[3] = alpha;
}

- (NSColor *) darkColor
{
	return _darkColor;
}

- (const CGFloat *) darkColorFloat
{
	return _darkColorFloat;
}

- (void) setLightColor:(NSColor *)color
{
	[color retain];
	[_lightColor release];
	_lightColor = color;

	CGFloat r, g, b, alpha;
	NSColor *rgb = [_lightColor colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"];
	[rgb getRed:&r green:&g blue:&b alpha:&alpha];
	_lightColorFloat[0] = r;
	_lightColorFloat[1] = g;
	_lightColorFloat[2] = b;
	_lightColorFloat[3] = alpha;
}

- (NSColor *) lightColor
{
	return _lightColor;
}

- (const CGFloat *) lightColorFloat
{
	return _lightColorFloat;
}

- (void) setTextColor:(NSColor *)color
{
	[color retain];
	[_textColor release];
	_textColor = color;
}

- (NSColor *) textColor
{
	return _textColor;
}

- (void) setBorderColor:(NSColor *)color
{
	[color retain];
	[_borderColor release];
	_borderColor = color;
}

- (NSColor *) borderColor
{
	return _borderColor;
}

#pragma mark -

- (id) target {
	return _target;
}

- (void) setTarget:(id) object {
	_target = object;
}

#pragma mark -

- (SEL) action {
	return _action;
}

- (void) setAction:(SEL) selector {
	_action = selector;
}


#pragma mark -

- (void) mouseUp:(NSEvent *) event {
	if (_target && _action && [_target respondsToSelector:_action])
		[_target performSelector:_action withObject:self];
}
@end

/* EOF */
