//
//  ConnectionAdapter.h
//  AList
//
//  Created by Christopher Garrett on 6/1/08.
//  Copyright 2008 ZWorkbench, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sqlite3.h>
#import "SQLitePreparedStatement.h"
#import "QueryResult.h"
#import "SQLiteTable.h"


@interface SQLiteConnectionAdapter : NSObject {
   sqlite3 *connection;
	NSMutableDictionary *preparedStatements;
	NSMutableDictionary *tables;
}

+(SQLiteConnectionAdapter *)defaultInstance; 
+(void)releaseDefaultInstance;

- (void) beginTransaction;
- (void) commitTransaction;
- (void) rollbackTransaction;
- (void) handleSQLiteError;

-(SQLitePreparedStatement *)preparedStatement:(NSString *)sql;
-(QueryResult *)prepareAndExecute: (NSString *)sql;
-(SQLiteTable *)tableNamed:(NSString *)tableName;

@end
