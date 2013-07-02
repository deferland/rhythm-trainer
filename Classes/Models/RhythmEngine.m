//
//  RhythmEngine.m
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "RhythmEngine.h"
#import "Rhythm.h"
#import "Level.h"
#import "Stage.h"
#import "GamePlayController.h"
#import "Note.h"
#import "RhythmsAppDelegate.h"
#import "LevelResult.h";

#import "Measure.h"
#import "SimpleAudioEngine.h"

#define NUM_STAGES_REQUIRED_FOR_SCORE 5
#define SIX_EIGHT_FAST_RANK 6

@implementation RhythmEngine

@synthesize playMode;
@synthesize difficulty;
@synthesize stage;
@synthesize beatNumber;
@synthesize standardCountDown;
@synthesize gamePlayController;
@synthesize playing;
@synthesize metronomePlaying;
@synthesize metronomeTimer;
@synthesize visualMetronomeLEDTimer;
@synthesize minPercentageForStop;
@synthesize maxDiffAtStart;
@synthesize minTickLengthToConsiderStopTime;
@synthesize upperSignature;
@synthesize lowerSignature;
@synthesize pointsForThisLevel;
@synthesize stageScorer;
@synthesize metronomeSound, buttonSound;

-(id) init {
	if (self = [super init]){
				
	
		fourFourBpm = malloc(sizeof(int) * (FAST + 1));
		fourFourBpm[SLOW] = 60;
		fourFourBpm[MEDIUM] = 90;
		fourFourBpm[FAST] = 120;
		
		sixEightSlow = malloc(sizeof(int) * (FAST + 1));
		sixEightSlow[SLOW] = 96;
		sixEightSlow[MEDIUM] = 104;
		sixEightSlow[FAST] = 116;
		
		sixEightFast = malloc(sizeof(int) * (FAST + 1));
		sixEightFast[SLOW] = 168;
		sixEightFast[MEDIUM] = 180;
		sixEightFast[FAST] = 204;
					   
		ticksPerBeat = 120;
		playMode = TEST;
		playing = NO;
		stageStartTime = 0;
		[self setDifficulty:BEGINNER];
		minTickLengthToConsiderStopTime = 120;
		standardCountDown = YES;
		scoresForThisLevel = [[NSMutableArray alloc] initWithCapacity:NUM_STAGES_REQUIRED_FOR_SCORE];
		
		[self setSpeedAndBPM:MEDIUM];
		metronomePlaying = NO;
		
		playedNotes = [[NSMutableArray alloc] init];
      
      self.metronomeSound = @"nearSound.caf";
      self.buttonSound = @"PianoC.wav";
      
      [[SimpleAudioEngine sharedEngine] preloadEffect: self.metronomeSound];
      [[SimpleAudioEngine sharedEngine] preloadEffect: self.buttonSound];
		
      /*
		NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PianoC" ofType:@"wav"]];
		tapAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
		tapAudioPlayer.numberOfLoops = 0; //INT_MAX;
		[tapAudioPlayer prepareToPlay];
		tapAudioPlayer.volume = 0.4;

      NSURL *metronomeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nearSound" ofType:@"caf"]];
		metronomeAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:metronomeURL error:nil];
		metronomeAudioPlayer.numberOfLoops = 0; //INT_MAX;
		[metronomeAudioPlayer prepareToPlay];
		metronomeAudioPlayer.volume = 0.4;
      */
      
      /*
      NSString *path = [[NSBundle mainBundle] pathForResource:@"nearSound" ofType:@"caf"];
		NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
		AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &soundID);
      */
	}
	
	return self;
}

-(void) setDifficulty:(Difficulty) newDifficulty {
	difficulty = newDifficulty;
	if (difficulty == BEGINNER){
		maxDiffAtStart = 40.0;
		minPercentageForStop = 0.60;
	} else {
		maxDiffAtStart = 30.0;
		minPercentageForStop = 0.65;
	}
}

-(void) setUser:(User *) nextUser{
	[nextUser retain];
	[_user release];
	_user = nextUser;
	
	self.rhythm = nil;
	self.level = nil;
}


-(User *) user{
	return _user;
}

