//
//  GameController.m
//  Rhythms
//
//  Created by Julio Barros on 7/24/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "GameController.h"
#import "GamePlayController.h"
#import "StageResultsController.h"

@implementation GameController

@synthesize gamePlayController,stageResultsController, saveScoreController;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.gamePlayController = [[[GamePlayController alloc] initWithNibName:@"GamePlay" bundle: nil] autorelease];
		gamePlayController.gameController = self;
		self.hidesBottomBarWhenPushed = YES;
		[self.view addSubview: gamePlayController.view];
		[gamePlayController prepareNewStage];
	}
	return self;
}

-(void) viewWillAppear:(BOOL) animated{
	[super viewWillAppear:animated];
	
	if ( self.navigationController.navigationBarHidden == NO ) {
        self.navigationController.navigationBarHidden = YES;
        CGRect frame = self.view.frame;
        frame.size.height += 44;
        self.view.frame = frame;    
    } 
	
	if ([gamePlayController.view superview] == nil){
		[self toggleView];
	}
}

-(void) viewWillDisappear:(BOOL) animated{
  self.navigationController.navigationBarHidden = NO;
}

- (void)toggleView {	

	if (stageResultsController == nil) {
      self.stageResultsController = [[[StageResultsController alloc] initWithNibName:@"StageResults" bundle:nil] autorelease];
		stageResultsController.gameController = self;
	}
	
	UIView *gamePlayView = gamePlayController.view;
	UIView *stageResultsView = stageResultsController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([gamePlayView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	
	if ([gamePlayView superview] != nil) {
		[stageResultsController viewWillAppear:YES];
		[gamePlayController viewWillDisappear:YES];
		[gamePlayView removeFromSuperview];
		[self.view addSubview:stageResultsView];
		[gamePlayController viewDidDisappear:YES];
		[stageResultsController viewDidAppear:YES];
		
	} else {
		if (useSameStage){
			useSameStage = NO;
			[gamePlayController prepareSameStage];
		} else            
            [gamePlayController prepareNewStage];
		
		[gamePlayController viewWillAppear:YES];
		[stageResultsController viewWillDisappear:YES];
		[stageResultsView removeFromSuperview];
		[self.view addSubview:gamePlayView];
		[stageResultsController viewDidDisappear:YES];
		[gamePlayController viewDidAppear:YES];
	}
	[UIView commitAnimations];
}

-(void) nextStage{
    if ([[self getRhythmEngine] newStageAvailable] == NO)
        if ([self getRhythmEngine].playMode == TEST)
            [self endGame];
        if ([self getRhythmEngine].playMode == PRACTICE)
            [self toggleView];
	else 
		[self toggleView];
}

-(void) sameStage{
	useSameStage = YES;
	[self nextStage];
}

-(void) endGame{
	if ([self getRhythmEngine].playMode == TEST){
		if (saveScoreController == nil){
			self.saveScoreController = [[[SaveScoreController alloc] initWithNibName:@"SaveScore"	bundle:nil] autorelease];
		}
		[self.navigationController pushViewController:saveScoreController animated:YES];
	} else {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
   NSLog(@"GameController dealloc");
  self.gamePlayController = nil;
  self.stageResultsController = nil;
	[saveScoreController release];
	[super dealloc];
}


@end
