//
//  ActiveRecord.m
//  AList
//
//  Created by Christopher Garrett on 6/1/08.
//  Copyright 2008 ZWorkbench, Inc.. All rights reserved.
//

#import "ActiveRecord.h"
#import "SQLiteConnectionAdapter.h"

#import "ModelConstants.h"

@implementation ActiveRecord

@synthesize newRecord, dateFormatters;

+ (NSString *)tableName
{
	return [NSString stringWithFormat: @"%@s", [[self class] description]];
}

+ (SQLiteConnectionAdapter *)connection {
	return [SQLiteConnectionAdapter defaultInstance];
}

+ (NSInteger) count
{
	NSString *sql = [[NSString alloc] initWithFormat: @"select count(*) from %@", [[self class] tableName]];
	QueryResult *result = [[ActiveRecord connection] prepareAndExecute: sql];
   [sql release];
	NSInteger count = [[result firstRow] integerValueForColumn: @"count(*)"];
	return count;
}

+ (void)deleteAll
{
	NSString *deleteSQL = [NSString stringWithFormat: @"delete from %@", [self tableName]];
	[[[self connection] preparedStatement: deleteSQL] execute];
}

+ (SQLiteTable *)table
{
	return [[[self class] connection] tableNamed: [[self class] tableName]];
}

+ (NSArray *)findAll{
	return [self findByCondition:@"1 = 1"];
}

+ (NSArray *) findByCondition: (NSString *)condition, ...
{
   NSString *sql = [NSString stringWithFormat: @"select %@ from %@ where %@", [self concatenatedColumnNames], [self tableName], condition];
   va_list bindings;
   va_start(bindings, condition);          // Start scanning for arguments after firstObject.
   return [self findBySQL: sql variables: bindings]; 
}

+ (ActiveRecord *)findByPrimaryKey:(NSInteger)key
{
   NSString *sql = [NSString stringWithFormat: @"%@ = ?", kPrimaryKeyName];
   return [[self findByCondition: sql, [NSNumber numberWithInteger:key]] objectAtIndex: 0];
}

+ (NSArray *) findBySQL: (NSString *)sql, ...
{
   va_list bindings;
   va_start(bindings, sql);          // Start scanning for arguments after firstObject.
   return [self findBySQL: sql variables: bindings];
}

+ (NSArray *) findBySQL: (NSString *)sql variables: (va_list) bindings
{
   SQLitePreparedStatement *statement = [[self connection] preparedStatement: sql];
   QueryResult *queryResult = [statement executeWithOperation: nil bindingVariables: bindings];
   return [self buildObjectsFromQueryResult: queryResult];
}

+ (void) deleteAllWithCondition: (NSString *)condition, ...
{
   NSString *sql = [NSString stringWithFormat: @"delete from %@ where %@", [self tableName], condition];
   va_list bindings;
   va_start(bindings, condition);          // Start scanning for arguments after firstObject.
   SQLitePreparedStatement *statement = [[self connection] preparedStatement: sql];
   [statement executeWithOperation: nil bindingVariables: bindings];
}

+ (NSArray *)buildObjectsFromQueryResult: (QueryResult *)queryResult
{
   NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
   NSEnumerator *rowEnum = [queryResult rowEnumerator];
   QueryRow *row;
   ActiveRecord *newObject;
   while (row = (QueryRow *)[rowEnum nextObject]) {
      newObject = [[[self class] alloc] initWithAttributes: [row columnValues] newRecord: NO];
      [result addObject: newObject];
      [newObject release];
   }
   return result;
}

+ (NSString *) concatenatedColumnNames
{
	NSArray *columnNames = [[self table] columnNames];
	return [columnNames componentsJoinedByString: @", "];   
}


- (id)init
{
	if (self = [super init]) {
		attributes = [[NSMutableDictionary alloc] init];
		newRecord = YES;
	}
	return self;
}

