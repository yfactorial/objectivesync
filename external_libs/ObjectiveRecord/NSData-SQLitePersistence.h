//
//  NSData-SQLitePersistence.h
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
#import <Foundation/Foundation.h>
#import "NSObject-SQLitePersistence.h"

@interface NSData(SQLitePersistence) <SQLitePersistence>
/*!
 This method initializes an NSData from blob pulled from the database.
 */
+ (id)objectWithSQLBlobRepresentation:(NSData *)data;
/*!
 This method returns self as a Base-64 encoded NSString.
 */
- (NSData *)sqlBlobRepresentationOfSelf;

/*!
 Returns YES to indicate it can be stored in a column of a database
 */
+ (BOOL)canBeStoredInSQLite;

/*!
 Returns REAL to inidicate this object can be stored in a TEXT column
 */
+ (NSString *)columnTypeForObjectStorage;
+ (BOOL)shouldBeStoredInBlob;
@end
