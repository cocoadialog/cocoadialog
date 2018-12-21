// CDControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDApplication.h"
#import "CDControl.h"
#import "CDColumns.h"
#import "CDTemplate.h"

#pragma mark -
@implementation CDControl

@synthesize app, alias, exitStatus, name, options, returnValues, terminal, template, topLevelObjects, nib;


#pragma mark - Properties
- (BOOL) isBaseControl {
    return [self class] == [CDControl class];
}

+ (NSString *) scope {
    return @"control";
}

#pragma mark - Public static methods
+ (CDOptions *) availableOptions {
    return [CDOptions options].addOptionsToScope(@"global",
  @[
    // Add hidden developement (Xcode) option.
    CDOption.create(CDBoolean,  @"dev").hide(YES),

    // Global options.
    CDOption.create(CDBoolean,  @"color").setDefaultValue(^() {
        return [NSNumber numberWithBool:[CDTerminal sharedInstance].supportsColor];
    }),
    CDOption.create(CDBoolean,  @"debug").addWarning(@"USAGE_OPTION_WARNING_AFFECTS_OUTPUT".localized),
    CDOption.create(CDBoolean,  @"help"),
    CDOption.create(CDString,   @"output").allow(@[@"columns", @"json"]).setDefaultValue(@"columns"),
    CDOption.create(CDBoolean,  @"quiet"),
    CDOption.create(CDNumber,   @"screen").setDefaultValue(^() {
        return [NSNumber numberWithUnsignedInteger:[[NSScreen screens] indexOfObject:[NSScreen mainScreen]]];
    }),
    CDOption.create(CDBoolean,  @"verbose").addWarning(@"USAGE_OPTION_WARNING_AFFECTS_OUTPUT".localized),
    CDOption.create(CDBoolean,  @"version"),
    CDOption.create(CDBoolean,  @"warnings").setDefaultValue(@"YES"),
    ]);
}

+ (instancetype) control {
    return [[self alloc] init];
}

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        app = [CDApplication sharedApplication];
        exitStatus = CDTerminalExitCodeOk;
        options = app.options.processWithControl(self);
        returnValues = @{}.mutableCopy;
        terminal = CDTerminal.sharedInstance;
        template = CDTemplate.sharedInstance;
        topLevelObjects = @[];

        // Allow option to override whether color should be used.
        NSStringCDColor = options[@"color"].boolValue;

        __block CDControl *control = self;
        options.getOptionOnceCallback = ^(CDOption *opt) {
            // Provide some useful debugging information for default/automatic values.
            // Note: this must be added here, after avaialble options have populated in
            // case they access the options themselves to add additional properties like
            // "required" or "defaultValue".
            [control debugOptions:opt];
#ifndef DEBUG
            // If not in Xcode debug mode, force the --dev option to be disabled.
            if ([opt.name isEqualToStringCaseInsensitive:@"dev"]) {
                opt.provided(NO).rawValue(@"NO");
            }
#endif
        };
    }
    return self;
}

- (instancetype) initWithName:(NSString*)aName alias:(CDControlAlias *)anAlias {
    self = [self init];
    if (self) {
        alias = anAlias;
        name = anAlias ? [NSString stringWithFormat:@"%@ (%@)", self.alias.name, aName] : aName;

        if (alias) {
            // Replace the control name.
            NSUInteger controlNameIndex = [self.options.arguments indexOfObject:alias.name];
            if (controlNameIndex < self.options.arguments.count) {
                [self.options.arguments replaceObjectAtIndex:controlNameIndex withObject:alias.controlName];
            }

            // Allow the alias to modify this control, if needed.
            if (alias.processBlock) {
                alias.processBlock(self);
            }
        }
    }
    return self;
}

- (void) debugOptions: (CDOption *)opt {
    // Immediately return if debug mode was not enabled.
    if (!self.options[@"debug"].boolValue) {
        return;
    }

    // Immediately return if parent option wasn't provided.
    if (opt.parentOption != nil && !opt.parentOption.wasProvided) {
        return;
    }

    // Option debug info.
    if (!opt.wasProvided) {
        // Ignore if no default value was provided.
        if (!opt.defaultValue) {
            return;
        }
        NSMutableString *value = opt.displayValue.mutableCopy;
        if (opt.hasAutomaticDefaultValue) {
            [value appendString:[NSString stringWithFormat:@" (%@)", @"USAGE_OPTION_AUTOMATIC_DEFAULT_VALUE".localizedLowercaseString]];
        }
        if (opt.maximumValues.unsignedIntegerValue == 1) {
            self.terminal.debug(@"The %@ option was not provided. Using default value: %@", opt.name.optionFormat, value, nil);
        }
        else {
            self.terminal.debug(@"The %@ option was not provided. Using default values: %@", opt.name.optionFormat, value, nil);
        }
    }
    else {
        if (opt.maximumValues.unsignedIntegerValue == 1) {
            self.terminal.debug(@"The %@ option was provided with the value: %@", opt.name.optionFormat, opt.displayValue, nil);
        }
        else {
            self.terminal.debug(@"The %@ option was provided with the values: %@", opt.name.optionFormat, opt.displayValue, nil);
        }
    }
}

- (void) createControl {
    // Attempt to load the specified control NIB.
    if (self.nib && !self.nib.isBlank) {
        NSArray *objects;
        if (![[NSBundle mainBundle] loadNibNamed:self.nib owner:self topLevelObjects:&objects]) {
            self.terminal.error(@"Unable to load NIB: %@", self.nib.doubleQuote, nil).exit(CDTerminalExitCodeControlFailure);
        }
        if (objects && objects.count) {
            topLevelObjects = objects;
        }
    }
};

- (NSScreen *) getScreen {
    NSUInteger index = self.options[@"screen"].unsignedIntegerValue;
    NSArray *screens = [NSScreen screens];
    if (index >= [screens count]) {
        self.terminal.warning(@"Unknown screen index: %@. Using screen where keyboard has focus.", [NSNumber numberWithUnsignedInteger:index], nil);
        return [NSScreen mainScreen];
    }
    return [screens objectAtIndex:index];
}

- (void) runControl {
    [NSApp run];
}

- (void) stopControl {
    // Stop any modal windows currently running
    [NSApp stop:self];

    // If this is the about dialog, just exit.
    if (self.alias && [self.alias.name isEqualToStringCaseInsensitive:@"about"]) {
        exit(0);
    }

    // Output return values in specified format.
    if ([self.options[@"output"].stringValue isEqualToStringCaseInsensitive:@"json"]) {
        [self.terminal write:self.returnValues.toJSONString];
    }
    else {
        [self.terminal write:self.returnValues.toColumnString];
    }

    if (!self.options[@"no-newline"].wasProvided) {
        [self.terminal writeNewLine];
    }

    // Return the exit status
    exit(self.exitStatus);
}

@end
