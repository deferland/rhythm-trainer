//
//  SQLiteDatabaseException.h
//  AList
//
//  Created by Christopher Garrett on 6/3/08.
//  Copyright 2008 ZWorkbench, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sqlite3.h>


@interface SQLiteDatabaseException : NSObject {

}
+ (SQLiteDatabaseException *)exceptionFromSQLite: (sqlite3 *)connection;

@end
