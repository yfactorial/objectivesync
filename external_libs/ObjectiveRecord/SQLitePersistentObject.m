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

#import "SQLitePersistentObject.h"
#import "SQLiteInstanceManager.h"
#import "NSString-SQLiteColumnName.h"
#import "NSObject-SQLitePersistence.h"
#import "NSString-UppercaseFirst.h"
#import "NSObject+PropertySupport.h"
#import "NSDate-SQLitePersistence.h"

id findByMethodImp(id self, SEL _cmd, id value)
{
	NSString *methodBeingCalled = [NSString stringWithUTF8String:sel_getName(_cmd)];
	
	NSRange theRange = NSMakeRange(6, [methodBeingCalled length] - 7);
	NSString *property = [[methodBeingCalled substringWithRange:theRange] stringByLowercasingFirstLetter];
	
	NSMutableString *queryCondition = [NSMutableString stringWithFormat:@"WHERE %@ = ", [property stringAsSQLColumnName]];
	if (![value isKindOfClass:[NSNumber class]])
		[queryCondition appendString:@"'"];
	
	if ([value conformsToProtocol:@protocol(SQLitePersistence)])
	{
		if ([[value class] shouldBeStoredInBlob])
		{
			NSLog(@"*** Can't search on BLOB fields");
			return nil;
		}
		else
			[queryCondition appendString:[value sqlColumnRepresentationOfSelf]];
	}
	else
	{
		[queryCondition appendString:[value stringValue]];
	}
	
	if (![value isKindOfClass:[NSNumber class]])	
		[queryCondition appendString:@"'"];	
	
	return [self findByCriteria:queryCondition];
}



@interface SQLitePersistentObject (private)
+ (void)tableCheck;
- (void)setPk:(int)newPk;
+ (NSString *)classNameForTableName:(NSString *)theTable;
+ (void)setUpDynamicMethods;
@end
@interface SQLitePersistentObject (private_memory)
+ (void)registerObjectInMemory:(SQLitePersistentObject *)theObject;
+ (void)unregisterObject:(SQLitePersistentObject *)theObject;
- (NSString *)memoryMapKey;
@end

NSMutableDictionary *objectMap;
static id<ORCDataChangedDelegate>__delegate;


@implementation SQLitePersistentObject
#pragma mark Public Class Methods
+(NSArray *)indices
{
	return nil;
}
+(SQLitePersistentObject *)findFirstByCriteria:(NSString *)criteriaString;
{
	NSArray *array = [self findByCriteria:criteriaString];
	if (array != nil)
		if ([array count] > 0)
			return [array objectAtIndex:0];
	return  nil;
}
+(SQLitePersistentObject *)findByPK:(int)inPk
{
	return [self findFirstByCriteria:[NSString stringWithFormat:@"WHERE pk = %d", inPk]];
}
+(NSArray *)findByCriteria:(NSString *)criteriaString
{
	
	[[self class] tableCheck];
	NSMutableArray *ret = [NSMutableArray array];
	
	NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ %@", [[self class] tableName], criteriaString];
	NSArray *result = [[SQLiteInstanceManager sharedManager] executeQuery:query];

	NSDictionary *propertyTypes = [[self class] propertiesWithEncodedTypes];
	
	for (NSDictionary *row in result) {
		id oneItem = [[[self class] alloc] init];
		NSEnumerator *columns = [row keyEnumerator];
		NSString *colName;
		while (colName = [columns nextObject]) {
			if ([colName isEqualToString:@"pk"])
			{
				[oneItem setPk:[[row objectForKey:colName] intValue]];
			}
			else {
				NSString *propName = [colName stringAsPropertyString];
				NSString *propType = [propertyTypes objectForKey:propName];
				if ([propType hasPrefix:@"@"] && [[propType substringWithRange:NSMakeRange(2, [propType length]-3)] isEqualToString:@"NSDate"]) {
					[oneItem setValue:[NSDate objectWithSqlColumnRepresentation:[row objectForKey:colName]] forKey:propName];
				}
				else {
					[oneItem setValue:[row objectForKey:colName] forKey:propName];
				}
			}
				
		}
		[ret addObject:oneItem];
	}
	return ret;
}

+(void)deleteByCriteria:(NSString *)criteriaString {
	[[self class] tableCheck];
	
	NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM %@", [[self class] tableName]];
	if (criteriaString) {
		deleteQuery = [NSString stringWithFormat:@"%@ %@", deleteQuery, criteriaString];
	}
	[[SQLiteInstanceManager sharedManager] executeQuery:deleteQuery];
	
}

