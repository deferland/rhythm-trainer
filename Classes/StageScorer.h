//
//  StageScorer.h
//  Rhythms
//
//  Created by Julio Barros on 9/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ERROR_TITLE @"TITLE"
#define ERROR_LIST @"LIST"


@class RhythmEngine;
@class Stage;

@interface StageScorer : NSObject {
	RhythmEngine *rhythmEngine;
	NSMutableArray *allPlayedNotes;	
	double scoreForThisStage;
	int pointsForThisStage;
	
	NSMutableArray *measures;
	NSMutableArray *expectedNotes;
	NSArray *originalExpectedNotes;
	NSMutableArray *errors;
}

@property (nonatomic,retain) NSMutableArray *allPlayedNotes;
@property (nonatomic,retain) NSMutableArray *measures;
@property (nonatomic,retain) NSMutableArray *expectedNotes;
@property (nonatomic,retain) NSArray *originalExpectedNotes;
@property (nonatomic,retain) NSMutableArray *errors;
@property double scoreForThisStage;
@property int pointsForThisStage;

-(id) initWithRhythmEngine:(RhythmEngine *) engine;
-(void) scoreExpectedNotes:(Stage *) stage withPlayedNotes:(NSMutableArray*) playedNotes;
-(void) convertStageToExpected:(NSArray *) stageNotes;

@end
