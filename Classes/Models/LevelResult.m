//
//  Result.m
//  Rhythms
//
//  Created by Julio Barros on 8/19/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "LevelResult.h"


@implementation LevelResult

-(NSString *) description {
	return [NSString stringWithFormat:@"accuracy=%2.0f%% score=%@",[[self getAttributeNamed:kAccuracy] doubleValue] * 100,[self getAttributeNamed:kScore]];
}
@end
