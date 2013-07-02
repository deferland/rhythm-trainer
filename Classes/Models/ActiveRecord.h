//
//  ActiveRecord.h
//  AList
//
//  Created by Christopher Garrett on 6/1/08.
//  Copyright 2008 ZWorkbench, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLiteConnectionAdapter.h"
#import "SQLitePreparedStatement.h"

#define kPrimaryKeyName @"PrimaryKey"
#define kCreatedAt @"created_at"
#define kUpdatedAt @"updated_at"


// Here's a failed experiment in preprocessor magic.  I'd like to be able to generate getters and setters for active record fields,
// but it gives compiler warnings.  If you're reading this, and you know how to do it, please let me know!

#define Tokenize(token1, token2) token1 ## token2

#define ActiveRecordField(camelCaseName, capitalizedName, type) \
   + (type) camelCaseName; \
   + (void) Tokenize(set, capitalizedName): (type) value;

#define ActiveRecordSynthesize(camelCaseName, capitalizedName, columnName, type) \
   + (type) camelCaseName { return (type) [self getAttributeNamed: [NSString stringWithUTF8String: #columnName]]; } \
   + (void) Tokenize(set, capitalizedName): (type) value { [self setAttributeNamed: [NSString stringWithUTF8String: #columnName] value: value]; }

@interface ActiveRecord : NSObject {
	NSMutableDictionary *attributes;
   NSMutableArray *dateFormatters;
	BOOL newRecord;
}

@property(nonatomic) BOOL newRecord;
@property(nonatomic, retain) NSMutableArray *dateFormatters;

+ (void) deleteAll;
+ (NSInteger) count;
+ (NSString *)tableName;
+ (SQLiteTable *)table;
+ (SQLiteConnectionAdapter *)connection;
+ (NSArray *)buildObjectsFromQueryResult: (QueryResult *)queryResult;

+ (NSString *) concatenatedColumnNames;
- (NSString *) concatenatedColumnNames;

// Finders 
// First parameter is the SQL for a WHERE clause, and subsequent params are bindings to that clause
+ (NSArray *)findAll;
+ (NSArray *) findByCondition: (NSString *)condition, ...;
+ (ActiveRecord *)findByPrimaryKey:(NSInteger)key;
// First parameter is the SQL for a WHERE clause, and subsequent params are bindings to that clause
+ (NSArray *) findBySQL: (NSString *)sql, ...;
+ (NSArray *) findBySQL: (NSString *)sql variables: (va_list) bindings;
+ (void) deleteAllWithCondition: (NSString *)condition, ...;

- (id)initWithAttributes: (NSDictionary *)attributes newRecord:(BOOL)newRecord;

- (SQLiteConnectionAdapter *)connection;
- (void)create;
- (void)save;
- (void)refresh;
- (void)delete;
// Deletes all attributes and marks the object as a new record
- (void)clean;

- (NSTimeInterval)timeIntervalFromString:(NSString *)xmlString;
- (NSString *) toXML;

- (void)setAttributeNamed:(NSString *)attributeName value:(id)value;

- (NSString *) createdAtAttributeName;
- (NSString *) updatedAtAttributeName;

- (id)getAttributeNamed:(NSString *)attributeName;
- (NSInteger)getIntegerAttributeNamed:(NSString *)attributeName;
- (NSValue *)getValueAttributeNamed:(NSString *)attributeName;
- (NSNumber *)getNumberAttributeNamed:(NSString *)attributeName;
- (BOOL)getBooleanAttributeNamed:(NSString *)attributeName;
- (NSDate *)getDateAttributeNamed:(NSString *)attributeName;
- (double)getFloatAttributeNamed:(NSString *)attributeName;

- (NSInteger)primaryKey;
- (NSString *)findByPrimaryKeyStatement;
- (void)bindAttributesToStatement: (SQLitePreparedStatement *)statement;
- (NSString *)textFromDatetimeAttribute:(NSString *)attributeName;
- (NSArray *) activeRecordAttributeKeys;

// Callbacks
- (void) beforeCreate;

// convinience
-(NSString *) name;

@end
