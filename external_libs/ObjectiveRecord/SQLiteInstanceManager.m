//
//  SQLiteInstanceManager.m
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

#import "SQLiteInstanceManager.h"
#import "NSDate-SQLitePersistence.h"

#ifndef debugLog(...)
	#define debugLog(...)
#endif

static SQLiteInstanceManager *sharedSQLiteManager = nil;

#pragma mark Private Method Declarations
@interface SQLiteInstanceManager (private)
- (NSString *)databaseFilepath;
@end

@implementation SQLiteInstanceManager
#pragma mark -
#pragma mark Singleton Methods
+ (id)sharedManager 
{
	@synchronized(self) 
	{
        if (sharedSQLiteManager == nil) 
            [[self alloc] init]; 
    }
    return sharedSQLiteManager;
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedSQLiteManager == nil) 
		{
            sharedSQLiteManager = [super allocWithZone:zone];
            return sharedSQLiteManager; 
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)retain
{
    return self;
}
- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release
{
    // never release
}
- (id)autorelease
{
    return self;
}
#pragma mark -
-(sqlite3 *)database
{
	static BOOL first = YES;
	
	if (first || database == NULL)
	{
		first = NO;
		if (!sqlite3_open([[self databaseFilepath] UTF8String], &database) == SQLITE_OK) 
		{
			// Even though the open failed, call close to properly clean up resources.
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			sqlite3_close(database);
		}
		char *errorMsg = 0;
		if (sqlite3_exec(database, "PRAGMA encoding = \"UTF-8\"", NULL, NULL, &errorMsg) != SQLITE_OK) {
			NSAssert1(0, @"Failed to switch encoding to UTF-8 with message '%s'.",  errorMsg);
			sqlite3_free(errorMsg);
		} 
	}
	return database;
}

- (NSArray *)columnsForQuery:(sqlite3_stmt *)query
{
	int columnCount = sqlite3_column_count(query);
	if(columnCount <= 0)
		return nil;
	
	NSMutableArray *columnNames = [NSMutableArray array];
	for(int i = 0; i < columnCount; ++i)
	{
		const char *name;
		name = sqlite3_column_name(query, i);
		[columnNames addObject:[NSString stringWithUTF8String:name]];
	}
	return columnNames;
}


// You have to step through the *query yourself,
- (id)valueForColumn:(unsigned int)colIndex query:(sqlite3_stmt *)query
{
	int columnType = sqlite3_column_type(query, colIndex);
	switch(columnType)
	{
		case SQLITE_INTEGER:
			return [NSNumber numberWithInt:sqlite3_column_int(query, colIndex)];
			break;
		case SQLITE_FLOAT:
			return [NSNumber numberWithDouble:sqlite3_column_double(query, colIndex)];
			break;
		case SQLITE_BLOB:
			return [NSData dataWithBytes:sqlite3_column_blob(query, colIndex)
								  length:sqlite3_column_bytes(query, colIndex)];
			break;
		case SQLITE_NULL:
			return [NSNull null];
			break;
		case SQLITE_TEXT:
			return [NSString stringWithUTF8String:(const char *)sqlite3_column_text(query, colIndex)];
			break;
		default:
			// It really shouldn't ever come to this.
			break;
	}
	return nil;
}

- (void)beginTransaction {
	[self executeQuery:@"BEGIN"];
}
- (void)commitTransaction {
	[self executeQuery:@"COMMIT"];
}
- (void)rollbackTransaction {
	[self executeQuery:@"ROLLBACK"];
}

- (NSArray *)executeQuery:(NSString *)sql  {
	return [self executeQuery:sql substitutions:nil];
}

