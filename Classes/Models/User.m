//
//  User.m
//  Rhythms
//
//  Created by Julio Barros on 8/8/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "User.h"
#import "ModelConstants.h"

@implementation User

-(NSString *) description{
	return [self getAttributeNamed:kUserName];
}

@end
