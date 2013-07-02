//
//  ScoreModeController.h
//  Rhythms
//
//  Created by Julio Barros on 7/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RhythmBaseController.h"
#import "PrePlaySplashController.h"
#import "GameController.h"

@interface ScoreModeController : RhythmBaseController {
	IBOutlet UILabel *playerLabel;
	IBOutlet UILabel *playModeLabel;
	IBOutlet UILabel *rhythmLabel;
	IBOutlet UILabel *levelLabel;
	IBOutlet UILabel *BPMLabel;
	
}


-(IBAction) playForScore;
-(IBAction) playForPractice;

@end
