//
//  Measure.h
//  Rhythms
//
//  Created by Julio Barros on 9/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Measure : NSObject {
	int measureNum;
	double startTime;
	double endTime;
	int numNotes;
	int numRight;
	int extraNotes;
	int missedNotes;
	
	NSMutableArray *errors;
}

@property int measureNum;
@property double startTime;
@property double endTime;
@property int numNotes;
@property int numRight;
@property int extraNotes;
@property int missedNotes;

@property (nonatomic,retain) NSMutableArray *errors;

@end
