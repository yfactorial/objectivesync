//
//  NSString-SQLiteColumnName.m
// ----------------------------------------------------------------------
// Part of the SQLite Persistent Objects for Cocoa and Cocoa Touch
//
// (c) 2008 Jeff LaMarche (jeff_Lamarche@mac.com)
// ----------------------------------------------------------------------
// This code may be used without restriction in any software, commercial,
// free, or otherwise. There are no attribution requirements, and no
// requirement that you distribute your changes, although bugfixes and 
// enhancements are welcome.
// 
// If you do choose to re-distribute the source code, you must retain the
// copyright notice and this license information. I also request that you
// place comments in to identify your changes.
//
// For information on how to use these classes, take a look at the 
// included eadme.txt file
// ----------------------------------------------------------------------

#import "NSString-SQLiteColumnName.h"


@implementation NSString(SQLiteColumnName)
- (NSString *)stringAsSQLColumnName
{
	NSMutableString *ret = [NSMutableString string];
	for (int i=0; i < [self length]; i++)
	{
		NSRange sRange = NSMakeRange(i,1);
		NSString *oneChar = [self substringWithRange:sRange];
		if ([oneChar isEqualToString:[oneChar uppercaseString]] && i > 0)
			[ret appendFormat:@"_%@", [oneChar lowercaseString]];
		else
			[ret appendString:[oneChar lowercaseString]];
	}
	return ret;
}
- (NSString *)stringAsPropertyString
{
	BOOL lastWasUnderscore = NO;
	NSMutableString *ret = [NSMutableString string];
	for (int i=0; i < [self length]; i++)
	{
		NSRange sRange = NSMakeRange(i,1);
		NSString *oneChar = [self substringWithRange:sRange];
		if ([oneChar isEqualToString:@"_"])
			lastWasUnderscore = YES;
		else
		{
			if (lastWasUnderscore)
				[ret appendString:[oneChar uppercaseString]];
			else
				[ret appendString:oneChar];
			
			lastWasUnderscore = NO;
		}
	}
	return ret;
}
@end
