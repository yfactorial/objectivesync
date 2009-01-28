//
//  NSObject-SQLitePersistence.m
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

#import "NSObject-SQLitePersistence.h"
@implementation NSObject(SQLitePersistence)

+ (BOOL)canBeStoredInSQLite;
{
	return [self conformsToProtocol:@protocol(NSCoding)];
}
+ (NSString *)columnTypeForObjectStorage 
{
	return kSQLiteColumnTypeBlob;
}
- (NSData *)sqlBlobRepresentationOfSelf
{
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:self forKey:[self className]];
	[archiver finishEncoding];
	[archiver release];
	return [data autorelease];
}
+ (BOOL)shouldBeStoredInBlob
{
	return YES;
}
+ (id)objectWithSQLBlobRepresentation:(NSData *)data;
{
	if (data == nil || [data length] == 0)
		return nil;
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	id ret = [unarchiver decodeObjectForKey:[self className]];
	[unarchiver finishDecoding];
	[unarchiver release];
	[data release];
	
	return ret;
}

+ (NSString *)className {
	return NSStringFromClass([self class]);
}
- (NSString *)className {
	return [[self class] className];
}

@end
