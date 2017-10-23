// CDUsage.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDUsage.h"

@implementation CDUsage

+ (instancetype)usage {
  return [[CDUsage alloc] init];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _app = [CDApplication sharedApplication];
    _terminal = [CDTerminal sharedInstance];
    _template = [CDTemplate sharedInstance];
  }
  return self;
}

- (void)showUsage {
  NSArray <CDControlAlias *> *controlAliases = self.app.controlAliases;
  NSArray *controls = [CDApplication availableControls].sortedAlphabetically;

  CDControl *control = self.app.control;

  NSMutableString *controlUsage = [NSMutableString string];
  if (control.isBaseControl || control.name == nil) {
    [controlUsage appendString:[NSString stringWithFormat:@"<%@>", @"CONTROL".localizedLowercaseString]];
  }
  else {
    [controlUsage appendString:control.name];
    if (control.options.requiredOptions.count) {
      for (NSString *optionName in control.options.requiredOptions.allKeys.sortedAlphabetically) {
        CDOption *opt = control.options.requiredOptions[optionName];
        NSMutableString *required = [NSMutableString stringWithString:opt.label.white.bold];
        [controlUsage appendString:@" "];
        NSString *requiredType = opt.typeLabel;
        if (requiredType != nil) {
          [required appendString:@" "];
          [required appendString:requiredType];
        }
        [controlUsage appendString:required];
        [controlUsage appendString:@"".white.bold];
      }
    }
  }

  // Output usage as JSON.
  if ([control.options[@"output"].stringValue isEqualToStringCaseInsensitive:@"json"]) {
    NSMutableDictionary *output = [NSMutableDictionary dictionary];
    output[@"controlAliases"] = controlAliases;
    output[@"controls"] = controls;
    output[@"deprecatedControls"] = [CDApplication deprecatedControls];
    output[@"removedControls"] = [CDApplication removedControls];
    output[@"options"] = control.options;
    output[@"usage"] = @"USAGE".localized.arguments(controlUsage, nil);
    output[@"version"] = self.app.version;
    output[@"website"] = self.app.baseUrl;
    [self.terminal write:output.toJSONString];
    exit(0);
  }

  NSUInteger margin = 4;

  // If (for whatever reason) there is no terminal width, default to 80.
  NSUInteger terminalColumns = [self.terminal colsWithMinimum:80] - margin;

  [self.terminal writeNewLine];
  [self.terminal writeLine:@"USAGE_EXAMPLE".localized.arguments(controlUsage, nil).white.bold.stop];

  // Show available controls if it's the CDControl class printing this.
  if (control.class == CDControl.class) {
    NSString *controlsString = [controls componentsJoinedByString:@", "].white.bold.stop;
    [self.terminal writeNewLine];
    [self.terminal writeLine:@"USAGE_HEADER_CONTROLS".localizedUppercaseString.white.bold.underline.stop];
    [self.terminal writeNewLine];
    controlsString = [controlsString wrapToLength:terminalColumns];
    controlsString = [controlsString indentNewlinesWith:margin];
    [self.terminal writeLine:[controlsString indent:margin]];
    [self.terminal writeNewLine];

    if (controlAliases.count) {
      [self.terminal writeNewLine];
      [self.terminal writeLine:@"USAGE_HEADER_CONTROL_ALIASES".localizedUppercaseString.white.bold.underline.stop];
      [self.terminal writeNewLine];

      for (CDControlAlias *alias in controlAliases) {
        NSMutableString *controlAliasesString = [NSMutableString string];
        if ([alias.name isEqualToStringCaseInsensitive:@"about"]) {
          [controlAliasesString appendFormat:@"%@\t\t - %@\n", alias.name.bold.white.stop, alias.usageDescription];
        }
        else {
          [controlAliasesString appendFormat:@"%@ - Alias for: %@ %@", alias.name.white.bold.stop, alias.controlName.magenta, alias.usageDescription.magenta];
        }
        [self.terminal writeLine:[[[controlAliasesString wrapToLength:terminalColumns] indentNewlinesWith:margin * 2] indent:margin]];
      }
      [self.terminal writeNewLine];
    }
  }

  // Get all available options and put them in their necessary scopedOptions.
  NSDictionary<NSString *, CDOptions *> *scopedOptions = control.options.groupByScope;

  // Print options for each scope.
  NSEnumerator *sortedScopes = [[NSArray arrayWithArray:[scopedOptions.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
    // Ensure global options are always at the bottom.
    if ([a isEqualToString:@"global"]) {
      return (NSComparisonResult) NSOrderedDescending;
    }
    else if ([b isEqualToString:@"global"]) {
      return (NSComparisonResult) NSOrderedAscending;
    }
    return [a localizedCaseInsensitiveCompare:b];
  }]] objectEnumerator];

  NSString *scope;
  while ((scope = [sortedScopes nextObject])) {
    [self.terminal writeNewLine];
    [self.terminal writeLine:[NSString stringWithFormat:@"USAGE_HEADER_SCOPE_%@", scope.uppercaseString].localized.white.bold.underline.stop];
    [self.terminal writeNewLine];

    CDOptions *scopeOptions = scopedOptions[scope];
    NSArray *sorted = scopeOptions.allKeys.sortedAlphabetically;
    for (NSString *optionName in sorted) {
      CDOption *scopeOption = scopeOptions[optionName];

      NSMutableString *line = [NSMutableString string];
      NSMutableArray *extra = [NSMutableArray array];

      [line appendString:[scopeOption.name.optionFormat indent:margin].white.bold.stop];

      // Add the "type" of option, if available.
      CDColor *typeColor = scopeOption.typeColor;
      NSString *typeLabel = scopeOption.typeLabel;
      if (typeLabel != nil) {
        if (scopeOption.hasAutomaticDefaultValue || scopeOption.valueType == CDBoolean) {
          typeLabel = typeLabel.dim;
        }
        [line appendString:@" "];
        [line appendString:typeLabel.stop];
      }

      // Indicate if option is required.
      if (scopeOption.required) {
        [line appendString:[NSString stringWithFormat:@" (%@)", @"USAGE_OPTION_REQUIRED_VALUE".localizedLowercaseString].red.bold.stop];
      }

      if (control.options[@"verbose"].wasProvided) {
        // Add the option description.
        [line appendString:@"\n"];

        NSMutableString *description = scopeOption.description.mutableCopy;

        // Wrap the column to fit available space.
        description = [NSMutableString stringWithString:[description wrapToLength:(terminalColumns - (margin * 2))]];

        // Replace new lines so they're indented properly.
        description = [NSMutableString stringWithString:[description indentNewlinesWith:(margin * 2)]];

        [line appendString:[description indent:(margin * 2)]];

        // Add the allowed values.
        NSMutableArray *allowedValues = [NSMutableArray array];
        id value = nil;
        for (value in scopeOption.allowedValues) {
          if (value != nil && [value isKindOfClass:NSString.class]) {
            NSString *valueString = (NSString *) value;
            value = valueString.doubleQuote;
          }
          else if (value != nil && [value isKindOfClass:NSNumber.class]) {
            NSNumber *valueNumber = (NSNumber *) value;
            if (strcmp([valueNumber objCType], @encode(BOOL)) == 0) {
              value = [valueNumber boolValue] ? @"YES".localized : @"NO".localized;
            }
            else {
              value = [valueNumber stringValue];
            }
          }
          [allowedValues addObject:value];
        }

        if (allowedValues.count > 0) {
          if (allowedValues.count == 1) {
            [extra addObject:@"USAGE_OPTION_ALLOWED_VALUE".localized.arguments([allowedValues componentsJoinedByString:@", "].addColor(typeColor), nil).white.bold.stop];
          }
          else {
            [extra addObject:@"USAGE_OPTION_ALLOWED_VALUES".localized.arguments([allowedValues componentsJoinedByString:@", "].addColor(typeColor), nil).white.bold.stop];
          }
        }

        // Add the default/required values.
        id defaultValue = scopeOption.defaultValue;
        if (defaultValue != nil && [defaultValue isKindOfClass:NSString.class]) {
          NSString *defaultValueString = (NSString *) defaultValue;
          defaultValue = defaultValueString.doubleQuote;
        }
        else if (defaultValue != nil && [defaultValue isKindOfClass:NSNumber.class]) {
          NSNumber *defaultValueNumber = (NSNumber *) defaultValue;
          if (strcmp([defaultValueNumber objCType], @encode(BOOL)) == 0) {
            defaultValue = [defaultValueNumber boolValue] ? @"YES".localized : @"NO".localized;
          }
          else {
            defaultValue = [defaultValueNumber stringValue];
          }
        }

        if (defaultValue) {
          if (scopeOption.hasAutomaticDefaultValue) {
            defaultValue = [NSString stringWithFormat:@"%@ (%@)", defaultValue, @"USAGE_OPTION_AUTOMATIC_DEFAULT_VALUE".localized];
          }
          [extra addObject:@"USAGE_OPTION_DEFAULT_VALUE".localized.arguments(@"%@".arguments(defaultValue, nil).addColor(typeColor), nil).white.bold.stop];
        }

        if (extra.count > 0) {
          [extra insertObject:@"" atIndex:0];
          [line appendString:[[extra componentsJoinedByString:@"\n\n"] indentNewlinesWith:(margin * 2)]];
        }

        if (scopeOption.notes.count) {
          [line appendString:@"\n\n"];
          [line appendString:[[NSString stringWithFormat:@"%@:", @"USAGE_OPTION_NOTE".localizedUppercaseString] indent:(margin * 2)].yellow.bold.stop];
          if (scopeOption.notes.count == 1) {
            [line appendString:[NSString stringWithFormat:@" %@", scopeOption.notes[0]].yellow.dim.stop];
          }
          else {
            for (NSUInteger i = 0; i < scopeOption.notes.count; i++) {
              [line appendString:@"\n"];
              [line appendString:[[NSString stringWithFormat:@"* %@", scopeOption.notes[i]] indent:(margin * 3)].yellow.stop];
            }
          }
        }

        if (scopeOption.warnings.count) {
          [line appendString:@"\n\n"];
          [line appendString:[[NSString stringWithFormat:@"%@:", @"USAGE_OPTION_WARNING".localizedUppercaseString] indent:(margin * 2)].red.bold.stop];
          if (scopeOption.warnings.count == 1) {
            [line appendString:[NSString stringWithFormat:@" %@", scopeOption.warnings[0]].red.stop];
          }
          else {
            for (NSUInteger i = 0; i < scopeOption.warnings.count; i++) {
              [line appendString:@"\n"];
              [line appendString:[[NSString stringWithFormat:@"* %@", scopeOption.warnings[i]] indent:(margin * 3)].red.stop];
            }
          }
        }
        [line appendString:@"\n"];
      }

      [self.terminal writeLine:line];
    }
  }

  [self.terminal writeNewLine];
  [self.terminal writeNewLine];

  [self.terminal writeLine:[NSString stringWithFormat:@"%@: %@", @"VERSION".localizedUppercaseString.underline.white.bold.stop, self.app.version.cyan]];

  [self.terminal writeNewLine];

  [self.terminal writeLine:[NSString stringWithFormat:@"%@: %@", @"WEBSITE".localizedUppercaseString.underline.white.bold.stop, self.app.baseUrl.cyan.stop]];

  if (!control.options[@"verbose"].wasProvided) {
    [self.terminal writeNewLine];
    [self.terminal writeLine:@"---"];
    [self.terminal writeNewLine];
    [self.terminal writeLine:@"USAGE_VERBOSE_HELP".localized.arguments(@"verbose".optionFormat, nil).white.bold.stop];
  }
}

@end
