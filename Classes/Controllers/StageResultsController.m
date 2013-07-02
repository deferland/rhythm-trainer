//
//  StageResultsController.m
//  Rhythms
//
//  Created by Julio Barros on 7/24/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "StageResultsController.h"
#import "GameController.h"
#import "RhythmEngine.h"
#import "Stage.h"
#import "StageScorer.h"

@implementation StageResultsController

@synthesize gameController;



-(IBAction) nextStage:(id) sender{
	[gameController nextStage];
}

-(IBAction) sameStage:(id) sender{
	[gameController sameStage];
}

-(IBAction) endGame:(id) sender{
	[gameController endGame];
}

-(IBAction) emailResults:(id) sender {
	RhythmEngine *engine = [self getRhythmEngine];
	NSMutableString *url = [[NSMutableString alloc] initWithString: @"mailto:Julio@E-String.com?subject=RIR Game Result&body="];
	[url appendFormat:@"rhythm %@\n",[engine rhythm]];
	[url appendFormat:@"level %@\n",[engine level]];
	[url appendFormat:@"stage %@\n",[engine stage]];
	[url appendFormat:@"mode %d\n",[engine playMode]];
	[url appendFormat:@"speed %d\n",[engine speed]];
	[url appendFormat:@"difficulty %d\n",[engine difficulty]];
	[url appendFormat:@"maxDiffAtStart %f\n",[engine maxDiffAtStart]];
	[url appendFormat:@"minPercentageForStop %f\n",[engine minPercentageForStop]];
	[url appendFormat:@"expectedNotes %@\n",engine.stageScorer.originalExpectedNotes];
	[url appendFormat:@"allPlayedNotes %@\n",[engine.stageScorer allPlayedNotes]];
//	[url appendFormat:@"errors %@\n",[engine.stageScorer errors]];

	NSURL *nsurl =  [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	[[UIApplication sharedApplication] openURL: nsurl];
	[url release];
}


-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Work around bug in redrawing table
	if (tableFrame.origin.x == 0){
		tableFrame = errorTable.frame;
	} else {
		errorTable.frame = tableFrame;
	}
	
	RhythmEngine *engine = [self getRhythmEngine];
	
	if (engine.playMode == PRACTICE)
		sameStageButton.hidden = NO;
	else
		sameStageButton.hidden = YES;
	
	lable.text = [NSString stringWithFormat:@"%.0f\%% accuracy %d points    %d stages completed %d points",
				  engine.stageScorer.scoreForThisStage*100,engine.stageScorer.pointsForThisStage,[engine stagesCompletedForThisLevel],engine.pointsForThisLevel];
	imageView.image = [self imageForStage];
	[errorTable reloadData];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
   self.gameController = nil;
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	RhythmEngine *engine = [self getRhythmEngine];

	return MAX(1,[engine.stageScorer.errors count]);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	RhythmEngine *engine = [self getRhythmEngine];
	NSString *title  = @"No Errors";
	NSDictionary *measuresErrors = nil;
	if ([engine.stageScorer.errors count] > section){
		measuresErrors = [engine.stageScorer.errors objectAtIndex:section];
	}
	if (measuresErrors != nil)
		title = [measuresErrors objectForKey:ERROR_TITLE];
    return title;	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	RhythmEngine *engine = [self getRhythmEngine];
	int numberOfRowsInSection = 0;
	
	NSDictionary *measuresErrors = nil;
	if ([engine.stageScorer.errors count] > section){
		measuresErrors = [engine.stageScorer.errors objectAtIndex:section];
	}
	
	if (measuresErrors != nil)
		numberOfRowsInSection = [[measuresErrors objectForKey:ERROR_LIST] count];
	
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RhythmEngine *engine = [self getRhythmEngine];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	cell.textLabel.text = [[[engine.stageScorer.errors  objectAtIndex:indexPath.section] valueForKey:ERROR_LIST] objectAtIndex:indexPath.row];
    return cell;
}



@end
