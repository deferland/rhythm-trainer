//
//  ConnectionAdapter.m
//  AList
//
//  Created by Christopher Garrett on 6/1/08.
//  Copyright 2008 ZWorkbench, Inc.. All rights reserved.
//

#import "SQLiteConnectionAdapter.h"
#import "SQLiteDatabaseException.h"

#define kDefaultDBFile @"app.db"

static SQLiteConnectionAdapter *defaultInstance;


@implementation SQLiteConnectionAdapter

+(SQLiteConnectionAdapter *)defaultInstance
{
	if (!defaultInstance) {
		defaultInstance = [[SQLiteConnectionAdapter alloc] init];
	}
	return defaultInstance;
}

+(void)releaseDefaultInstance
{
   if (defaultInstance) {
      [defaultInstance release];      
   }
}


- (id) init
{
 	// First, test for existence of a writable db file.
   NSFileManager *fileManager = [NSFileManager defaultManager];
   NSError *error;
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *documentsDirectory = [paths objectAtIndex:0];
   NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:kDefaultDBFile];
   if (![fileManager fileExistsAtPath:writableDBPath]) {
      NSLog(@"Database doesn't exist, copying from starting database.");
	    // The writable database does not exist, so copy the default to the appropriate location.
	    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDefaultDBFile];
	    if (![fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error]) {
	        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	    }	
	} else {
      NSLog(@"Database already exists in %@.", writableDBPath);
   }
   // Open the database. The database was prepared outside the application.
   if (sqlite3_open([writableDBPath UTF8String], &connection) != SQLITE_OK) {
        NSAssert1(0, @"Failed to open connection with message '%s'.", sqlite3_errmsg(connection));
   }

	tables = [[NSMutableDictionary alloc] init];

	preparedStatements = [[NSMutableDictionary alloc] init];
	return self;
}

- (void) dealloc
{
	[preparedStatements release];
	[tables release];
    if (sqlite3_close(connection) != SQLITE_OK) {
		NSLog(@"Failed to close database connection with message %s", sqlite3_errmsg(connection));
    }
	connection = NULL;
	if (self == defaultInstance) {
		defaultInstance = nil;
	}
   [super dealloc];
}

-(SQLiteTable *)tableNamed:(NSString *)tableName
{
	SQLiteTable *result = (SQLiteTable *)[tables objectForKey: tableName];
	if (!result) {
		result = [[SQLiteTable alloc] initWithName: tableName];		
		[tables setObject: result forKey: tableName];
		[result release];
	}
	return result;
}


-(SQLitePreparedStatement *)preparedStatement:(NSString *)sql
{
	if (![preparedStatements objectForKey: sql]) {
		SQLitePreparedStatement *statement = [[SQLitePreparedStatement alloc] initWithConnection: connection sql: sql];
		[preparedStatements setObject: statement forKey: sql];
		[statement release];		
	}
	return (SQLitePreparedStatement *) [preparedStatements objectForKey: sql];
}

-(QueryResult *)prepareAndExecute: (NSString *)sql
{
	return [[self preparedStatement: sql] execute];
}

- (void) beginTransaction
{
	sqlite3_exec(connection, "begin transaction", NULL, NULL, NULL);
}

- (void) commitTransaction
{
	sqlite3_exec(connection, "commit transaction", NULL, NULL, NULL);
}

- (void) rollbackTransaction
{
	sqlite3_exec(connection, "rollback transaction", NULL, NULL, NULL);
}

- (void) handleSQLiteError
{
	@throw [SQLiteDatabaseException exceptionFromSQLite: connection];
}


@end
