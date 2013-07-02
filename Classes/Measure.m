//
//  Measure.m
//  Rhythms
//
//  Created by Julio Barros on 9/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "Measure.h"


@implementation Measure

@synthesize measureNum;
@synthesize startTime;
@synthesize endTime;
@synthesize numNotes;
@synthesize numRight;
@synthesize extraNotes;
@synthesize missedNotes;

@synthesize errors;


- (id) init
{
	self = [super init];
	if (self != nil) {
		errors = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc {
  self.errors = nil;
  [super dealloc];
}


@end
