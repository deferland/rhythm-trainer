//
//  ScoreModeController.m
//  Rhythms
//
//  Created by Julio Barros on 7/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "ScoreModeController.h"
#import "GameController.h"
#import "Rhythm.h"
#import "Level.h"
#import "ModelConstants.h"

@implementation ScoreModeController

- (void)viewWillAppear:(BOOL)animated{
	rhythmLabel.text = [[self getRhythmEngine].rhythm getAttributeNamed:kName];
	levelLabel.text = [[self getRhythmEngine].level getAttributeNamed:kName];
	
	playerLabel.text = [[self getRhythmEngine].user description];
	
	NSString *speed = @"unknown";
	switch ([self getRhythmEngine].speed) {
		case SLOW:
			speed = @"Slow";
			break;
		case MEDIUM:
			speed = @"Medium";
			break;
		case FAST:
			speed = @"Fast";
			break;
		default:
			break;
	}
	BPMLabel.text = speed;
	
	NSString *playMode = @"unknown";
	switch ([self getRhythmEngine].playMode) {
		case TEST:
			playMode = @"Test";
			break;
		case PRACTICE:
			playMode = @"Practice";
			break;		
		default:
			break;
	}
	playModeLabel.text= playMode;
}

-(IBAction) playForScore{
	[self getRhythmEngine].playMode = TEST;
   PrePlaySplashController *prePlaySplashController = [[[PrePlaySplashController alloc] initWithNibName:@"PrePlaySplash" bundle:nil] autorelease];
	[self.navigationController pushViewController:prePlaySplashController animated:YES];
}

-(IBAction) playForPractice{
	[self getRhythmEngine].playMode = PRACTICE;
	GameController *gameController = [[[GameController alloc] init] autorelease];
	
	[self.navigationController pushViewController:gameController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
   NSLog(@"ScoreModeController dealloc");
    [super dealloc];
}


@end
