//
//  CDNotifyControl.m
//  CocoaDialog
//
//  Created by Mark Carver on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDNotifyControl.h"

@implementation CDNotifyControl

- (id)init
{
    self = [self initWithOptions:nil];
    activeNotifications = 0;
    hasFinished = NO;
    notifications = [[[NSMutableArray alloc] init] retain];
	return self;
}

- (void) dealloc
{
    [notifications release];
	[_options release];
    [controlItems release];
	[super dealloc];
}


// This must be overridden if you want local global options for your control
- (NSDictionary *) globalAvailableKeys {
    NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
    NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    return [NSDictionary dictionaryWithObjectsAndKeys:
             // General
             vNone, @"help",
             vNone, @"debug",
             vNone, @"sticky",
             vNone, @"no-growl",
             // Text
             vOne,  @"title",
             vOne,  @"description",
             vMul,  @"titles",
             vMul,  @"descriptions",
             // Icons
             vOne,  @"icon",
             vOne,  @"icon-bundle",
             vOne,  @"icon-type",
             vOne,  @"icon-file",
             vMul,  @"icons",
             vMul,  @"icon-files",
             // Click
             vOne,  @"click-path",
             vOne,  @"click-arg",
             vMul,  @"click-paths",
             vMul,  @"click-args",
             
             
   // CDBubbleControl Options (they're not used by CDGrowlControl, but need to be recognized as possible keys for backwards compatability support and so CDGrowlControl doesn't interpret them as values)

             // Options for one bubble
             vOne, @"text-color",
             vOne, @"border-color",
             vOne, @"background-top",
             vOne, @"background-bottom",
             
             // Options for multiple bubble
             vMul, @"text-colors",
             vMul, @"border-colors",
             vMul, @"background-tops",
             vMul, @"background-bottoms",
             vNone, @"independent", // With this set, clicking one bubble won't kill the rest.
             
             // General options, apply to all scenarios
             vOne, @"posX",
             vOne, @"posY",
             vOne, @"alpha",
             vOne, @"timeout",

             nil];
}

- (NSDictionary *) depreciatedKeys
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
            @"description", @"text",
            @"descriptions", @"texts",
            @"sticky", @"no-timeout",
            @"posX", @"x-placement",
            @"posY", @"y-placement",
            nil];
}


- (void)addNotificationWithTitle:(NSString *)title description:(NSString *)description icon:(NSImage *)icon priority:(NSNumber *)priority sticky:(BOOL)sticky clickPath:(NSString *)clickPath clickArg:(NSString *)clickArg
{
    NSMutableDictionary * notification = [NSMutableDictionary dictionary];
    [notification setObject:title forKey:@"title"];
    [notification setObject:description forKey:@"description"];
    [notification setObject:icon forKey:@"icon"];
    NSData *iconData = [NSData dataWithData:[icon TIFFRepresentation]];
    if (iconData == nil) {
        iconData = [NSData data];
    }
    [notification setObject:iconData forKey:@"iconData"];
    if (priority == nil) {
        priority = [NSNumber numberWithInt:0];
    }
    [notification setObject:priority forKey:@"priority"];
    [notification setObject:[NSNumber numberWithBool:sticky] forKey:@"sticky"];
    if (clickPath == nil) {
        clickPath = @"";
    }
    [notification setObject:clickPath forKey:@"clickPath"];
    if (clickArg == nil) {
        clickArg = @"";
    }
    [notification setObject:clickArg forKey:@"clickArg"];
    [notifications addObject:notification];
}

// Should always return an image
- (NSImage *) notificationIcon
{
	CDOptions *options = [self options];
	NSImage *icon = nil;
    
	if ([options hasOpt:@"icon-file"]) {
        icon = [self getIconFromFile:[options optValue:@"icon-file"]];
        
	} else if ([options hasOpt:@"icon"]) {
        icon = [self getIconWithName:[options optValue:@"icon"]];
	}
    
	if (icon == nil) {
		icon = [NSApp applicationIconImage];
	}
	return icon;
}


// returns an NSArray of NSImage's or nil if there's only one.
- (NSArray *) notificationIcons
{
	CDOptions *options = [self options];
	NSMutableArray *icons = [NSMutableArray array];
	NSArray *iconArgs;
	NSEnumerator *en;
    
	if ([options hasOpt:@"icons"] && [[options optValues:@"icons"] count]) {
		iconArgs = [options optValues:@"icons"];
		en = [iconArgs objectEnumerator];
		NSString *iconName;
		while (iconName = (NSString *)[en nextObject]) {
            NSImage * icon = [self getIconWithName:iconName];
			if (icon == nil) {
				icon = [NSApp applicationIconImage];
			}
			[icons addObject:icon];
		}
        
	} else if ([options hasOpt:@"icon-files"]
	           && [[options optValues:@"icon-files"] count])
	{
		iconArgs = [options optValues:@"icon-files"];
		en = [iconArgs objectEnumerator];
		NSString *fileName;
		while (fileName = (NSString *)[en nextObject]) {
            NSImage * icon = [self getIconFromFile:fileName];
			if (icon == nil) {
				icon = [NSApp applicationIconImage];
			}
			[icons addObject:icon];
		}
        
	} else {
		return nil;
	}
    
	return icons;
}

- (void) notificationWasClicked:(id)clickContext
{
    NSDictionary * notification = [NSDictionary dictionaryWithDictionary:[notifications objectAtIndex:[clickContext intValue]]];
    NSString * path = [notification objectForKey:@"clickPath"];
    if ([path caseInsensitiveCompare:@"cocoaDialog"] == NSOrderedSame) {
        path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    }
    NSArray *arguments = nil;
    if (![[notification objectForKey:@"clickArg"] isEqualToString:@""]) {
        arguments = [NSArray arrayWithArray:[self parseTextForArguments:[notification objectForKey:@"clickArg"]]];
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
        NSTask *task = [[[NSTask alloc] init] autorelease];
        // Output must be silenced to not hang this process
        [task setStandardError:[NSPipe pipe]];
        [task setStandardOutput:[NSPipe pipe]];
        [task setLaunchPath:@"/usr/bin/arch"];
        [task setArguments:args];
        [task launch];
    }
}

- (NSArray *) parseTextForArguments:(NSString *)string
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
