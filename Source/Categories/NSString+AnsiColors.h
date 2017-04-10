#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern BOOL NSStringAnsiColors;

typedef NS_ENUM(int, AnsiBg) {
    AnsiBgBlack = 40,
    AnsiBgRed,
    AnsiBgGreen,
    AnsiBgYellow,
    AnsiBgBlue,
    AnsiBgMagenta,
    AnsiBgCyan,
    AnsiBgWhite,
    AnsiBgDefault = 49,
};

typedef NS_ENUM(int, AnsiFg) {
    AnsiFgBlack = 30,
    AnsiFgRed,
    AnsiFgGreen,
    AnsiFgYellow,
    AnsiFgBlue,
    AnsiFgMagenta,
    AnsiFgCyan,
    AnsiFgWhite,
    AnsiFgDefault = 39,
    AnsiFgLightBlack = 90,
    AnsiFgLightRed,
    AnsiFgLightGreen,
    AnsiFgLightYellow,
    AnsiFgLightBlue,
    AnsiFgLightMagenta,
    AnsiFgLightCyan,
    AnsiFgLightWhite,
};

typedef NS_ENUM(int, AnsiStyle) {
    AnsiStyleDefault = 0,
    AnsiStyleBold = 1,
    AnsiStyleDim = 2,
    AnsiStyleItalic = 3,
    AnsiStyleUnderline = 4,
    AnsiStyleBlink = 5,
    AnsiStyleSwap = 7,
};

@interface NSString (AnsiColors)

// Storage.
@property (nonatomic) AnsiBg ansiBg;
@property (nonatomic) AnsiFg ansiFg;
@property (nonatomic) NSMutableArray *ansiStyles;
@property (nonatomic) NSString *ansiOriginal;

// Background colors.
@property (nonatomic, readonly) NSString *onBlack;
@property (nonatomic, readonly) NSString *onRed;
@property (nonatomic, readonly) NSString *onGreen;
@property (nonatomic, readonly) NSString *onYellow;
@property (nonatomic, readonly) NSString *onBlue;
@property (nonatomic, readonly) NSString *onMagenta;
@property (nonatomic, readonly) NSString *onCyan;
@property (nonatomic, readonly) NSString *onWhite;

// Foreground colors.
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

// Styles.
@property (nonatomic, readonly) NSString *bold;
@property (nonatomic, readonly) NSString *dim;
@property (nonatomic, readonly) NSString *italic;
@property (nonatomic, readonly) NSString *underline;
@property (nonatomic, readonly) NSString *blink;
@property (nonatomic, readonly) NSString *swap;

// Clearing.
@property (nonatomic, readonly) NSString *clearAll;
@property (nonatomic, readonly) NSString *clearFg;
@property (nonatomic, readonly) NSString *clearBg;
@property (nonatomic, readonly) NSString *clearStyles;
@property (nonatomic, readonly) NSString *removeAnsi;

// Stopping.
@property (nonatomic, readonly) NSString *stopAnsi;

-(NSString *)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex ignoreAnsi:(BOOL)ignoreAnsi;

@end
