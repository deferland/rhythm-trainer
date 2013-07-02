//
//  StageTest.m
//  Rhythms
//
//  Created by Julio Barros on 8/11/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//


#import "Rhythm.h"
#import "Level.h"
#import "Stage.h"
#import "GTMSenTestCase.h"
#import "RhythmEngine.h"
#import "Note.h"
#import "Measure.h"

@interface StageTest : SenTestCase {
	
}

@end


@implementation StageTest

-(void) test0307 {
	Rhythm *rhythm = (Rhythm *) [Rhythm findByPrimaryKey:1];
	Level *level = (Level *) [Level findByPrimaryKey:4];
	level.rhythm = rhythm;
		
	RhythmEngine *engine = [[RhythmEngine alloc] init];
	engine.playMode = 0;
	[engine setSpeedAndBPM: MEDIUM];
	engine.difficulty = 0;
	engine.maxDiffAtStart = 40.0;
	engine.minPercentageForStop = .6000;
	
	engine.rhythm = rhythm;
	[engine setLevel:level];
	
	for (int i = 	24; i <=30;i++){
		Stage *stage = (Stage *) [Stage findByPrimaryKey:i]; 
		NSLog(@"Got stage: %@",stage);
		stage.level = level;
		STAssertTrue(stage != nil, @"Did not find stage");
		engine.stage = stage;
		double len = [stage totalTicks];
		NSLog(@"Stage %d is %f ticks long",i,len);
	}
	
}

