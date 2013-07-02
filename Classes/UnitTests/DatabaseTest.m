//
//  DabaseTest.m
//  Rhythms
//
//  Created by Julio Barros on 8/8/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "DatabaseTest.h"


@implementation DatabaseTest

- (void) setUp{
}

-(void) testGetAllUsers{
	NSLog(@"Testing get all users");
	NSArray *users = [User findAll];
	STAssertNotNil(users,@"Did not get array of users");
	STAssertTrue([users count] > 0 ,@"Did not get the any users: %d",[users count]);
}

-(void) testCreateDeleteUser{
	User *user = [[User alloc] init];
	[user setAttributeNamed:kUserName value: @"Tester"];
	[user save];
	STAssertTrue([user primaryKey] > 0,@"Got invalid uiser id  back");
	int numUsers = [[User findAll] count];
	[user delete];
	STAssertTrue(numUsers - 1 == [[User findAll] count],@"Deleted a user but the count is off");
}


@end