-(void) setRhythm:(Rhythm *) nextRhythm{
	[nextRhythm retain];
	[_rhythm release];
	_rhythm = nextRhythm;
		
	self.level = nil;
	self.stage = nil;
	
	NSArray *signatureParts = [[_rhythm getAttributeNamed:kName] componentsSeparatedByString:@"/"];
	upperSignature = [[signatureParts objectAtIndex:0] intValue];
	lowerSignature = [[signatureParts objectAtIndex:1] intValue];
	
	if (lowerSignature == 4){
		ticksPerBeat = 120;
	} else if (lowerSignature == 8){
		ticksPerBeat = 60;
	}
}

-(Rhythm *) rhythm {
	return _rhythm;
}

-(void) setLevel:(Level *) nextLevel {
	[nextLevel retain];
	[_level release];
	_level = nextLevel;

	pointsForThisLevel = 0;
	[scoresForThisLevel removeAllObjects];
	[self updateBPM];
}

-(Level *) level  {
	return _level;
}

-(Boolean) isAdvanced68{
	return (_level != nil && lowerSignature == 8 &&  [_level rank] >= SIX_EIGHT_FAST_RANK);
}

-(Boolean) isBasic68{
	return (_level != nil && lowerSignature == 8 &&  [_level rank] < SIX_EIGHT_FAST_RANK);
}


-(void) prepareStage:(Stage *) candidateStage {
	self.stage = candidateStage;	
	beatPhase = 0;
	beatNumber = 0;
	stageStartTime = 0;
	[playedNotes removeAllObjects];
	[gamePlayController turnOffVisualMetronome];
}

-(int) curStageIndex{
    return [_level stageIndex];
}

-(BOOL) newStageAvailable{
    return [_level nextStageAvailable];
}

-(void) firstStage{
    Stage *candidateStage = [_level firstStage];     
    [self prepareStage:candidateStage];
}

-(void) newStage{
	Stage *candidateStage = [_level nextStage];

	[self prepareStage:candidateStage];
}

-(void) sameStage{
	[self prepareStage:stage];
}

// Can be negative -- because we need the last click and we need to accept late last notes.
-(double) timeLeftInStage{
	double timeLeft = (stageStartTime + stageDuration) - CFAbsoluteTimeGetCurrent();
	return timeLeft;
}


-(void) compareStageToPlayed{
	self.stageScorer = [[[StageScorer alloc] initWithRhythmEngine:self] autorelease];
	[stageScorer scoreExpectedNotes:stage withPlayedNotes:playedNotes];
	pointsForThisLevel += stageScorer.pointsForThisStage;
	[scoresForThisLevel addObject:[NSNumber numberWithDouble: stageScorer.scoreForThisStage]];
}

-(int) stagesCompletedForThisLevel{
	return [scoresForThisLevel count];
}

-(BOOL) enoughStagesPlayedForThisLevel {
	return [self stagesCompletedForThisLevel] >= NUM_STAGES_REQUIRED_FOR_SCORE;
}

-(double) scoreForThisLevel{
	double avgAccuracy = 0.0;
	for (NSNumber *number in scoresForThisLevel){
		avgAccuracy += [number doubleValue];
	}
	avgAccuracy /= [scoresForThisLevel count];
	return avgAccuracy;
}


-(void) saveLevelScore {
	// delete old score
/*	[LevelResult deleteAllWithCondition:@"rhythm_id = ? and level_id = ? and user_id = ? and speed = ?",
	 [NSNumber numberWithInt:[_rhythm primaryKey]],[NSNumber numberWithInt:[_level primaryKey]],[NSNumber numberWithInt:[_user primaryKey]],
	 [NSNumber numberWithInt:speed]];
*/
	
	// delete old score regardless of speed

	[LevelResult deleteAllWithCondition:@"rhythm_id = ? and level_id = ? and user_id = ?",
	 [NSNumber numberWithInt:[_rhythm primaryKey]],[NSNumber numberWithInt:[_level primaryKey]],[NSNumber numberWithInt:[_user primaryKey]]];
	
	LevelResult *levelResult = [[LevelResult alloc] init];
	[levelResult setAttributeNamed:kScore value:[NSNumber numberWithInt:pointsForThisLevel]];
	[levelResult setAttributeNamed:kAccuracy value:[NSNumber numberWithDouble:[self scoreForThisLevel]]];
	[levelResult setAttributeNamed:kUserId value:[NSNumber numberWithInt:[_user primaryKey]]];
	[levelResult setAttributeNamed:kSpeed value:[NSNumber numberWithInt:speed]];
	[levelResult setAttributeNamed:kLevelId value:[NSNumber numberWithInt:[_level primaryKey]]];
	[levelResult setAttributeNamed:kRhythmId value:[NSNumber numberWithInt:[_rhythm primaryKey]]];
	
	[levelResult save];
	[levelResult release];
}

