//
//  SaveScoreController.m
//  Rhythms
//
//  Created by Julio Barros on 9/10/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "SaveScoreController.h"


@implementation SaveScoreController


-(void) viewWillAppear:(BOOL) animated {
	RhythmEngine *engine = [self getRhythmEngine];
	if ([engine enoughStagesPlayedForThisLevel]){
		congratulationsLabel.text = @"Congratulations";
		message.text = [NSString stringWithFormat:@"You completed %d stages and got a score of %.0f\%% and %d points.",
						[engine stagesCompletedForThisLevel],[engine scoreForThisLevel] * 100,[engine pointsForThisLevel]];
		saveButton.enabled = YES;
	} else {
		congratulationsLabel.text = nil;
		message.text = @"You have not played enough stages for this level to save a score.";
		saveButton.enabled = NO;
	}
}

-(IBAction) saveScore:(id) sender{
	[[self getRhythmEngine] saveLevelScore];
	[self.navigationController popToRootViewControllerAnimated:YES]; 
}
-(IBAction) doNotSaveScore:(id) sender{
	[self.navigationController popToRootViewControllerAnimated:YES]; 	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
