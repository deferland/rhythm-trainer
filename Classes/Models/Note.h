//
//  PlayedNote.h
//  Rhythms
//
//  Created by Julio Barros on 7/17/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Note : NSObject {
	double startTime;
	double stopTime;
	
	int ticks;
	
	int measure;
	int position;
}

@property double startTime;
@property double stopTime;
@property int measure;
@property int position;
@property int ticks;

-(id) initWithStartTime:(double) s andStopTime: (double) d;

-(BOOL) completelyBefore:(Note *) n;
-(BOOL) startedBefore:(double) t;
-(BOOL) startedAfter:(double) t;
-(BOOL) endedBefore:(double) t;
-(BOOL) endedAfter:(double) t;

@end
