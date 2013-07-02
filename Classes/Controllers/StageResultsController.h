//
//  StageResultsController.h
//  Rhythms
//
//  Created by Julio Barros on 7/24/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RhythmBaseController.h"

@class GameController;
@class RhythmEngine;

@interface StageResultsController : RhythmBaseController  <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UILabel *lable;
	IBOutlet UIImageView *imageView;
	IBOutlet UITableView *errorTable;
	
	IBOutlet UIButton *sameStageButton;

	CGRect tableFrame;
	GameController *gameController;
}

@property(nonatomic, assign) GameController *gameController; // Should not retain or you'll create a circular reference

-(IBAction) nextStage:(id) sender;
-(IBAction) sameStage:(id) sender;
-(IBAction) endGame:(id) sender;
-(IBAction) emailResults:(id) sender;
@end
