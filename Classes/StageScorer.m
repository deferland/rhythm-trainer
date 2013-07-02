//
//  StageScorer.m
//  Rhythms
//
//  Created by Julio Barros on 9/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "StageScorer.h"
#import "RhythmEngine.h"
#import "RhythmsAppDelegate.h"
#import "Note.h";
#import "Measure.h"
#import "Level.h"
#import "ModelConstants.h"
#import "Stage.h"

@implementation StageScorer

@synthesize allPlayedNotes;
@synthesize errors;
@synthesize scoreForThisStage;
@synthesize pointsForThisStage;
@synthesize measures;
@synthesize expectedNotes;
@synthesize originalExpectedNotes;

-(id) initWithRhythmEngine:(RhythmEngine *) engine {
	self = [super init];
	if (self != nil) {
		rhythmEngine =  engine;
		scoreForThisStage = 0;
		pointsForThisStage = 0;
	}
	return self;
}

- (void) convertStageToExpected:(NSArray *) stageNotes{
	self.expectedNotes =  [[NSMutableArray alloc] init];
	for (Note *note in stageNotes){
		Note *expectedNote = [[Note alloc] init];
		expectedNote.startTime = [rhythmEngine ticksToSeconds: note.startTime];
		expectedNote.stopTime = [rhythmEngine  ticksToSeconds:note.stopTime];
		expectedNote.ticks = note.ticks;
		[expectedNotes addObject: expectedNote];
		[expectedNote release];
	}
	
	self.originalExpectedNotes = [[NSArray alloc] initWithArray:expectedNotes];
}

-(Note *) nextNote:(NSMutableArray *)list {
	if ([list count] == 0)
		return nil;
	Note *note  = [[list objectAtIndex:0] retain];
	[note autorelease];
	[list removeObjectAtIndex:0];
	return note;
}