-(void) setSpeedAndBPM:(int) s{
	speed = s;
	[self updateBPM];
}

-(Speed) speed{
	return speed;
}

-(void) updateBPM{
	int *bpmSet = fourFourBpm;
	
	if (lowerSignature == 8){
		if ([_level rank] < SIX_EIGHT_FAST_RANK)
			bpmSet = sixEightSlow;
		else
			bpmSet = sixEightFast;
	}
	
	bpm = bpmSet[speed];
}

-(int) bpm{
	return bpm;
}


-(void) startGame{
	playing = YES;
	
	// Count all notes played before even before game starts.
	// [playedNotes removeAllObjects];
	
	stageDuration = [self ticksToSeconds: [stage totalTicks]];
	stageStartTime = CFAbsoluteTimeGetCurrent();
	// NSLog(@"totalTicks=%f startTime=%f duration=%f",[stage totalTicks],stageStartTime,stageDuration);
	
	for (Note *note in playedNotes){
		note.startTime = note.startTime - stageStartTime;
		note.stopTime = note.stopTime - stageStartTime;
	}
}

-(BOOL) downBeat {
	return (beatPhase % 2 == 0);
}

-(BOOL) playMetronome{
	if (![self downBeat])
		return NO;
	
	if (beatNumber < 0 && standardCountDown && lowerSignature == 4)
		return (beatNumber == -8 || beatNumber == -6 || beatNumber >= - 4);
	
	if (lowerSignature == 4)
		return YES;
	
	// x/8 in slow speed and after first countdown measure
	if (beatNumber > -6 && [self isBasic68])
		return YES;
	
	int tempBeatNumber = beatNumber;
	if (tempBeatNumber < 0)
		tempBeatNumber = abs(tempBeatNumber) + 1;
	
	// slow speed first countdown measure
	if ([self isBasic68] &&  (tempBeatNumber % 3 == 1))
		return YES;
		
	// x/8 at faster speeds
	if ([self isAdvanced68] && (tempBeatNumber % 3 == 1))
		return YES;
	
	return NO;
}

-(void) endStage  {
	playing = NO;
   [[SimpleAudioEngine sharedEngine] stopEffect: buttonSoundID];
	//[tapAudioPlayer pause];
	[self stopMetronome];
	[self compareStageToPlayed];
	[gamePlayController showResults];
}

-(void) lightLED {
	if ([self timeLeftInStage] > 0){
		ledSegment = (ledSegment +1 ) % 5;
		[gamePlayController lightMetronome:ledSegment];
	}
}