/*
-(void) test0307 {
	Rhythm *rhythm = (Rhythm *) [Rhythm findByPrimaryKey:2];
	Level *level = (Level *) [Level findByPrimaryKey:15];
	level.rhythm = rhythm;
	Stage *stage = (Stage *) [Stage findByPrimaryKey:103]; 
	stage.level = level;
	STAssertTrue(stage != nil, @"Did not find stage");
	
	RhythmEngine *engine = [[RhythmEngine alloc] init];
	engine.playMode = 0;
	[engine setSpeedAndBPM: MEDIUM];
	engine.difficulty = 0;
	engine.maxDiffAtStart = 40.0;
	engine.minPercentageForStop = .6000;
	
	engine.rhythm = rhythm;
	[engine setLevel:level];
	engine.stage = stage;
	
	StageScorer *scorer = [[StageScorer alloc] initWithRhythmEngine:engine];
	
	NSMutableArray *playedNotes = [[NSMutableArray alloc] init];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 0.047429 andStopTime: 1.813506]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 2.057606 andStopTime: 2.285617]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 2.401160 andStopTime: 2.613789]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 2.764770 andStopTime: 2.980947]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 3.131848 andStopTime: 3.314074]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 3.448148 andStopTime: 3.647730]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 3.781888 andStopTime: 3.964338]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 4.117070 andStopTime: 4.631257]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 4.784475 andStopTime: 5.869106]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 6.132757 andStopTime: 7.128287]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 7.493143 andStopTime: 7.965927]];

	[scorer scoreExpectedNotes:stage withPlayedNotes:playedNotes];
	NSLog(@"%@",[scorer errors]);
}

/*
-(void) test0307A {
	Rhythm *rhythm = (Rhythm *) [Rhythm findByPrimaryKey:3];
	Level *level = (Level *) [Level findByPrimaryKey:20];
	level.rhythm = rhythm;
	Stage *stage = (Stage *) [Stage findByPrimaryKey:141]; 
	stage.level = level;
	STAssertTrue(stage != nil, @"Did not find stage");
	
	RhythmEngine *engine = [[RhythmEngine alloc] init];
	engine.playMode = 1;
	[engine setSpeedAndBPM: MEDIUM];
	engine.difficulty = 0;
	engine.maxDiffAtStart = 40.0;
	engine.minPercentageForStop = .6000;
	
	engine.rhythm = rhythm;
	[engine setLevel:level];
	engine.stage = stage;
	
	StageScorer *scorer = [[StageScorer alloc] initWithRhythmEngine:engine];
	
	NSMutableArray *playedNotes = [[NSMutableArray alloc] init];
	
	[playedNotes addObject:[[Note alloc] initWithStartTime: 0.043801 andStopTime: 0.198280]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 0.301360 andStopTime: 1.125305]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 1.540146 andStopTime: 2.339757]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 2.642889 andStopTime: 3.420070]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 3.724602 andStopTime: 3.914292]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 4.092239 andStopTime: 4.207298]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 4.301010 andStopTime: 4.417275]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 4.464905 andStopTime: 4.640450]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 5.041551 andStopTime: 5.260428]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 6.892300 andStopTime: 7.041584]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 7.158973 andStopTime: 7.748126]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 7.919773 andStopTime: 8.059292]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 8.259444 andStopTime: 8.392128]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 8.461012 andStopTime: 9.175545]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 9.560022 andStopTime: 9.692630]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 9.752001 andStopTime: 10.059450]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 10.127752 andStopTime: 10.309529]];
	
	[scorer scoreExpectedNotes:stage withPlayedNotes:playedNotes];
	NSLog(@"%@",[scorer errors]);
}


/*
-(void) test1222A {
	// No note 7 in the first measure. 
	
	Rhythm *rhythm = (Rhythm *) [Rhythm findByPrimaryKey:3];
	Level *level = (Level *) [Level findByPrimaryKey:27];
	level.rhythm = rhythm;
	Stage *stage = (Stage *) [Stage findByPrimaryKey:209]; 
	stage.level = level;
	STAssertTrue(stage != nil, @"Did not find stage");

	RhythmEngine *engine = [[RhythmEngine alloc] init];
	engine.playMode = 1;
	[engine setSpeedAndBPM: MEDIUM];
	engine.difficulty = 0;
	engine.maxDiffAtStart = 40.0;
	engine.minPercentageForStop = .652644;
	
	engine.rhythm = rhythm;
	[engine setLevel:level];
	engine.stage = stage;
	
	StageScorer *scorer = [[StageScorer alloc] initWithRhythmEngine:engine];
	
	NSMutableArray *playedNotes = [[NSMutableArray alloc] init];
        [playedNotes addObject:[[Note alloc] initWithStartTime:0.396170 andStopTime: 0.661669]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:0.778996 andStopTime: 1.012604]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:1.098700 andStopTime: 1.295236]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:1.662686 andStopTime: 1.862050]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:2.013234 andStopTime: 2.213380]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:2.379632 andStopTime: 2.584388]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:2.699285 andStopTime: 4.741018]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:5.494455 andStopTime: 5.714792]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:5.831076 andStopTime: 5.997062]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:6.161761 andStopTime: 6.365520]];
        [playedNotes addObject:[[Note alloc] initWithStartTime:8.200696 andStopTime: 8.644874]];
	
	[scorer scoreExpectedNotes:stage withPlayedNotes:playedNotes];
	Measure *measure = [[scorer measures] objectAtIndex:0];
	STAssertTrue(measure.numNotes == 1,@"There should only be 6 notes in measure one.");
}

-(void) test1226A {
  // There is no note four in the fourth measure. 
	
	// This was a problem with rounding.
	
	Rhythm *rhythm = (Rhythm *) [Rhythm findByPrimaryKey:3];
	Level *level = (Level *) [Level findByPrimaryKey:26];
	level.rhythm = rhythm;
	Stage *stage = (Stage *) [Stage findByPrimaryKey:228]; 
	stage.level = level;
	STAssertTrue(stage != nil, @"Did not find stage");

	RhythmEngine *engine = [[RhythmEngine alloc] init];
	engine.playMode = 1;
	[engine setSpeedAndBPM:2];
	engine.difficulty = 0;
	engine.maxDiffAtStart = 40.0;
	engine.minPercentageForStop = .652644;
	
	engine.rhythm = rhythm;
	[engine setLevel:level];
	engine.stage = stage;
	
	StageScorer *scorer = [[StageScorer alloc] initWithRhythmEngine:engine];
	
	NSMutableArray *playedNotes = [[NSMutableArray alloc] init];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 0.052502 andStopTime: 0.265860]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 0.467585 andStopTime: 0.899427]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 1.092783 andStopTime: 1.227156]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 1.372586 andStopTime: 1.516338]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 1.629060 andStopTime: 1.716394]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 1.800226 andStopTime: 1.924375]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 2.040980 andStopTime: 2.523284]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 2.698086 andStopTime: 3.247812]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 3.417592 andStopTime: 3.625397]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 3.768455 andStopTime: 3.984678]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 4.184707 andStopTime: 4.698247]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 4.887045 andStopTime: 5.052132]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 5.229998 andStopTime: 5.450996]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 6.235323 andStopTime: 6.384713]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 6.469247 andStopTime: 6.601730]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 6.695374 andStopTime: 6.858988]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 7.530552 andStopTime: 7.636096]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 7.764065 andStopTime: 7.868609]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 7.947586 andStopTime: 8.068916]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 8.186367 andStopTime: 8.749602]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 8.869921 andStopTime: 10.181798]];
	[playedNotes addObject:[[Note alloc] initWithStartTime: 10.328955 andStopTime: 10.726943]];
	
	[scorer scoreExpectedNotes:stage withPlayedNotes:playedNotes];
	Measure *m  = [scorer.measures objectAtIndex:0];
	STAssertTrue(m.numNotes == 7,@"Should be 7 notes in that measure");
	m  = [scorer.measures objectAtIndex:1];
	STAssertTrue(m.numNotes == 6,@"Should be 6 notes in that measure");
	m  = [scorer.measures objectAtIndex:2];
	STAssertTrue(m.numNotes == 6,@"Should be 6 notes in that measure");
	m  = [scorer.measures objectAtIndex:3];
	STAssertTrue(m.numNotes == 3,@"Should be 3 notes in that measure");

}
 
 */

