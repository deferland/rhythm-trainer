//
//  SetupController.m
//  Rhythms
//
//  Created by Julio Barros on 7/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "SetupController.h"
#import "ModelConstants.h"

@implementation SetupController

-(void) viewWillAppear:(BOOL) animated{	
	standardCountdownSwitch.on = [self getRhythmEngine].standardCountDown;
	speedControl.selectedSegmentIndex = [self getRhythmEngine].speed -1;
	difficultyControl.selectedSegmentIndex = [self getRhythmEngine].difficulty;
}


-(void) viewWillDisappear:(BOOL) animated{
	[[NSUserDefaults standardUserDefaults] setBool:standardCountdownSwitch.on forKey:kStandardCountdown];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[self getRhythmEngine].speed] forKey:kSelectedSpeed];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[self getRhythmEngine].difficulty] forKey:kDifficulty];
}

-(IBAction) setStandardCountDown:(id) sender{
	[self getRhythmEngine].standardCountDown = standardCountdownSwitch.on;
}

-(IBAction) setSpeed:(id) sender{
	[[self getRhythmEngine] setSpeedAndBPM:speedControl.selectedSegmentIndex + 1];
}

-(IBAction) setDifficulty:(id) sender{
	[self getRhythmEngine].difficulty = difficultyControl.selectedSegmentIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