-(void) scoreExpectedNotes:(Stage *) stage withPlayedNotes:(NSMutableArray*) playedNotes{
	
	int numRight = 0;
	int ticksRight = 0;
	int totalNoteTicks = 0;
	double secondsPerMeasure = [rhythmEngine  ticksToSeconds:([rhythmEngine ticksPerBeat] * [rhythmEngine upperSignature])];
	
	// Make a copy for error reporting
	self.allPlayedNotes = [NSArray arrayWithArray:playedNotes];
	NSMutableArray *stageNotes = [stage notes];
	
	// Get the list of notes -- in Ticks.
	double maxStartDiff = [rhythmEngine  ticksToSeconds: [rhythmEngine maxDiffAtStart]];
	
	// Convert the stage notes in ticks to expected notes in seconds
	[self convertStageToExpected: stageNotes];
	for (Note *note in stageNotes)
		totalNoteTicks += note.ticks;
	
	
	// Create a measure for each measure we expect plus 1 each for before and after stage starts
	self.measures = [[NSMutableArray alloc] init];
	double totalTime = [rhythmEngine ticksToSeconds:[stage totalTicks]];
	int numMeasuresInStage = (totalTime / secondsPerMeasure) + .1;
	for (int i = 0; i < numMeasuresInStage+2; i++){
		Measure *measure = [[Measure alloc] init];
		measure.measureNum = i;
		[measures addObject:measure];
		[measure release];
	}
	
	// Assign each expected note to a measure and count expected notes per measure.
	for (Note *expectedNote in expectedNotes){
		int measureIndex = (expectedNote.startTime / secondsPerMeasure) + .05;
		expectedNote.measure = measureIndex + 1;
		Measure *measure = [measures objectAtIndex:measureIndex];
		measure.numNotes += 1;
		expectedNote.position = measure.numNotes;
	}
	
	// Assign each played note to a measure
	for (Note *playedNote in playedNotes){
		int measureIndex = 0;
		if (playedNote.stopTime < 0)
			measureIndex = 0;
		else {
			measureIndex = (playedNote.startTime / secondsPerMeasure) + .05;
			measureIndex += 1;
		}
		if (measureIndex > numMeasuresInStage) 
			measureIndex = numMeasuresInStage+1;
		playedNote.measure = measureIndex;
	}
	
	// NSLog(@"Expected Notes:\n%@",expectedNotes);
	// NSLog(@"Played Notes:\n%@",playedNotes);
		
	while ([expectedNotes count] > 0 || [playedNotes count] > 0){
		Note *playedNote = [self nextNote:playedNotes];
		Note *expectedNote = [self nextNote:expectedNotes];
		
		if (playedNote == nil){
			Measure *measure = [measures objectAtIndex:expectedNote.measure];
			measure.missedNotes += 1;
			continue;
		}
		
		if (expectedNote == nil){
			Measure *measure = [measures objectAtIndex:playedNote.measure];
			measure.extraNotes += 1;
			continue;
		}
		
		if ([playedNote completelyBefore: expectedNote]){
			[expectedNotes insertObject:expectedNote atIndex:0];
			Measure *measure = [measures objectAtIndex:playedNote.measure];
			measure.extraNotes += 1;
			continue;
		}
		
		// look for missed notes
		if ([expectedNote completelyBefore: playedNote]){
			[playedNotes insertObject:playedNote atIndex:0];
			Measure *measure = [measures objectAtIndex:expectedNote.measure];
			measure.missedNotes += 1;
			continue;
		}
		
		// Calculate acceptable error as percentage of duration.
		double maxStopDiff = [rhythmEngine ticksToSeconds: expectedNote.ticks] * (1.0 - [rhythmEngine minPercentageForStop]);
		
		// Quarter notes get a special stop diff 50%
		if (expectedNote.ticks == 120)
			maxStopDiff = [rhythmEngine ticksToSeconds: expectedNote.ticks] * .5;
		
		Measure *measure = [measures objectAtIndex:expectedNote.measure];
		if ([playedNote startedBefore: expectedNote.startTime - maxStartDiff]){
			[measure.errors addObject:[NSString stringWithFormat:@"Note %d started early",expectedNote.position]]; ;
		} else if ([playedNote startedAfter: expectedNote.startTime + maxStartDiff]){
			[measure.errors addObject:[NSString stringWithFormat:@"Note %d started late",expectedNote.position]]; ;
		} else if (expectedNote.ticks > [rhythmEngine minTickLengthToConsiderStopTime] &&  [playedNote endedBefore: expectedNote.stopTime - maxStopDiff]){
			[measure.errors addObject:[NSString stringWithFormat:@"Note %d ended early",expectedNote.position]]; ;
		} else if ([playedNote endedAfter: expectedNote.stopTime + maxStopDiff]){
			[measure.errors addObject:[NSString stringWithFormat:@"Note %d ended late",expectedNote.position]]; ;
		} else {
			numRight++;
			ticksRight += expectedNote.ticks;
		}
	}
	
	
	self.errors = [NSMutableArray array];
	
	int totalExtraNotes = 0;
	
	for (Measure *measure in measures){		
		if (measure.missedNotes == 0 && measure.extraNotes == 0 && [measure.errors count] == 0)
			continue;

		totalExtraNotes += measure.extraNotes;
		
		NSMutableDictionary *errorMap = [NSMutableDictionary dictionary];
		NSMutableArray *errorList = [NSMutableArray array];
		[errorMap setValue:errorList forKey:ERROR_LIST];
		[errors addObject:errorMap];
		
		NSString *noteWord = @"note";
		
		if (measure.measureNum == 0){
			[errorMap setValue:@"Before Stage Started"  forKey:ERROR_TITLE];
		} else {
			if (measure.measureNum <= numMeasuresInStage){
				[errorMap setValue:	[NSString stringWithFormat:@"Measure %d",measure.measureNum] forKey:ERROR_TITLE];
			} else {
				[errorMap setValue:@"After Stage Ended"  forKey:ERROR_TITLE];
			}
		}
		
		if (measure.missedNotes > 0){
			if (measure.missedNotes == 1)
				noteWord = @"note";
			else
				noteWord = @"notes";
			[errorList addObject:[NSString stringWithFormat:@"%d missed %@",measure.missedNotes,noteWord]];
		}
		
		if (measure.extraNotes > 0){
			if (measure.extraNotes == 1)
				noteWord = @"note";
			else
				noteWord = @"notes";
			[errorList addObject:[NSString stringWithFormat:@"%d extra %@",measure.extraNotes,noteWord]] ;
		}	
		if ([measure.errors count] > 0){
			for (id error in measure.errors){
				[errorList addObject:[NSString stringWithFormat:@"%@",error]];
			}
		}
	}
			
	// Calculate the percentage right based on number of notes and note length. Average the two for the final score
	double numRightScore =  1.0*numRight / [stageNotes count];
	double ticksRightScore = 1.0 * ticksRight / totalNoteTicks;
	scoreForThisStage = (numRightScore + ticksRightScore) / 2.0;
	
	// For now use the level name as the level level/index/rank/position.
	// accuracy * (10 + levelRank)
	int levelRank = [rhythmEngine.level rank];
	double difficultyMultiplier = 1.0; // BEGINNER
	if (rhythmEngine.difficulty == EXPERT) difficultyMultiplier = 1.5;
	
	self.pointsForThisStage = round(scoreForThisStage * ((9 + levelRank) * 10.0) * difficultyMultiplier) - (10 * totalExtraNotes);
	scoreForThisStage -=  .02 * totalExtraNotes;	
}

- (void) dealloc {
   self.allPlayedNotes = nil;
   self.measures = nil;
   self.expectedNotes = nil;
   self.originalExpectedNotes = nil;
   self.errors = nil;
   
	[originalExpectedNotes release];
	[measures release];
	[errors release];
	[super dealloc];
}


@end