-(void) testSpeedAndBpm {
	RhythmEngine *engine = [[RhythmEngine alloc] init];
	[engine setSpeedAndBPM:SLOW];
	STAssertTrue([engine bpm] == 60,@"BPM for slow not correct");
	STAssertTrue([engine ticksPerBeat] == 120,@"Ticks Per Beat for slow not correct");

	[engine setSpeedAndBPM:MEDIUM];
	STAssertTrue([engine bpm] == 90,@"BPM for medium not correct");
	STAssertTrue([engine ticksPerBeat] == 120,@"Ticks Per Beat for slow not correct");

	[engine setSpeedAndBPM:FAST];
	STAssertTrue([engine bpm] == 120,@"BPM for fast not correct");
	STAssertTrue([engine ticksPerBeat] == 120,@"Ticks Per Beat for slow not correct");

	Rhythm *sixeight = [[Rhythm findByCondition:@"name = '6/8'"] objectAtIndex:0];
	NSArray *levels = [Level findByCondition:@"directory_name = '6-8_level_1'"];
	Level *slow68 = [levels objectAtIndex:0];
	STAssertTrue(slow68 != nil,@"Did not find slow 6/8 level");
	
	[engine setRhythm:sixeight];
	[engine setLevel:slow68];	
	STAssertTrue([engine ticksPerBeat] == 60,@"Ticks Per Beat for 6/8 not correct");
	
	[engine setSpeedAndBPM:SLOW];
	STAssertTrue([engine bpm] == 96,@"BPM for slow slow 68 not correct");
	
	[engine setSpeedAndBPM:MEDIUM];
	STAssertTrue([engine bpm] == 104,@"BPM for medium slow 68 not correct");

	[engine setSpeedAndBPM:FAST];
	STAssertTrue([engine bpm] == 116,@"BPM for fast slow 68 not correct");

	levels = [Level findByCondition:@"directory_name = '6-8_level_4'"];
	Level *fast68 = [levels objectAtIndex:0];
	STAssertTrue(fast68 != nil,@"Did not find fast 6/8 level");

	[engine setLevel:fast68];	
	STAssertTrue([engine ticksPerBeat] == 180,@"Ticks Per Beat for fast 6/8 not correct");
	
	[engine setSpeedAndBPM:SLOW];
	STAssertTrue([engine bpm] == 56,@"BPM for slow fast68 68 not correct");
	
	[engine setSpeedAndBPM:MEDIUM];
	STAssertTrue([engine bpm] == 60,@"BPM for medium fast68 68 not correct");
	
	[engine setSpeedAndBPM:FAST];
	STAssertTrue([engine bpm] == 68,@"BPM for fast fast68 68 not correct");
	
	// find a 6/8 ryhtm fast and slow and check ticks per beat
	// check bpm
	//6-8_level_4
}

-(void) testImageName{
	NSArray *rhythms = [Rhythm findAll];
	STAssertTrue([rhythms count]> 0, @"Can't have no rhythms");
	
	/*
	 Rhythm *rhythm = [rhythms objectAtIndex:0];
	 NSArray *levels = [Level findByCondition: @"rhythm_id = ?",[NSNumber numberWithInt:[rhythm primaryKey]]];
	 STAssertTrue(levels != nil,@"Levels can not be nil");
	 STAssertTrue([levels count] > 0, @"levels has to have a level");
	 Level *level = [levels objectAtIndex:0];
	 level.rhythm = rhythm;
	 [level loadAllStages];
	 Stage *stage = [level randomStage];
	 NSString *imagePath = [stage getImagePath];
	 STAssertTrue(imagePath!=nil,@"Can not have a nil image path");
	 NSLog(@"ImagePath is : %@",imagePath);
	 NSArray *ts = [stage loadTimingSequence];
	 NSLog(@"Timing sequence: %@",ts);
	 STAssertTrue([ts count] %2 == 0,@"Can not have an odd number of tokens");
	 
	 */
}


@end
