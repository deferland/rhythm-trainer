//
//  SetupController.h
//  Rhythms
//
//  Created by Julio Barros on 7/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RhythmBaseController.h"


@interface SetupController : RhythmBaseController {
	IBOutlet UISwitch *standardCountdownSwitch;
	IBOutlet UISegmentedControl *speedControl;
	IBOutlet UISegmentedControl *difficultyControl;
}

-(IBAction) setStandardCountDown:(id) sender;
-(IBAction) setSpeed:(id) sender;
-(IBAction) setDifficulty:(id) sender;

@end
