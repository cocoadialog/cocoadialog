//
//  SUAppcastItem.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUAPPCASTITEM_H
#define SUAPPCASTITEM_H

@interface SUAppcastItem : NSObject
{
@private
	NSString *title;
	NSDate *date;
	NSString *itemDescription;
	
	NSURL *releaseNotesURL;
	
	NSString *DSASignature;	
	NSString *minimumSystemVersion;
	
	NSURL *fileURL;
	NSString *versionString;
	NSString *displayVersionString;

	NSDictionary *deltaUpdates;

	NSDictionary *propertiesDictionary;
    
	NSURL *infoURL;	// UK 2007-08-31
}

// Initializes with data from a dictionary provided by the RSS class.
- (instancetype) initWithDictionary:(NSDictionary *)dict;
- (instancetype) initWithDictionary:(NSDictionary *)dict failureReason:(NSString**)error;

@property (readonly, copy) NSString *title;
@property (readonly, copy) NSString *versionString;
@property (readonly, copy) NSString *displayVersionString;
@property (readonly, copy) NSDate *date;
@property (readonly, copy) NSString *itemDescription;
@property (readonly, copy) NSURL *releaseNotesURL;
@property (readonly, copy) NSURL *fileURL;
@property (readonly, copy) NSString *DSASignature;
@property (readonly, copy) NSString *minimumSystemVersion;
@property (readonly, copy) NSDictionary *deltaUpdates;
@property (getter=isDeltaUpdate, readonly) BOOL deltaUpdate;
@property (getter=isCriticalUpdate, readonly) BOOL criticalUpdate;

// Returns the dictionary provided in initWithDictionary; this might be useful later for extensions.
@property (readonly, copy) NSDictionary *propertiesDictionary;

@property (readonly, copy) NSURL *infoURL;						// UK 2007-08-31

@end

#endif
