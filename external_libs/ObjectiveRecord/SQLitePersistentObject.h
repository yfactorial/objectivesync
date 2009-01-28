//
//  SQLitePersistentObject.h
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
#import "/usr/include/sqlite3.h"
#import <objc/runtime.h>
#import "ORCDataChangedDelegate.h"

#define isNSArrayType(x) ([x isEqualToString:@"NSArray"] || [x isEqualToString:@"NSMutableArray"])
#define isNSDictionaryType(x) ([x isEqualToString:@"NSDictionary"] || [x isEqualToString:@"NSMutableDictionary"])
#define isNSSetType(x) ([x isEqualToString:@"NSSet"] || [x isEqualToString:@"NSMutableSet"])

/*! 
 Any class that subclasses this class can have their properties automatically persisted into a sqlite database. There are some limits - currently certain property types aren't supported like void *, char *, structs and unions. Anything that doesn't work correctly with Key Value Coding will not work with this. Ordinary scalars (ints, floats, etc) will be converted to NSNumber, as will BOOL.
 
 SQLite is very good about converting types, so you can search on a number field passing in a number in a string, and can search on a string field by passing in a number. The only limitation we place on the search methods is that we don't allow searching on blobs, which is simply for performance reasons. 
 
 */
// TODO: Look at marking object "dirty" when changes are made, and if it's not dirty, save becomes a no-op.

@interface SQLitePersistentObject : NSObject {

	NSInteger	pk;	

}
/*!
 Returns the name of the table that this object will use to save its data
 */
+ (NSString *)tableName;

/*!
 Find by criteria lets you specify the SQL conditions that will be used. The string passed in should start with the word WHERE. So, to search for a value with a pk value of 1, you would pass in @"WHERE pk = 1". When comparing to strings, the string comparison must be in single-quotes like this @"WHERE name = 'smith'".
 */
+(NSArray *)findByCriteria:(NSString *)criteriaString;
+(SQLitePersistentObject *)findFirstByCriteria:(NSString *)criteriaString;
+(SQLitePersistentObject *)findByPK:(int)inPk;

+(void)deleteByCriteria:(NSString *)criteriaString;

/*!
 This method should be overridden by subclasses in order to specify performance indices on the underyling table. 
 @result Should return an array of arrays. Each array represents one index, and should contain a list of the properties that the index should be created on, in the order the database should use to create it. This is case sensitive, and the values must match the value of property names
 */
+(NSArray *)indices;

/*!
 Deletes this object's corresponding row from the database table. This version does NOT cascade to child objects in other tables.
 */
-(void)deleteObject;

/*!
 This is just a convenience routine; in several places we have to iterate through the properties and take some action based
 on their type. This method creates an array with all the property names and their types in a dictionary. The values for 
 the encoded types will be one of:
 
 c	A char
 i	An int
 s	A short
 l	A long
 q	A long long
 C	An unsigned char
 I	An unsigned int
 S	An unsigned short
 L	An unsigned long
 Q	An unsigned long long
 f	A float
 d	A double
 B	A C++ bool or a C99 _Bool
 v	A void
 *	A character string (char *)
 @	An object (whether statically typed or typed id)
 #	A class object (Class)
 :	A method selector (SEL)
 [array type]	An array
 {name=type...}	A structure
 (name=type...)	A union
 bnum	A bit field of num bits
 ^type	A pointer to type
 ?	An unknown type (among other things, this code is used for function pointers)

 Currently, the following properties cannot be persisted using this class:  C, c, v, #, :, [array type], *, {name=type...}, (name=type...), bnum, ^type, or ?
 TODO: Look at finding ways to allow people to use some or all of the currently unsupported types... we could probably use sizeof to store the structs and unions maybe??.
 TODO: Look at overriding valueForUndefinedKey: to handle the char, char * and unsigned char property types - valueForKey: doesn't return anything for these, so currently they do not work.
 */
+ (NSDictionary *)propertiesWithEncodedTypes;

+ (void)setDataChangedDelegate:(id<ORCDataChangedDelegate>)delegate;

/*!
 Indicates whether this object has ever been saved to the database. It does not indicate that the data matches what's in the database, just that there is a corresponding row
 */
-(BOOL) existsInDB;

/*!
 Saves this object's current data to the database. If it has never been saved before, it will assign a primary key value based on the database contents. Scalar values (ints, floats, doubles, etc.) will be stored in appropriate database columns, objects will be stored using the SQLitePersistence protocol methods - objects that don't implement that protocol will be archived into the database. Collection clases will be stored in child cross-reference tables that serve double duty. Any object they contain that is a subclass of SQLItePersistentObject will be stored as a foreign key to the appropriate table, otherwise objects will be stored in a column according to SQLitePersistence. Currently, collection classes inside collection classes are simply serialized into the x-ref table, which works, but is not the most efficient means. 
 
 //TODO: Look at adding recursion of some form to allow collection objects within collection objects to be stored in a normalized fashion
 */
-(void)save;

/*!
 Returns this objects primary key
 */
-(int)pk;

@end
