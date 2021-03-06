//
//  SQLitePreparedStatement.h
//  AList
//
//  Created by Christopher Garrett on 6/1/08.
//  Copyright 2008 ZWorkbench, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sqlite3.h>
#import "QueryResult.h"

@interface SQLitePreparedStatement : NSObject {
	sqlite3_stmt *statement;
	sqlite3 *connection;
	NSString *sql;
}
- (id)initWithConnection:(sqlite3 *)connection sql:(NSString *)sql;
- (QueryResult *)execute;
- (QueryResult *)executeWithOperation:(NSOperation *)operation;
// Returns the new primary key instead of a query result
- (NSNumber *)executeAsInsert;
- (QueryResult *)executeWithOperation:(NSOperation *)operation bindingVariables: (va_list)bindings;

// Note that binding methods used zero-based indexing (as opposed to SQLite's 1-based indexing)
- (void)bindTextValue: (NSString *)text toColumn: (NSInteger)column;
- (void)bindInteger: (NSInteger)value toColumn: (NSInteger)column;
- (void)bindIntegerValue: (NSNumber *)value toColumn: (NSInteger)column;
- (void)bindFloatValue: (NSNumber *)value toColumn: (NSInteger)column;
- (void)bindFloat: (double)value toColumn: (NSInteger)column;
- (void)bindValue: (NSObject *)value toColumn: (NSInteger)column;

- (NSInteger) bindingCount;

@end