- (NSMutableArray *)dateFormatters {
   if (dateFormatters == nil) {
      self.dateFormatters = [[[NSMutableArray alloc] init] autorelease];
      NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
      [dateFormatter1 setDateFormat: @"yyyy-MM-dd'T'HH:mm:ssZ"];
      NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
      [dateFormatter2 setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
      [dateFormatters addObject: dateFormatter1];
      [dateFormatter1 release];
      [dateFormatters addObject: dateFormatter2];
      [dateFormatter2 release];      
   }
   return dateFormatters;
}

- (id)initWithAttributes: (NSDictionary *)newAttributes newRecord: (BOOL)isNewRecord;
{
   [self init];
   newRecord = isNewRecord;
   [attributes addEntriesFromDictionary: newAttributes];
   return self;
}

- (void) dealloc
{
	[attributes release];
   self.dateFormatters = nil;
	[super dealloc];
}

- (SQLiteConnectionAdapter *)connection {
	return [SQLiteConnectionAdapter defaultInstance];
}


- (void)create
{
   [self beforeCreate];
	[self setAttributeNamed: [self createdAtAttributeName] value: [NSNumber numberWithDouble: [NSDate timeIntervalSinceReferenceDate]]];
	// Build the SQL insertion string
	NSArray *columnNames = [attributes allKeys];
	NSEnumerator *columnEnum = [columnNames objectEnumerator];
	NSMutableString *bindings = [[NSMutableString alloc] init];
	if ([columnEnum nextObject]) {
		[bindings appendString: @"?"];
	}
	while ([columnEnum nextObject]) {
		[bindings appendString: @", ?"];			
	}
	NSString *columnList = [columnNames componentsJoinedByString: @", "];
	NSString *creationSQL;
	creationSQL = [NSString stringWithFormat: @"INSERT INTO %@ (%@) VALUES(%@)", [[self class] tableName], columnList, bindings];
	[bindings release];
	
	// Now bind the column values to the SQL
	SQLitePreparedStatement *statement = [[self connection] preparedStatement: creationSQL];
	[self bindAttributesToStatement: statement];
	[self setAttributeNamed: kPrimaryKeyName value: [statement executeAsInsert]];
	newRecord = NO;
}

- (void) delete {
	NSString *deleteSQL = [NSString stringWithFormat: @"delete from %@ where PrimaryKey = %d", [[self class] tableName],[self primaryKey]];
	[[[self connection] preparedStatement: deleteSQL] execute];
	[self clean];
}

- (void)clean
{
	[attributes removeAllObjects];
	newRecord = YES;
}

- (void)save
{
	[self setAttributeNamed: [self updatedAtAttributeName] value: [NSNumber numberWithDouble: [NSDate timeIntervalSinceReferenceDate]]];
	if (newRecord) {
		[self create];
	} else {
      // Build the SQL insertion string
      NSArray *columnNames = [attributes allKeys];
      NSMutableString *bindings = [[NSMutableString alloc] init];
      [bindings appendString: [columnNames componentsJoinedByString: @"=?, "]];
      [bindings appendString: @"=? "];
      
      NSString *updateSQL = [NSString stringWithFormat: @"UPDATE %@ SET %@ where PrimaryKey=?", [[self class] tableName], bindings];
      [bindings release];
      
      // Now bind the column values to the SQL
      SQLitePreparedStatement *statement = [[self connection] preparedStatement: updateSQL];
      [self bindAttributesToStatement: statement];
		[statement bindInteger: [self primaryKey] toColumn: [columnNames count]]; // Bind it to the last param
      [statement execute];
   }
}


- (void)bindAttributesToStatement:(SQLitePreparedStatement *)statement
{
	NSEnumerator *columnEnum = [[attributes allKeys] objectEnumerator];
	NSString *columnName;
	int index = 0;
	while (columnName = (NSString *)[columnEnum nextObject]) {
      [statement bindValue: [attributes objectForKey: columnName] toColumn: index];
		index++;
	}	
}

// Populate the Guest with all the values from the database
- (void)refresh
{
	if (!newRecord) {
		SQLitePreparedStatement *statement = [[self connection] preparedStatement: [self findByPrimaryKeyStatement]];
		[statement bindInteger: [self primaryKey]  toColumn: 0];
		QueryRow *row = [[statement execute] firstRow];
		[attributes addEntriesFromDictionary: [row columnValues]];		
	}
}

- (NSString *)toXML
{
	return nil;
}

- (NSTimeInterval)timeIntervalFromString:(NSString *)dateString
{
	NSTimeInterval result;
	if (dateString) {
      NSEnumerator *dateFormatterEnum = [self.dateFormatters objectEnumerator];
      NSDateFormatter *dateFormatter;
      NSDate *date = nil;
      while (!date && (dateFormatter = (NSDateFormatter *)[dateFormatterEnum nextObject])) {
         date =  [dateFormatter dateFromString: dateString];
      }
      NSAssert1(date, @"Could not parse date from string: %@", dateString);
      result = [date timeIntervalSinceReferenceDate];         
	} else {
		result =  0.0;
	}
	return result;
}

- (NSString *)textFromDatetimeAttribute:(NSString *)attributeName
{
	NSDate *date = [self getDateAttributeNamed: attributeName];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
   NSString *result =  [dateFormatter stringFromDate: date];
	[dateFormatter release];
	return result;
}

- (void)setAttributeNamed:(NSString *)attributeName value:(id)value
{
   if (value == nil) {
      [attributes setObject: [NSNull null] forKey: attributeName];
   } else if ([value isKindOfClass: [NSDate class]]) {
		NSNumber *floatValue = [NSNumber numberWithFloat: [(NSDate *)value timeIntervalSinceReferenceDate]];
		[attributes setObject: floatValue forKey: attributeName];
	} else {
		[attributes setObject: value forKey: attributeName];		
	}
}
- (id)getAttributeNamed:(NSString *)attributeName 
{
	id result = [attributes objectForKey: attributeName];
   if (result == [NSNull null]) {
      return nil;
   } else {
      return result;
   }
}

- (NSString *) createdAtAttributeName
{
	return kCreatedAt;
}
- (NSString *) updatedAtAttributeName
{
	return kUpdatedAt;
}


- (NSInteger)primaryKey
{
	return [self getIntegerAttributeNamed: kPrimaryKeyName];
}

- (NSValue *)getValueAttributeNamed:(NSString *)attributeName
{
	return (NSValue *)[self getAttributeNamed: attributeName];
}

- (NSNumber *)getNumberAttributeNamed:(NSString *)attributeName
{
	return (NSNumber *)[self getAttributeNamed: attributeName];	
}

- (NSInteger)getIntegerAttributeNamed:(NSString *)attributeName
{
	return (NSInteger)[[self getNumberAttributeNamed: attributeName] integerValue];
}

- (double)getFloatAttributeNamed:(NSString *)attributeName
{
	return [[self getNumberAttributeNamed: attributeName] doubleValue];
}

- (NSDate *)getDateAttributeNamed:(NSString *)attributeName
{
	return [NSDate dateWithTimeIntervalSinceReferenceDate: [self getFloatAttributeNamed: attributeName]];
}

- (NSString *)findByPrimaryKeyStatement
{
	NSString *columnList = [[[[self class] table] columnNames] componentsJoinedByString: @", "];
	return [NSString stringWithFormat: @"select %@ from %@ where PrimaryKey = ?", columnList, [[self class] tableName]];
}

- (BOOL)getBooleanAttributeNamed:(NSString *)attributeName
{
   return (BOOL) [self getIntegerAttributeNamed: attributeName];
}


- (NSString *)concatenatedColumnNames
{
   return [[self class] concatenatedColumnNames];
}

// Callback stubs
- (void) beforeCreate
{
   // Default does nothing
}

- (NSArray *) activeRecordAttributeKeys{
	return [attributes allKeys];
}

- (NSString *) description{
	return [attributes description];
}

-(NSString *) name; {
	return [self getAttributeNamed:kName];
}

@end
