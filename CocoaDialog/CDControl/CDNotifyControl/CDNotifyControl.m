

#import "CDNotifyControl.h"

@implementation CDNotifyControl

- (instancetype)initWithOptions:(CDOptions*)opts {
	self = [super initWithOptions:opts];
    activeNotifications = 0;
    notifications = @[].mutableCopy;
	return self;
}


// This must be overridden if you want local global options for your control
- (NSDictionary*) globalAvailableKeys {
    NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
    NSNumber *vMul = @CDOptionsMultipleValues;
    return @{@"help": vNone,
            @"debug": vNone,
            @"quiet": vNone,

            // CDNotifyControls
             @"fh": vOne,
             @"no-growl": vNone,
             @"sticky": vNone,
             // Text
             @"title": vOne,
             @"description": vOne,
             @"titles": vMul,
             @"descriptions": vMul,
             // Icons
             @"icon": vOne,
             @"icon-bundle": vOne,
             @"icon-type": vOne,
             @"icon-file": vOne,
             @"icons": vMul,
             @"icon-files": vMul,
             // Click
             @"click-path": vOne,
             @"click-arg": vOne,
             @"click-paths": vMul,
             @"click-args": vMul,
             
   // CDBubbleControl Options (they're not used by CDGrowlControl, but need to be recognized as possible keys for backwards compatability support and so CDGrowlControl doesn't interpret them as values)

             // Options for one bubble
             @"text-color": vOne,
             @"border-color": vOne,
             @"background-top": vOne,
             @"background-bottom": vOne,
             
             // Options for multiple bubble
             @"text-colors": vMul,
             @"border-colors": vMul,
             @"background-tops": vMul,
             @"background-bottoms": vMul,
             @"independent": vNone, // With this set, clicking one bubble won't kill the rest.
             
             // General options, apply to all scenarios
             @"posX": vOne,
             @"posY": vOne,
             @"alpha": vOne,
             @"timeout": vOne};
}

- (NSDictionary*) depreciatedKeys
{
	return @{@"text": @"description",
            @"texts": @"descriptions",
            @"no-timeout": @"sticky",
            @"x-placement": @"posX",
            @"y-placement": @"posY"};
}


- (void)addNotificationWithTitle:(NSString *)title description:(NSString *)description icon:(NSImage *)_icon priority:(NSNumber *)priority sticky:(BOOL)sticky clickPath:(NSString *)clickPath clickArg:(NSString*)clickArg
{
    NSMutableDictionary * notification = [NSMutableDictionary dictionary];
    notification[@"title"] = title;
    notification[@"description"] = description;
    notification[@"icon"] = _icon;
    NSData *iconData = [NSData dataWithData:[_icon TIFFRepresentation]];
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
- (NSArray*) notificationIcons {
	NSMutableArray *icons = [NSMutableArray array];
	NSArray *iconArgs;
	NSEnumerator *en;
    
	if ([self.options hasOpt:@"icons"] && [[self.options optValues:@"icons"] count]) {
		iconArgs = [self.options optValues:@"icons"];
		en = [iconArgs objectEnumerator];
		NSString *iconName;
		while (iconName = (NSString *)[en nextObject]) {
            NSImage * _icon = [self.icon iconFromName:iconName];
			if (_icon == nil) {
				_icon = [NSApp applicationIconImage];
			}
			[icons addObject:_icon];
		}
        
	} else if ([self.options hasOpt:@"icon-files"]
	           && [[self.options optValues:@"icon-files"] count])
	{
		iconArgs = [self.options optValues:@"icon-files"];
		en = [iconArgs objectEnumerator];
		NSString *fileName;
		while (fileName = (NSString *)[en nextObject]) {
            NSImage * _icon = [self.icon iconFromFile:fileName];
			if (_icon == nil) {
				_icon = [NSApp applicationIconImage];
			}
			[icons addObject:_icon];
		}
        
	} else {
		return nil;
	}
    
	return icons;
}

- (void) notificationWasClicked:(id)clickContext
{
    NSDictionary * notification = [NSDictionary dictionaryWithDictionary:notifications[[clickContext intValue]]];
    NSString * path = notification[@"clickPath"];
    if ([path caseInsensitiveCompare:@"cocoaDialog"] == NSOrderedSame) {
        path = [[NSProcessInfo processInfo] arguments][0];
    }
    NSArray *arguments = nil;
    if (![notification[@"clickArg"] isEqualToString:@""]) {
        arguments = [NSArray arrayWithArray:[self parseTextForArguments:notification[@"clickArg"]]];
    }
    NSMutableArray * args = [NSMutableArray arrayWithArray:arguments];
    // Check to ensure the file exists before launching the command
    if (![path isEqualToString:@""] && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [args insertObject:path atIndex:0];
#if defined __ppc__ || defined __i368__
        [args insertObject:@"-32" atIndex:0];
#elif defined __ppc64__ || defined __x86_64__
        [args insertObject:@"-64" atIndex:0];
#endif
        NSTask *task = NSTask.new;
        // Output must be silenced to not hang this process
        [task setStandardError:[NSPipe pipe]];
        [task setStandardOutput:[NSPipe pipe]];
        [task setLaunchPath:@"/usr/bin/arch"];
        [task setArguments:args];
        [task launch];
    }
}

- (NSArray*) parseTextForArguments:(NSString*)string
{
    NSMutableArray* masterArray = [NSMutableArray arrayWithArray:nil];
    // Make quotes on their own lines
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:[NSString stringWithFormat: @"\n\"\n"]];
    NSArray * quotedArray = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    BOOL inQuote = NO;
    NSEnumerator *en = [quotedArray objectEnumerator];
    id arg;
    while (arg = [en nextObject]) {
        NSMutableArray* spacedArray = [NSMutableArray arrayWithArray:nil];
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
