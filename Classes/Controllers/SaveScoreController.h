//
//  SaveScoreController.h
//  Rhythms
//
//  Created by Julio Barros on 9/10/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RhythmBaseController.h"


@interface SaveScoreController : RhythmBaseController {
	IBOutlet UITextView *message;
	IBOutlet UILabel *congratulationsLabel;
	IBOutlet UIButton *saveButton;
}

-(IBAction) saveScore:(id) sender;
-(IBAction) doNotSaveScore:(id) sender;


@end
