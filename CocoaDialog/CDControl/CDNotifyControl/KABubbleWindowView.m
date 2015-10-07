/* KABubbleWindowView.m from Colloquy (colloquy.info).
 * Modified for cocoaDialog (cocoadialog.sf.net).
 * I think they got this from an old version of Growl (growl.info).
 */

#import "KABubbleWindowView.h"

// info needs to be a KABubbleWindowView with rgb+alpha set.
void KABubbleShadeInterpolate( void *info, CGFloat *inData, CGFloat *outData ) {
	// These 2 will always return an array of 4 floats
	CGFloat *dark = [(__bridge KABubbleWindowView *)info darkColorFloat];
	CGFloat *light = [(__bridge KABubbleWindowView *)info lightColorFloat];
	CGFloat a = inData[0];
	int i = 0;

	for( i = 0; i < 4; i++ )
		outData[i] = ( 1. - a ) * dark[i] + a * light[i];
}

#pragma mark -

@implementation KABubbleWindowView

- (void) drawRect:(NSRect) rect {
	[NSColor.clearColor set];
	NSRectFill( [self frame] );

	float lineWidth = 4.;
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path setLineWidth:lineWidth];

	float radius = 9.;
	NSRect irect = NSInsetRect( [self bounds], radius + lineWidth, radius + lineWidth );
	[path appendBezierPathWithArcWithCenter:NSMakePoint( NSMinX( irect ), NSMinY( irect ) ) radius:radius startAngle:180. endAngle:270.];
	[path appendBezierPathWithArcWithCenter:NSMakePoint( NSMaxX( irect ), NSMinY( irect ) ) radius:radius startAngle:270. endAngle:360.];
	[path appendBezierPathWithArcWithCenter:NSMakePoint( NSMaxX( irect ), NSMaxY( irect ) ) radius:radius startAngle:0. endAngle:90.];
	[path appendBezierPathWithArcWithCenter:NSMakePoint( NSMinX( irect ), NSMaxY( irect ) ) radius:radius startAngle:90. endAngle:180.];
	[path closePath];

	[[NSGraphicsContext currentContext] saveGraphicsState];

	[path setClip];

	struct CGFunctionCallbacks callbacks = { 0, (void *)KABubbleShadeInterpolate, NULL };
	CGFunctionRef function = CGFunctionCreate( (__bridge void * _Nullable)(self), 1, NULL, 4, NULL, &callbacks );
	CGColorSpaceRef cspace = CGColorSpaceCreateDeviceRGB();

	float srcX = NSMinX( [self bounds] ), srcY = NSMinY( [self bounds] );
	float dstX = NSMinX( [self bounds] ), dstY = NSMaxY( [self bounds] );
	CGShadingRef shading = CGShadingCreateAxial( cspace, CGPointMake( srcX, srcY ), CGPointMake( dstX, dstY ), function, false, false );

	CGContextDrawShading( [[NSGraphicsContext currentContext] graphicsPort], shading );

	CGShadingRelease( shading );
	CGColorSpaceRelease( cspace );
	CGFunctionRelease( function );

	[[NSGraphicsContext currentContext] restoreGraphicsState];

	[[self borderColor] set];
	[path stroke];

	[_title drawAtPoint:NSMakePoint( 55., 40. ) withAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:13.], NSForegroundColorAttributeName: [self textColor]}];
	[_text drawInRect:NSMakeRect( 55., 10., 200., 30. )];

	if( [_icon size].width > 32. || [_icon size].height > 32. ) { // Assume a square image.
		NSImageRep *sourceImageRep = [_icon bestRepresentationForDevice:nil];
//		[_icon autorelease];
		_icon = [NSImage.alloc initWithSize:NSMakeSize( 32., 32. )];
		[_icon lockFocus];
		[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];
		[sourceImageRep drawInRect:NSMakeRect( 0., 0., 32., 32. )];
		[_icon unlockFocus];
	}

	[_icon compositeToPoint:NSMakePoint( 15., 20. ) operation:NSCompositeSourceAtop fraction:1.];

	[[self window] invalidateShadow];
}

#pragma mark -

- (void) setIcon:(NSImage*) icon {
	_icon = icon;
	[self setNeedsDisplay:YES];
}

- (void) setTitle:(NSString*) title {

	_title = [title copy];
	[self setNeedsDisplay:YES];
}

- (void) setAttributedText:(NSAttributedString*) text {

	_text = [text copy];
	[self setNeedsDisplay:YES];
}

// Either use setAttributedText, or setTextColor THEN setText (in order)
- (void) setText:(NSString*) text {

	NSColor *color = nil;
	if ([self textColor] != nil) {
		color = [self textColor];
	} else {
		color = [NSColor controlTextColor];
	}
	_text = [NSAttributedString.alloc initWithString:text attributes:@{NSFontAttributeName: [NSFont messageFontOfSize:11.], NSForegroundColorAttributeName: color}];
	[self setNeedsDisplay:YES];
}

@synthesize darkColorFloat = _darkColorFloat, lightColorFloat = _lightColorFloat;

- (const CGFloat*) darkColorFloat
{
	CGFloat r, g, b, alpha;
	NSColor *rgb = [_darkColor colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"];
	[rgb getRed:&r green:&g blue:&b alpha:&alpha];
	_darkColorFloat[0] = r;
	_darkColorFloat[1] = g;
	_darkColorFloat[2] = b;
	_darkColorFloat[3] = alpha;

	return _darkColorFloat;
}

- (CGFloat*) lightColorFloat {

	CGFloat r, g, b, alpha;
	NSColor *rgb = [_lightColor colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"];
	[rgb getRed:&r green:&g blue:&b alpha:&alpha];
	_lightColorFloat[0] = r;
	_lightColorFloat[1] = g;
	_lightColorFloat[2] = b;
	_lightColorFloat[3] = alpha;
  return _lightColorFloat;
}
#pragma mark -

- (void) mouseUp:(NSEvent*) event {
	if( _target && _action && [_target respondsToSelector:_action] )
		[_target performSelector:_action withObject:self];
}
@end
