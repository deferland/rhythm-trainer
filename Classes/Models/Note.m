//
//  PlayedNote.m
//  Rhythms
//
//  Created by Julio Barros on 7/17/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "Note.h"


@implementation Note

@synthesize startTime;
@synthesize stopTime;
@synthesize measure;
@synthesize position;
@synthesize ticks;

-(id) initWithStartTime:(double) s andStopTime: (double) d{
	if (self = [super init]){
		self.startTime = s;
		self.stopTime = d;
	}
	return self;
}


-(NSString *) description {
	return [NSString stringWithFormat: @"start: %f end: %f duration: %f measure: %d position: %d ticks: %d", self.startTime,self.stopTime,self.stopTime-self.startTime,self.measure,self.position, self.ticks];
}

-(BOOL) completelyBefore:(Note *) n{
	return [self endedBefore:n.startTime];
}

-(BOOL) startedBefore:(double) t{
	return startTime < t;
}

-(BOOL) startedAfter:(double) t{
	return startTime > t;
}

-(BOOL) endedBefore:(double) t{
	return stopTime < t;
}

-(BOOL) endedAfter:(double) t{
	return stopTime > t;
}

@end
