//
//  GamePlayController.m
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "GamePlayController.h"
#import "GameController.h"
#import "RhythmEngine.h"
#import "RhythmsAppDelegate.h"
#import "Rhythm.h"
#import "Level.h"
#import "Stage.h"
#import "ModelConstants.h"

@implementation GamePlayController

@synthesize rhythmEngine;
@synthesize gameController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.rhythmEngine = [self getRhythmEngine];
		rhythmEngine.gamePlayController = self;
	}
	return self;
}

-(void) dimScreen:(Boolean) dim{
	dimmingView.hidden = !dim;
}

-(void) prepareForStage {
	imageView.image = [self imageForStage];
	[self dimScreen:YES];
	[gamePad setTitle: @"Tap Here" forState:  UIControlStateNormal ];
    levelDifficultyLabel.text = [NSString stringWithFormat:@"Level %@ Stage %d",[rhythmEngine.level getAttributeNamed:kName],[rhythmEngine curStageIndex]];
}


-(void) prepareNewStage{
    if ([rhythmEngine newStageAvailable])
        [rhythmEngine newStage];
    else if (rhythmEngine.playMode == PRACTICE)
        [rhythmEngine firstStage];    
    
    [self prepareForStage];
}

-(void) prepareSameStage {
	[rhythmEngine sameStage];
	[self prepareForStage];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    levelDifficultyLabel.text = [NSString stringWithFormat:@"Level %@ Stage %d",[rhythmEngine.level getAttributeNamed:kName],[rhythmEngine curStageIndex]];
}


-(void) showResults{
	[gameController toggleView];
}


-(IBAction) showGamePlay:(id) sender{
	UIView *superView = [resultsView superview];
	[resultsView removeFromSuperview];
	[superView addSubview:self.view];
}


-(IBAction) startMetronome:(id) sender{
	if (rhythmEngine.metronomePlaying == NO){
		[rhythmEngine startMetronome];
	} else{
		[rhythmEngine stopMetronome];
	}
}

-(IBAction) padDown:(id) sender{
	[rhythmEngine padDown];
}

-(IBAction) padUp:(id) sender{
	[rhythmEngine padUp];
}

-(void) turnOffAllLEDs {
	[m1a on:NO];
	[m1b on:NO];
	[m2a on:NO];
	[m2b on:NO];
	[m3a on:NO];
	[m3b on:NO];
	[m4a on:NO];
	[m4b on:NO];
}

-(void) turnOffVisualMetronome {
	beatLabel.text = @"";
	[self turnOffAllLEDs];
}

-(void) turnOnAllLEDs {
   NSLog(@"m1a = %@", m1a);
	[m1a on:YES];
	[m1b on:YES];
	[m2a on:YES];
	[m2b on:YES];
	[m3a on:YES];
	[m3b on:YES];
	[m4a on:YES];
	[m4b on:YES];
}

-(void) lightMetronome:(int) segment{	
	switch (segment) {
		case 0:
			[self turnOffAllLEDs];
			break;
			
		case 1:
			[m1a on:YES];
			[m1b on:YES];
			break;
		case 2:
			[m2a on:YES];
			[m2b on:YES];
			break;
		case 3:
			[m3a on:YES];
			[m3b on:YES];
			break;
		case 4:
			[m4a on:YES];
			[m4b on:YES];
			break;
			
		default:
			break;
	}
}

-(void) drawPadLabel{
	int beatDisplay = rhythmEngine.beatNumber;

	int firstCountDownLabel = 4;
	
	if ([rhythmEngine isBasic68])
		firstCountDownLabel = 6;
	if ([rhythmEngine isAdvanced68])
		firstCountDownLabel = 12;
		
	if (beatDisplay >= -firstCountDownLabel){
		if (beatDisplay < 0){
			if ([rhythmEngine isAdvanced68]){
				beatDisplay = -ceil(-beatDisplay / 3.0);
			}
			[gamePad setTitle:[NSString stringWithFormat:@"%d",-beatDisplay] forState:  UIControlStateNormal ];
		}
		else if (beatDisplay == 1){
			[gamePad setTitle: @"Go" forState:  UIControlStateNormal ];
			[gamePad setTitle: @"" forState:  UIControlStateHighlighted ];
			[self dimScreen:NO];
		}
	}
}

-(void) updateDisplay44{
	int beatDisplay = rhythmEngine.beatNumber % rhythmEngine.upperSignature;
	if (beatDisplay == 0) 
		beatDisplay = rhythmEngine.upperSignature;
	beatLabel.text = [NSString stringWithFormat:@"%d",beatDisplay];
}

-(void) updateDisplay68{
	int beatDisplay = rhythmEngine.beatNumber % rhythmEngine.upperSignature;
	if (beatDisplay == 0) 
		beatDisplay = rhythmEngine.upperSignature;
	if ([rhythmEngine isAdvanced68]){
		if (beatDisplay < 4) 
			beatDisplay = 1;
		else
			beatDisplay = 2;
	}
	beatLabel.text = [NSString stringWithFormat:@"%d",beatDisplay];
}

-(void) updateDisplay{

	// If its not a down beat then we only need to clear the metronome on the up beat
	if (![rhythmEngine downBeat]){
		if (!rhythmEngine.playing && ![rhythmEngine isAdvanced68]){
			[self turnOffAllLEDs];
		}
		if (!rhythmEngine.playing && (abs(rhythmEngine.beatNumber -1) % 3 == 0))
			[self turnOffAllLEDs];
		return;
	}
	
	[self drawPadLabel];
	
	if (rhythmEngine.beatNumber >= 0){
		if (rhythmEngine.lowerSignature == 4)
			[self updateDisplay44];
		else
			[self updateDisplay68];
	}
	if (!rhythmEngine.playing){
		if ([rhythmEngine isAdvanced68]){
			if (abs(rhythmEngine.beatNumber) % 3 == 0)
				[self turnOnAllLEDs];
		} else {
			[self turnOnAllLEDs];			
		}
	} 
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
   NSLog(@"gamePlayController dealloc");
   self.rhythmEngine.gamePlayController = nil;
   self.rhythmEngine = nil;
   self.gameController = nil;
	[super dealloc];
}


@end
