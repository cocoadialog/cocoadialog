/*
	CDBubbleControl.h
	cocoaDialog
	Copyright (C) 2004-2006 Mark A. Stratman <mark@sporkstorms.org>
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.
 
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
 
	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

@import Foundation;
#import "CDNotifyControl.h"

@interface CDBubbleControl : CDNotifyControl

// We really ought to stick this in a proper NSColor category
+ (NSColor *) colorFromHex:(NSString *) hexValue alpha:(CGFloat)alpha;
- (NSColor*) _colorForBubble:(unsigned long)i fromKey:(NSString*)key alpha:(CGFloat)alpha;

@end