- (NSArray *)executeQuery:(NSString *)sql substitutions:(NSDictionary *)substitutions {
	@synchronized(self) {
		sqlite3 *db = [self database];
		
		sqlite3_stmt *stmt;
		const char *errMsg;
		int err = sqlite3_prepare_v2(db, [sql UTF8String], 
									 [sql lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 
									 &stmt, &errMsg);
		
		if(err != SQLITE_OK || stmt == NULL)
		{
			NSLog(@"ERROR Couldn't prepare(%@), %@", sql, [NSString stringWithUTF8String:sqlite3_errmsg(db)]);
			return nil;
		}
		else {
			debugLog(sql);
		}
		
		NSArray *columnNames = [self columnsForQuery:stmt];
		
		for(int i = 1; i <= sqlite3_bind_parameter_count(stmt); ++i)
		{
			const char *keyCstring = sqlite3_bind_parameter_name(stmt, i);
			if(!keyCstring)
				continue;
			
			NSString *key = [[NSString stringWithUTF8String:keyCstring] stringByReplacingOccurrencesOfString:@":" withString:@""];
			id sub = [substitutions objectForKey:key];
			if(!sub)
				continue;
			if([sub isMemberOfClass:[NSString class]] || [[sub className] isEqualToString:@"NSCFString"])
				sqlite3_bind_text(stmt, i, [sub UTF8String], -1, SQLITE_TRANSIENT);
			else if([sub isMemberOfClass:[NSData class]])
				sqlite3_bind_blob(stmt, i, [sub bytes], [sub length], SQLITE_STATIC); // Not sure if we should make this transient
			else if([[sub className] isEqualToString:@"NSCFNumber"])
				sqlite3_bind_double(stmt, i, [sub doubleValue]);
			else if([sub isMemberOfClass:[NSNull class]])
				sqlite3_bind_null(stmt, i);
			else if([sub isKindOfClass:[NSDate class]])
				sqlite3_bind_text(stmt, i, [[sub sqlColumnRepresentationOfSelf] UTF8String], -1, NULL);
			else
				NSLog(@"ERROR SQLiteInstanceManager doesn't know how to handle this type of object: %@ class: %@", sub, [sub className]);
		}
		
		
		NSMutableArray *result = [NSMutableArray array];
		NSMutableDictionary *columns;
		int resultCode = 0;
		while((resultCode = sqlite3_step(stmt)) != SQLITE_DONE)
		{
			if(resultCode == SQLITE_ERROR || err == SQLITE_MISUSE)
			{
				NSLog(@"ERROR while running \"%@\" %@", sql, [NSString stringWithUTF8String:sqlite3_errmsg(db)]);
				break;
			}
			else if(resultCode == SQLITE_ROW)
			{
				// construct the dictionary for the row
				columns = [NSMutableDictionary dictionary];
				int i = 0;
				for (NSString *columnName in columnNames)
				{
					id value = [self valueForColumn:i query:stmt];
					if ([NSNull null] != value) {
						[columns setObject:value forKey:columnName];
					}
					++i;
				}
				[result addObject:columns];
			}
		}
		
		sqlite3_finalize(stmt);

		return result;
	}
	return nil;
}

#pragma mark -
- (void)dealloc
{
	[databaseFilepath release];
	[super dealloc];
}
#pragma mark -
#pragma mark Private Methods
- (NSString *)databaseFilepath
{
	if (databaseFilepath == nil)
	{
		NSMutableString *ret = [NSMutableString string];
		NSString *appName = [[NSProcessInfo processInfo] processName];
		for (int i = 0; i < [appName length]; i++)
		{
			NSRange range = NSMakeRange(i, 1);
			NSString *oneChar = [appName substringWithRange:range];
			if (![oneChar isEqualToString:@" "]) 
				[ret appendString:[oneChar lowercaseString]];
		}
#if (TARGET_OS_MAC && ! (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR))
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
		NSString *saveDirectory = [basePath stringByAppendingPathComponent:appName];
#else
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *saveDirectory = [paths objectAtIndex:0];
#endif
		NSString *saveFileName = [NSString stringWithFormat:@"%@.sqlite3", ret];
		NSString *filepath = [saveDirectory stringByAppendingPathComponent:saveFileName];
		
		databaseFilepath = [filepath retain];
		debugLog(databaseFilepath);
		if (![[NSFileManager defaultManager] fileExistsAtPath:saveDirectory]) 
			[[NSFileManager defaultManager] createDirectoryAtPath:saveDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return databaseFilepath;
}
@end
