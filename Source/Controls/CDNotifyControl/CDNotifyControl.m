//
//  CDNotifyControl.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/1/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDNotifyControl.h"

@implementation CDNotifyControl

- (instancetype) init {
    self = [super init];
    if (self) {
        activeNotifications = 0;
        notifications = [NSMutableArray array];
    }
    return self;
}

- (CDOptions *) availableOptions {
    CDOptions *options = [CDOptions options];

    NSString *global = @"GLOBAL_OPTION";

    // Global
    [options addOption:[CDOptionFlag                    name:@"help"            category:global]];
    [options addOption:[CDOptionFlag                    name:@"debug"           category:global]];
    [options addOption:[CDOptionFlag                    name:@"quiet"           category:global]];
    [options addOption:[CDOptionSingleString            name:@"icon"            category:global]];
    [options addOption:[CDOptionSingleString            name:@"icon-bundle"     category:global]];
    [options addOption:[CDOptionSingleString            name:@"icon-file"       category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-height"     category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-size"       category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-width"      category:global]];
    [options addOption:[CDOptionSingleString            name:@"icon-type"       category:global]];
    [options addOption:[CDOptionSingleStringOrNumber    name:@"posX"            category:global]];
    [options addOption:[CDOptionSingleStringOrNumber    name:@"posY"            category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"timeout"         category:global]];

    // CDNotifyControls
    [options addOption:[CDOptionSingleString            name:@"alpha"]];
    [options addOption:[CDOptionSingleString            name:@"fh"]];
    [options addOption:[CDOptionFlag                    name:@"no-growl"]];
    [options addOption:[CDOptionFlag                    name:@"sticky"]];

    // Text.
    [options addOption:[CDOptionSingleString            name:@"title"]];
    [options addOption:[CDOptionMultipleStrings         name:@"titles"]];
    [options addOption:[CDOptionSingleString            name:@"description"]];
    [options addOption:[CDOptionMultipleStrings         name:@"descriptions"]];


    // Clicks handler(s).
    [options addOption:[CDOptionSingleString            name:@"click-arg"]];
    [options addOption:[CDOptionMultipleStrings         name:@"click-args"]];
    [options addOption:[CDOptionSingleString            name:@"click-path"]];
    [options addOption:[CDOptionMultipleStrings         name:@"click-paths"]];

    // CDBubbleControl Options (they're not used by CDGrowlControl, but need to be
    // recognized as possible keys for backwards compatability support and so
    // CDGrowlControl doesn't interpret them as values)
    //
    // Options for one bubble
    [options addOption:[CDOptionSingleString            name:@"text-color"]];
    [options addOption:[CDOptionSingleString            name:@"border-color"]];
    [options addOption:[CDOptionSingleString            name:@"background-top"]];
    [options addOption:[CDOptionSingleString            name:@"background-bottom"]];

    // Options for multiple bubble
    [options addOption:[CDOptionMultipleStrings         name:@"text-colors"]];
    [options addOption:[CDOptionMultipleStrings         name:@"border-colors"]];
    [options addOption:[CDOptionMultipleStrings         name:@"background-tops"]];
    [options addOption:[CDOptionMultipleStrings         name:@"background-bottoms"]];

    // With this set, clicking one bubble won't kill the rest.
    [options addOption:[CDOptionFlag                    name:@"independent"]];

    // Deprecated options.
    [options addOption:[CDOptionDeprecated              from:@"text"        to:@"description"]];
    [options addOption:[CDOptionDeprecated              from:@"texts"       to:@"descriptions"]];
    [options addOption:[CDOptionDeprecated              from:@"no-timeout"  to:@"sticky"]];
    [options addOption:[CDOptionDeprecated              from:@"x-placement" to:@"posX"]];
    [options addOption:[CDOptionDeprecated              from:@"y-placement" to:@"posY"]];

    return options;
}

- (void) dealloc {
    [notifications release];
    [super dealloc];
}

- (void)addNotificationWithTitle:(NSString *)title description:(NSString *)description icon:(NSImage *)_icon priority:(NSNumber *)priority sticky:(BOOL)sticky clickPath:(NSString *)clickPath clickArg:(NSString *)clickArg {

    if (!(option[@"title"] && option[@"description"]) || !(option[@"titles"] && option[@"descriptions"])) {
        [self fatalError:@"You must specify either --title and --description, or --titles and --descriptions (with the same number of args).", nil];
    }

    NSMutableDictionary * notification = [NSMutableDictionary dictionary];
    notification[@"title"] = title;
    notification[@"description"] = description;
    notification[@"icon"] = _icon;
    NSData *iconData = [NSData dataWithData:_icon.TIFFRepresentation];
    if (iconData == nil) {
        iconData = [NSData data];
    }
    notification[@"iconData"] = iconData;
    if (priority == nil) {
        priority = @0;
    }
    notification[@"priority"] = priority;
    notification[@"sticky"] = @(sticky);
    if (clickPath == nil) {
        clickPath = @"";
    }
    notification[@"clickPath"] = clickPath;
    if (clickArg == nil) {
        clickArg = @"";
    }
    notification[@"clickArg"] = clickArg;
    [notifications addObject:notification];
}

// returns an NSArray of NSImage's or nil if there's only one.
- (NSArray *) notificationIcons {
	NSMutableArray *icons = [NSMutableArray array];
	NSArray *iconArgs;
	NSEnumerator *en;
    
	if (option[@"icons"].wasProvided) {
		iconArgs = option[@"icons"].arrayValue;
		en = [iconArgs objectEnumerator];
		NSString *iconName;
		while (iconName = (NSString *)[en nextObject]) {
            NSImage * _icon = [self iconFromName:iconName];
			if (_icon == nil) {
				_icon = NSApp.applicationIconImage;
			}
			[icons addObject:_icon];
		}
        
	}
    else if (option[@"icon-files"].wasProvided) {
		iconArgs = option[@"icon-files"].arrayValue;
		en = [iconArgs objectEnumerator];
		NSString *fileName;
		while (fileName = (NSString *)[en nextObject]) {
            NSImage * _icon = [self iconFromFile:fileName];
			if (_icon == nil) {
				_icon = NSApp.applicationIconImage;
			}
			[icons addObject:_icon];
		}
        
	}
    else {
		return nil;
	}
    
	return icons;
}

- (void) notificationWasClicked:(id)clickContext
{
    NSDictionary * notification = [NSDictionary dictionaryWithDictionary:notifications[[clickContext intValue]]];
    NSString * path = notification[@"clickPath"];
    if ([path isEqualToStringCaseInsensitive:@"cocoaDialog"]) {
        path = [NSProcessInfo processInfo].arguments[0];
    }
    NSMutableArray *args = [NSMutableArray array];
    if (![notification[@"clickArg"] isEqualToString:@""]) {
        args = [NSMutableArray arrayWithArray:[self parseTextForArguments:notification[@"clickArg"]]];
    }
    // Check to ensure the file exists before launching the command
    if (![path isEqualToString:@""] && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [args insertObject:path atIndex:0];
#if defined __ppc__ || defined __i368__
        [args insertObject:@"-32" atIndex:0];
#elif defined __ppc64__ || defined __x86_64__
        [args insertObject:@"-64" atIndex:0];
#endif
        NSTask *task = [[[NSTask alloc] init] autorelease];
        // Output must be silenced to not hang this process
        task.standardError = [NSPipe pipe];
        task.standardOutput = [NSPipe pipe];
        task.launchPath = @"/usr/bin/arch";
        task.arguments = args;
        [task launch];
    }
}

- (NSArray *) parseTextForArguments:(NSString *)string
{
    NSMutableArray* masterArray = [NSMutableArray array];
    // Make quotes on their own lines
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:[NSString stringWithFormat: @"\n\"\n"]];
    NSArray * quotedArray = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    BOOL inQuote = NO;
    NSEnumerator *en = [quotedArray objectEnumerator];
    id arg;
    while (arg = [en nextObject]) {
        NSMutableArray* spacedArray = [NSMutableArray array];
        // Determine which quote state we're in
        if ([[arg substringToIndex:1] isEqualToString:@"\""]) {
            inQuote = !inQuote;
            continue;
        }
        if (![arg isEqualToString:@""] || arg != nil) {
            if (inQuote) {
                [spacedArray addObject:arg];
            }
            else {
                // Trim any spaces or newlines from the beginning or end
                arg = [arg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [spacedArray addObjectsFromArray: [arg componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            [masterArray addObjectsFromArray:spacedArray];
        }
    }
    return masterArray;
}

@end
