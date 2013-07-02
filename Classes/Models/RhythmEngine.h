//
//  RhythmEngine.h
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "SimpleAudioEngine.h"

#import "StageScorer.h"

typedef enum  {
	TEST = 0,
	PRACTICE = 1
} PlayMode;

typedef enum {
	SLOW = 1,
	MEDIUM = 2,
	FAST = 3
} Speed;

typedef enum {
	BEGINNER = 0,
	EXPERT = 1
} Difficulty;


@class User, Rhythm, Level, Stage;
@class GamePlayController;
@class LevelResult;

@interface RhythmEngine : NSObject {	
	PlayMode playMode;
	Difficulty difficulty;
	int beatPhase;
	int beatNumber;
	Boolean playing;
	Boolean metronomePlaying;
	Boolean standardCountDown;
	
	double maxDiffAtStart;
	double minPercentageForStop;
	int minTickLengthToConsiderStopTime;
	
	NSTimeInterval halfBeatInterval;
	NSTimeInterval metronomeLEDInterval;
	
	int ledSegment;
	
	int bpm;
	int *fourFourBpm;
	int *sixEightSlow;
	int *sixEightFast;
	
	int speed;
	int ticksPerBeat;
	
	User *_user;

	Rhythm *_rhythm;
	int upperSignature;
	int lowerSignature;

	Level *_level;
	
	Stage *stage;
	GamePlayController *gamePlayController;
	
	NSMutableArray *scoresForThisLevel;
	int pointsForThisLevel;
	
	//SystemSoundID soundID;
	
	NSTimer *metronomeTimer;
	NSTimer *visualMetronomeLEDTimer;
	
	double stageStartTime;
	double curNoteStartTime;
	double stageDuration;
		
	NSMutableArray *playedNotes;
	
	//AVAudioPlayer *tapAudioPlayer;
	//AVAudioPlayer *metronomeAudioPlayer;
   
   NSString *metronomeSound;
   NSString *buttonSound;
   ALuint metronomeSoundID;
   ALuint buttonSoundID;
   
	StageScorer *stageScorer;
}

@property (nonatomic, retain) NSString *metronomeSound;
@property (nonatomic, retain) NSString *buttonSound;


@property PlayMode playMode;
@property Difficulty difficulty; 
@property int beatNumber;

@property Boolean playing;
@property Boolean metronomePlaying;
@property Boolean standardCountDown;

@property double minPercentageForStop;
@property double maxDiffAtStart;
@property int minTickLengthToConsiderStopTime;
@property int upperSignature;
@property int lowerSignature;

@property int pointsForThisLevel;

@property (nonatomic, retain) Stage *stage;

@property (nonatomic, assign) GamePlayController *gamePlayController; // avoid circular retention
@property (nonatomic, retain) NSTimer *metronomeTimer;
@property (nonatomic, retain) NSTimer *visualMetronomeLEDTimer;

@property (nonatomic, retain) StageScorer *stageScorer;

-(void) setUser:(User *) user;
-(User *) user;

-(void) setRhythm:(Rhythm *) nextRhythm;
-(Rhythm *) rhythm;

-(void) setLevel:(Level *) nextLevel;
-(Level *) level;

-(Boolean) isAdvanced68;
-(Boolean) isBasic68;

-(BOOL) newStageAvailable;
-(void) newStage;
-(void) sameStage;
-(void) firstStage;
-(int) curStageIndex;

-(void) startMetronome;
-(void) stopMetronome;
-(void) saveLevelScore;

-(void) halfBeat;

-(void) padDown;
-(void) padUp;

-(double) timeLeftInStage;
-(double) ticksToSeconds:(int) ticks;
-(int) ticksPerBeat;

-(void) setSpeedAndBPM:(int) speed;
-(Speed) speed;
-(void) updateBPM;
-(int) bpm;

-(int) stagesCompletedForThisLevel;
-(BOOL) enoughStagesPlayedForThisLevel;
-(double) scoreForThisLevel;

-(BOOL) downBeat;

@end