+(NSDictionary *)propertiesWithEncodedTypes
{
	//	static NSMutableDictionary *encodedTypesByClass = nil;
	//	
	//	if (encodedTypesByClass == nil)
	//		encodedTypesByClass = [[NSMutableDictionary alloc] init];
	//	
	//	if ([[encodedTypesByClass allKeys] containsObject:[self className]])
	//		return [encodedTypesByClass objectForKey:[self className]];
	
	// DO NOT use a static variable to cache this, it will cause problem with subclasses of classes that are subclasses of SQLitePersistentObject
	
	// Recurse up the classes, but stop at NSObject. Each class only reports its own properties, not those inherited from its superclass
	NSMutableDictionary *theProps;
	
	if ([self superclass] != [NSObject class])
		theProps = (NSMutableDictionary *)[[self superclass] propertiesWithEncodedTypes];
	else
		theProps = [NSMutableDictionary dictionary];
	
	unsigned int outCount;
	
	
	objc_property_t *propList = class_copyPropertyList([self class], &outCount);
	int i;
	
	// Loop through properties and add declarations for the create
	for (i=0; i < outCount; i++)
	{
		objc_property_t * oneProp = propList + i;
		NSString *propName = [NSString stringWithUTF8String:property_getName(*oneProp)];
		NSString *attrs = [NSString stringWithUTF8String: property_getAttributes(*oneProp)];
		NSArray *attrParts = [attrs componentsSeparatedByString:@","];
		if (attrParts != nil)
		{
			if ([attrParts count] > 0)
			{
				NSString *propType = [[attrParts objectAtIndex:0] substringFromIndex:1];
				[theProps setObject:propType forKey:propName];
			}
		}
	}
	//	[encodedTypesByClass setValue:theProps forKey:[self className]];
	return theProps;	
}
#pragma mark -
#pragma mark Public Instance Methods
-(int)pk
{
	return pk;
}
-(void)save
{
	[[self class] tableCheck];
	
	
	// If this object is new, we need to figure out the correct primary key value, 
	// which will be one higher than the current highest pk value in the table.
	BOOL isNew = ![self existsInDB];
	if (isNew)
	{
		NSString *pkQuery = [NSString stringWithFormat:@"SELECT MAX(PK) as pk FROM %@", [[self class] tableName]];
		NSArray *pkResult = [[SQLiteInstanceManager sharedManager] executeQuery:pkQuery];
		id nextPK = [[pkResult objectAtIndex:0] objectForKey:@"pk"];
		if ([NSNull null] != nextPK) {
			pk = [nextPK intValue] + 1;
		}
		else {
			pk = 1;
		}
	}
	
	NSMutableString *updateSQL = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (pk", [[self class] tableName]];
	
	NSMutableString *bindSQL = [NSMutableString string];
	
	NSDictionary *props = [[self class] propertiesWithEncodedTypes];
	NSMutableDictionary *substitutions = [NSMutableDictionary dictionaryWithCapacity:[[props allKeys] count] + 1];
	[substitutions setObject:[NSNumber numberWithInt:pk] forKey:@"pk"];
	for (NSString *propName in props)
	{
		NSString *propType = [[[self class] propertiesWithEncodedTypes] objectForKey:propName];
		NSString *className = @"";
		if ([propType hasPrefix:@"@"])
			className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
		if (! (isNSSetType(className) || isNSArrayType(className) || isNSDictionaryType(className)))
		{
			NSString *columnName = [propName stringAsSQLColumnName];
			[updateSQL appendFormat:@", %@", columnName];
			[substitutions setValue:[self valueForKey:propName] forKey:columnName];
			[bindSQL appendFormat:@", :%@",columnName];
		}
	}
	
	[updateSQL appendFormat:@") VALUES (:pk%@)", bindSQL];
	
	

	[[SQLiteInstanceManager sharedManager] executeQuery:updateSQL substitutions:substitutions];
	if (isNew) {
		[__delegate objectOfClass:self.class withPk:pk was:CreatedAction];
	}

}
-(BOOL) existsInDB
{
	return pk >= 0;
}
-(void)deleteObject
{
	[[self class] tableCheck];
		
	NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM %@ WHERE pk = %d", [[self class] tableName], pk];
		
	[[SQLiteInstanceManager sharedManager] executeQuery:deleteQuery];

}
#pragma mark -
#pragma mark NSObject Overrides 

+ (BOOL)resolveClassMethod:(SEL)theMethod
{
	NSString *methodBeingCalled = [NSString stringWithUTF8String: sel_getName(theMethod)];
	
	if ([methodBeingCalled hasPrefix:@"findBy"])
	{
		NSRange theRange = NSMakeRange(6, [methodBeingCalled length] - 7);
		NSString *property = [[methodBeingCalled substringWithRange:theRange] stringByLowercasingFirstLetter];
		NSDictionary *properties = [self propertiesWithEncodedTypes];
		if ([[properties allKeys] containsObject:property])
		{
			SEL newMethodSelector = sel_registerName([methodBeingCalled UTF8String]);
			
			// Hardcore juju here, this is not documented anywhere in the runtime (at least no
			// anywhere easy to find for a dope like me), but if you want to add a class method
			// to a class, you have to get the metaclass object and add the clas to that. If you
			// add the method
			Class selfMetaClass = objc_getMetaClass([[self className] UTF8String]);
			return (class_addMethod(selfMetaClass, newMethodSelector, (IMP) findByMethodImp, "@@:@")) ? YES : [super resolveClassMethod:theMethod];
		}
		else
			return [super resolveClassMethod:theMethod];
	}
	return [super resolveClassMethod:theMethod];
}
-(id)init
{
	if (self=[super init])
	{
		pk = -1;
	}
	return self;
}
- (void)dealloc 
{
	[[self class] unregisterObject:self];
	[super dealloc];
}
#pragma mark -
#pragma mark Private Methods
+ (NSString *)classNameForTableName:(NSString *)theTable
{
	static NSMutableDictionary *classNamesForTables = nil;
	
	if (classNamesForTables == nil)
		classNamesForTables = [[NSMutableDictionary alloc] init];
	
	if ([[classNamesForTables allKeys] containsObject:theTable])
		return [classNamesForTables objectForKey:theTable];
	
	
	NSMutableString *ret = [NSMutableString string];
	
	BOOL lastCharacterWasUnderscore = NO;
	for (int i = 0; i < theTable.length; i++)
	{
		NSRange range = NSMakeRange(i, 1);
		NSString *oneChar = [theTable substringWithRange:range];
		if ([oneChar isEqualToString:@"_"])
			lastCharacterWasUnderscore = YES;
		else
		{
			if (lastCharacterWasUnderscore || i == 0)
				[ret appendString:[oneChar uppercaseString]];
			else
				[ret appendString:oneChar];
			
			lastCharacterWasUnderscore = NO;
		}
	}
	[classNamesForTables setObject:ret forKey:theTable];
	
	return ret;
}
+ (NSString *)tableName
{
	static NSMutableDictionary *tableNamesByClass = nil;
	
	if (tableNamesByClass == nil)
		tableNamesByClass = [[NSMutableDictionary alloc] init];
	
	if ([[tableNamesByClass allKeys] containsObject:[self className]])
		return [tableNamesByClass objectForKey:[self className]];
	
	// Note: Using a static variable to store the table name
	// will cause problems because the static variable will 
	// be shared by instances of classes and their subclasses
	// Cache in the instances, not here...
	NSMutableString *ret = [NSMutableString string];
	NSString *className = [self className];
	for (int i = 0; i < className.length; i++)
	{
		NSRange range = NSMakeRange(i, 1);
		NSString *oneChar = [className substringWithRange:range];
		if ([oneChar isEqualToString:[oneChar uppercaseString]] && i > 0)
			[ret appendFormat:@"_%@", [oneChar lowercaseString]];
		else
			[ret appendString:[oneChar lowercaseString]];
	}
	
	[tableNamesByClass setObject:ret forKey:[self className]];
	return ret;
}
+(void)tableCheck
{
	static NSMutableArray *checked = nil;
	
	if (checked == nil)
		checked = [[NSMutableArray alloc] init];
	
	if (![checked containsObject:[self className]])
	{
		[checked addObject:[self className]];
		
		// Do not use static variables to cache information in this method, as it will be
		// shared across subclasses. Do caching in instance methods.

		NSMutableString *createSQL = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (pk INTEGER PRIMARY KEY",[self tableName]];
		
		
		for (NSString *oneProp in [[self class] propertiesWithEncodedTypes])
		{ 
			NSString *propName = [oneProp stringAsSQLColumnName];
			NSString *propType = [[[self class] propertiesWithEncodedTypes] objectForKey:oneProp];
			// Integer Types
			if ([propType isEqualToString:@"i"] || // int
				[propType isEqualToString:@"I"] || // unsigned int
				[propType isEqualToString:@"l"] || // long
				[propType isEqualToString:@"L"] || // usigned long
				[propType isEqualToString:@"q"] || // long long
				[propType isEqualToString:@"Q"] || // unsigned long long
				[propType isEqualToString:@"s"] || // short
				[propType isEqualToString:@"S"] ||  // unsigned short
				[propType isEqualToString:@"B"] )   // bool or _Bool
			{
				[createSQL appendFormat:@", %@ INTEGER", propName];		
			}	
			// Character Types
			else if ([propType isEqualToString:@"c"] ||	// char
					 [propType isEqualToString:@"C"] )  // unsigned char
			{
				[createSQL appendFormat:@", %@ TEXT", propName];
			}
			else if ([propType isEqualToString:@"f"] || // float
					 [propType isEqualToString:@"d"] )  // double
			{		 
				[createSQL appendFormat:@", %@ REAL", propName];
			}
			else if ([propType hasPrefix:@"@"] ) // Object
			{
				
				
				NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
				
				// Collection classes have to be handled differently. Instead of adding a column, we add a child table.
				// Child tables will have a field for holding data and also a non-required foreign key field. If the
				// object stored in the collection is a subclass of SQLitePersistentObject, then it is stored as
				// a reference to the row in the table that holds the object. If it's not, then it is stored
				// in the field using the SQLitePersistence protocol methods. If it's not a subclass of 
				// SQLitePersistentObject and doesn't conform to NSCoding then the object won't get persisted.
				if (isNSArrayType(className))
				{
					NSString *xRefQuery = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@_%@ (parent_pk, array_index INTEGER, fk INTEGER, fk_table_name TEXT, object_data TEXT, object_class BLOB, PRIMARY KEY (parent_pk, array_index))", [self tableName], [propName stringAsSQLColumnName]];
					[[SQLiteInstanceManager sharedManager] executeQuery:xRefQuery];
					
				}
				else if (isNSDictionaryType(className))
				{
					NSString *xRefQuery = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@_%@ (parent_pk integer, dictionary_key TEXT, fk INTEGER, fk_table_name TEXT, object_data BLOB, object_class TEXT, PRIMARY KEY (parent_pk, dictionary_key))", [self tableName], [propName stringAsSQLColumnName]];
					[[SQLiteInstanceManager sharedManager] executeQuery:xRefQuery];
				}
				else if (isNSSetType(className))
				{
					NSString *xRefQuery = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@_%@ (parent_pk INTEGER, fk INTEGER, fk_table_name TEXT, object_data BLOB, object_class TEXT)", [self tableName], [propName stringAsSQLColumnName]];
					[[SQLiteInstanceManager sharedManager] executeQuery:xRefQuery];
				}
				else
				{
					Class propClass = objc_lookUpClass([className UTF8String]);
					
					if ([propClass isSubclassOfClass:[SQLitePersistentObject class]])
					{
						// Store persistent objects as quasi foreign-key reference. We don't use
						// datbase's referential integrity tools, but rather use the memory map
						// key to store the table and fk in a single text field
						[createSQL appendFormat:@", %@ TEXT", propName];
					}
					else if ([propClass canBeStoredInSQLite])
					{
						[createSQL appendFormat:@", %@ %@", propName, [propClass columnTypeForObjectStorage]];
					}
				}
				
			}
			
			
		}	 
		[createSQL appendString:@")"];
		
		[[SQLiteInstanceManager sharedManager] executeQuery:createSQL];
		NSArray *theIndices = [self indices];
		if (theIndices != nil)
		{
			if ([theIndices count] > 0)
			{
				for (NSArray *oneIndex in theIndices)
				{
					NSMutableString *indexName = [NSMutableString stringWithString:[self tableName]];
					NSMutableString *fieldCondition = [NSMutableString string];
					BOOL first = YES;
					for (NSString *oneField in oneIndex)
					{
						[indexName appendFormat:@"_%@", [oneField stringAsSQLColumnName]];
						
						if (first) 
							first = NO;
						else
							[fieldCondition appendString:@", "];
						[fieldCondition appendString:[oneField stringAsSQLColumnName]];
					}
					NSString *indexQuery = [NSString stringWithFormat:@"create index if not exists %@ on %@ (%@)", indexName, [self tableName], fieldCondition];
					[[SQLiteInstanceManager sharedManager] executeQuery:indexQuery];
				}
				
				
				
			}
		}
	}
}

+ (void)setDataChangedDelegate:(id<ORCDataChangedDelegate>)delegate {
	__delegate = delegate;
}

- (void)setPk:(int)newPk
{
	pk = newPk;
}
#pragma mark -
#pragma mark Memory Map Methods
- (NSString *)memoryMapKey
{
	return [NSString stringWithFormat:@"%@-%d", [self className], [self pk]];
}
+ (void)registerObjectInMemory:(SQLitePersistentObject *)theObject
{

	
}
+ (void)unregisterObject:(SQLitePersistentObject *)theObject
{

}

@end
