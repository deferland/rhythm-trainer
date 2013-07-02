//
//  GameController.h
//  Rhythms
//
//  Created by Julio Barros on 7/24/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RhythmBaseController.h"
#import "SaveScoreController.h"

@class GamePlayController;
@class StageResultsController;

@interface GameController : RhythmBaseController {
	GamePlayController *gamePlayController;
	StageResultsController *stageResultsController;
	SaveScoreController *saveScoreController;
	
	BOOL useSameStage;
}

@property(nonatomic,retain) SaveScoreController *saveScoreController;
@property(nonatomic,retain) GamePlayController *gamePlayController;
@property(nonatomic,retain) StageResultsController *stageResultsController;

- (void)toggleView;

-(void) nextStage;
-(void) sameStage;

-(void) endGame;
@end
