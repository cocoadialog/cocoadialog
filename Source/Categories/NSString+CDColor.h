#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CDColor.h"

extern BOOL NSStringCDColor;

@interface NSString (CDColor)

#pragma mark - Storage
@property (nonatomic) CDColor *color;
@property (nonatomic) NSString *originalString;

#pragma mark - Background colors
@property (nonatomic, readonly) NSString *onBlack;
@property (nonatomic, readonly) NSString *onRed;
@property (nonatomic, readonly) NSString *onGreen;
@property (nonatomic, readonly) NSString *onYellow;
@property (nonatomic, readonly) NSString *onBlue;
@property (nonatomic, readonly) NSString *onMagenta;
@property (nonatomic, readonly) NSString *onCyan;
@property (nonatomic, readonly) NSString *onWhite;

#pragma mark - Foreground colors
@property (nonatomic, readonly) NSString *black;
@property (nonatomic, readonly) NSString *red;
@property (nonatomic, readonly) NSString *green;
@property (nonatomic, readonly) NSString *yellow;
@property (nonatomic, readonly) NSString *blue;
@property (nonatomic, readonly) NSString *magenta;
@property (nonatomic, readonly) NSString *cyan;
@property (nonatomic, readonly) NSString *white;
@property (nonatomic, readonly) NSString *lightBlack;
@property (nonatomic, readonly) NSString *lightRed;
@property (nonatomic, readonly) NSString *lightGreen;
@property (nonatomic, readonly) NSString *lightYellow;
@property (nonatomic, readonly) NSString *lightBlue;
@property (nonatomic, readonly) NSString *lightMagenta;
@property (nonatomic, readonly) NSString *lightCyan;
@property (nonatomic, readonly) NSString *lightWhite;

#pragma mark - Styles
@property (nonatomic, readonly) NSString *bold;
@property (nonatomic, readonly) NSString *dim;
@property (nonatomic, readonly) NSString *italic;
@property (nonatomic, readonly) NSString *underline;
@property (nonatomic, readonly) NSString *blink;
@property (nonatomic, readonly) NSString *swap;

#pragma mark - Clearing
@property (nonatomic, readonly) NSString *clearAll;
@property (nonatomic, readonly) NSString *clearFg;
@property (nonatomic, readonly) NSString *clearBg;
@property (nonatomic, readonly) NSString *clearStyles;
@property (nonatomic, readonly) NSString *removeColor;

#pragma mark - Stopping
@property (nonatomic, readonly) NSString *stop;

#pragma mark - Public instance methods
- (NSString *)applyColor:(CDColor *)color;
- (NSString *)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex ignoreColor:(BOOL)ignoreColor;

@end