-(void) halfBeat {
	beatPhase++;	
	
	// NSLog(@"In halfBeat: beatPhase=%d downBeat=%d playing=%d  beat=%d timeLeft=%f extraTimeAtEnd=%f",beatPhase,[self downBeat],playing, beatNumber % upperSignature, [self timeLeftInStage], [self ticksToSeconds:[[[stage notes] lastObject] ticks]]);
	
	if ([self downBeat]){
		beatNumber++;
		if (beatNumber == 0){
			beatNumber = 1;
			[self startGame];
		}
	}
	
	if (playing == NO && [self playMetronome]) {
		//AudioServicesPlaySystemSound(soundID);
      //[metronomeAudioPlayer play];
      metronomeSoundID = [[SimpleAudioEngine sharedEngine] playEffect: self.metronomeSound];
   }
	
	if (playing == YES){
		double timeLeft = [self timeLeftInStage];
		double extraTimeAtEnd = [self ticksToSeconds:[[[stage notes] lastObject] ticks]]; 
		if (timeLeft + extraTimeAtEnd < 0){
			[self endStage];
		}
		if (timeLeft > 0.009){
		  [gamePlayController updateDisplay];
		  if ([self playMetronome]){
           //AudioServicesPlaySystemSound(soundID);
           //[metronomeAudioPlayer play];
           metronomeSoundID = [[SimpleAudioEngine sharedEngine] playEffect: self.metronomeSound];
		  }
		} else {
			[gamePlayController turnOffVisualMetronome];
		}
	} else {
		[gamePlayController updateDisplay];
	}
	
	// The first interval is longer to let the system catch up.
	if (metronomeTimer.timeInterval > halfBeatInterval){
		[self.metronomeTimer invalidate];
		self.metronomeTimer = nil;
		self.metronomeTimer = [NSTimer scheduledTimerWithTimeInterval: halfBeatInterval target: self selector: @selector(halfBeat) userInfo: nil repeats: YES];
	}
	
	if (playing && visualMetronomeLEDTimer == nil){
		ledSegment = 0;
		[self lightLED];
		self.visualMetronomeLEDTimer = [NSTimer scheduledTimerWithTimeInterval: metronomeLEDInterval target: self selector: @selector(lightLED) userInfo: nil repeats: YES];
	}
}

-(void) startMetronome {
	if (metronomePlaying == YES)
		return;
	
	beatPhase = 1;
	
	// Standard is 1 r 2 r 4 3 2 1
	// non standard s 1 2 3 1 2 3
	if (standardCountDown)
		beatNumber = -9;
	else 
		beatNumber = -1 * ((2 * upperSignature) + 1);
	
	if (lowerSignature == 8)
		beatNumber = -13;
	
	metronomePlaying = YES;
	halfBeatInterval = 60.0 / bpm / 2.0;
	
	metronomeLEDInterval = halfBeatInterval * 2.0 / 5.0;
	if (lowerSignature == 8 && [_level rank] >= SIX_EIGHT_FAST_RANK)
		metronomeLEDInterval *= 3;
	
	self.metronomeTimer = [NSTimer scheduledTimerWithTimeInterval: halfBeatInterval * 2 target: self selector: @selector(halfBeat) userInfo: nil repeats: YES];
}

-(void) stopMetronome {
	if (metronomeTimer)
		[metronomeTimer invalidate];
	self.metronomeTimer = nil;
	
	if (visualMetronomeLEDTimer)
		[visualMetronomeLEDTimer invalidate];
	self.visualMetronomeLEDTimer = nil;
	
	metronomePlaying = NO;
}

-(int) ticksPerBeat{
	return ticksPerBeat;
}

-(double) ticksToSeconds:(int) ticks{
	return ((double) ticks) / ticksPerBeat / bpm * 60;
}

-(int) secondsToTicks:(double) seconds{
	return seconds * ticksPerBeat * bpm / 60;
}

-(void) padDown {
	if (!metronomePlaying) return;
	//[tapAudioPlayer play];
   buttonSoundID = [[SimpleAudioEngine sharedEngine] playEffect: self.buttonSound];
	curNoteStartTime =  CFAbsoluteTimeGetCurrent();
}


-(void) padUp{
	//[tapAudioPlayer pause];
   [[SimpleAudioEngine sharedEngine] stopEffect: buttonSoundID];
   //tapAudioPlayer.currentTime = 0;

	if (metronomePlaying == NO){
		[self startMetronome];
		return;
	}
	double curNoteStopTime = CFAbsoluteTimeGetCurrent();
	Note *note = [[Note alloc] initWithStartTime: curNoteStartTime - stageStartTime andStopTime:curNoteStopTime - stageStartTime];
	[playedNotes addObject: note];
	[note release];
}

-(void) dealloc {
  self.stageScorer = nil;
   self.stage = nil;
   self.gamePlayController = nil;
   self.metronomeTimer = nil;
   self.visualMetronomeLEDTimer = nil;
	[playedNotes release];
	[scoresForThisLevel release];
	//[tapAudioPlayer release];
   self.metronomeSound = nil;
   self.buttonSound = nil;
	[super dealloc];
}



@end
