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
#define kSQLiteColumnTypeText		@"TEXT"
#define kSQLIteColumnTypeInteger	@"INTEGER"
#define kSQLiteColumnTypeReal		@"REAL"
#define kSQLiteColumnTypeBlob		@"BLOB"
#define kSQLiteColumnTypeNULL		@"NULL"

#import <Foundation/Foundation.h>
@protocol SQLitePersistence

/*! 
 This protocol should be implemented by any object that needs to be stored in a database as a single column. This protocol is not for objects that will be persisted as a table, but only those that need to be persisted inside a column of a table. This is primarily for objects that store numbers, text, dates, and other values that can easily be represented in a column of a database table. For more complex objects, subclass SQLitePersistentObject
 */

@required
/*!
 This method is used to indicate whether this data object can be stored in a column of a SQLite3 table
 */
+ (BOOL)canBeStoredInSQLite;

/*!
 Returns the SQL data type to use to store this object in a SQLite3 database. Must be one of kSQLiteColumnTypeText, kSQLIteColumnTypeInteger, kSQLiteColumnTypeReal, kSQLiteColumnTypeBlob
 */
+ (NSString *)columnTypeForObjectStorage;
+ (BOOL)shouldBeStoredInBlob;

@optional
/*!
 This method needs to be implemented only if a class returns YES to shouldBeStoredInBlob. Inits an object from a blob. 
 */
+ (id)objectWithSqlColumnRepresentation:(NSString *)columnData;
/*!
 This method needs to be implemented only if this class returns YES to shouldBeStoredInBlob. Returns an NSData containing the data to go in the blob. This method must be implemented by objects that return YES in canBeStoredInSQLite and YES in shouldBeStoredInBlob.
 */
- (NSData *)sqlBlobRepresentationOfSelf;

/*!
 This method returns an autoreleased object from column data pulled from the database. This is the reverse to sqlColumnRepresentationOfSelf and needs to be able to create a data from whatever is returned by that method. This method must be implemented by objects that return YES in canBeStoredInSQLite but YES in shouldBeStoredInBlob.  */
+ (id)objectWithSQLBlobRepresentation:(NSData *)data;

/*!
 This method returns a string that holds this object's data and which can be used to re-constitute the object using objectWithSqlColumnRepresentation:. This method must be implemented by objects that return YES in canBeStoredInSQLite but NO in shouldBeStoredInBlob.
 */
- (NSString *)sqlColumnRepresentationOfSelf;


@end

/*!
  This category on NSObject provides a basic mechanism for objects to be written into the database as the column of a table. The methods in this category should be overwritten by any class that needs to be stored in the database, as the method used here is to archive the object into an an NSData instance, then Base64 the archived data and store it in a TEXT column.  This method is inefficient and does not allow meaningful searches on the column, but it does provide a mechanism to allow any object that implements NSCoding to be stored in the database.
 
 NOTE: Investigate using a BLOB instead of BASE64 encoded TEXT for the default implementation.
 */
@interface NSObject(SQLitePersistence)
/*!
 This method is used to indicate whether this data object can be stored in a column of a SQLite3 table. This default implementation returns YES if this object conforms to NSCoding.
 */
+ (BOOL)canBeStoredInSQLite;

/*!
 Returns the SQL data type to use to store this object in a SQLite3 database. This default implementation returns TEXT, since the object will be stored BASE64 encoded.
 */
+ (NSString *)columnTypeForObjectStorage;

+ (BOOL)shouldBeStoredInBlob;
- (NSData *)sqlBlobRepresentationOfSelf;
+ (id)objectWithSQLBlobRepresentation:(NSData *)data;



/*
 * Foundation methods missing from iPhone
 */
+ (NSString *)className;
- (NSString *)className;


@end
