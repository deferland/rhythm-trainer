//
//  GamePlayController.h
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RhythmBaseController.h"

#import "MetronomeLED.h"

@class RhythmEngine;
@class GameController;

@interface GamePlayController : RhythmBaseController {
	IBOutlet UIButton *gamePad;
	IBOutlet UIImageView *imageView;
	IBOutlet UILabel *beatLabel;
	IBOutlet UIView *dimmingView;
	
	IBOutlet MetronomeLED *m1a;
	IBOutlet MetronomeLED *m1b;
	IBOutlet MetronomeLED *m2a;
	IBOutlet MetronomeLED *m2b;
	IBOutlet MetronomeLED *m3a;
	IBOutlet MetronomeLED *m3b;
	IBOutlet MetronomeLED *m4a;
	IBOutlet MetronomeLED *m4b;
	
	IBOutlet UILabel *levelDifficultyLabel;
	
	// Results stuff
	IBOutlet UIView *resultsView;
	IBOutlet UILabel *results;
	
	RhythmEngine *rhythmEngine;
	GameController *gameController;
	
	UIColor *viewColor;
	CGFloat viewBrightness;
}

@property (nonatomic, assign) RhythmEngine *rhythmEngine; // Should not retain or you'll create a circular reference
@property (nonatomic, assign) GameController *gameController; // Should not retain or you'll create a circular reference


-(IBAction) padUp:(id) sender;
-(IBAction) padDown:(id) sender;
-(IBAction) startMetronome:(id) sender;
-(void) lightMetronome:(int) segment;

-(void) turnOffVisualMetronome;
-(void) updateDisplay;

-(void) showResults;

-(void) prepareNewStage;
-(void) prepareSameStage;

-(IBAction) showGamePlay:(id) sender;

@end
