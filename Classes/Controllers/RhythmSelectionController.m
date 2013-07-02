//
//  RhythmSelectionController.m
//  Rhythms
//
//  Created by Julio Barros on 7/27/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "RhythmSelectionController.h"
#import "LevelSelectionController.h"
#import "Rhythm.h"
#import "Level.h"
#import "RhythmTableCell.h"
#import "User.h"
#import "ModelConstants.h"
#import "LevelResult.h"

@implementation RhythmSelectionController

@synthesize rhythms;
@synthesize selectedPath;


- (NSInteger) tableView:(UITableView *) table numberOfRowsInSection:(NSInteger) section {
	return rhythms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath{
	
    NSArray *cellTest = [[NSBundle mainBundle] loadNibNamed:@"RhythmTableCell" owner:self options:nil]; 	
	RhythmTableCell *cell = nil;
    id firstObj = [cellTest objectAtIndex:0];
    if ( [firstObj isKindOfClass:[UITableViewCell class]] )
        cell = [cellTest objectAtIndex:0];
    else
        cell = [cellTest objectAtIndex:1];
	
	Rhythm *rhythm = [rhythms objectAtIndex:indexPath.row];
	
	NSNumber *rpk = [NSNumber numberWithInt: [rhythm primaryKey]];
	NSArray *levelsForThisRhythm = [Level findByCondition:@"rhythm_id = ?",rpk];
	
	id user =  [self getRhythmEngine].user;
	NSArray *levelResults = [LevelResult findByCondition:@"user_id = ? and rhythm_id = ?",[NSNumber numberWithInt:[user primaryKey]],
							 [NSNumber numberWithInt:[rhythm primaryKey]]];
	double accuracy = 0.0;
	for (LevelResult *levelResult in levelResults){
		accuracy += [[levelResult getAttributeNamed:kAccuracy] doubleValue] / [levelResults count];
	}
	
	cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	cell.name.text = [rhythm getAttributeNamed:kName];
	if ([levelResults count] == 1)	
		cell.levelsCompleted.text = [NSString stringWithFormat:@"%d level of %d completed",[levelResults count],[levelsForThisRhythm count]];
	else
		cell.levelsCompleted.text = [NSString stringWithFormat:@"%d levels of %d completed",[levelResults count],[levelsForThisRhythm count]];
	cell.accuracy.text = [NSString stringWithFormat:@"%.0f\%% accuracy",accuracy*100];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	self.selectedPath = indexPath;
	[self getRhythmEngine].rhythm = [rhythms objectAtIndex:indexPath.row];
   LevelSelectionController *levelSelectionController = [[[LevelSelectionController alloc] initWithNibName:@"LevelSelection" bundle:nil] autorelease];
	
	[self.navigationController pushViewController:levelSelectionController animated:YES];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self == [super initWithNibName:nibNameOrNil	bundle:nibBundleOrNil]){
		self.title = @"Time Signature Select";
		self.rhythms = [Rhythm findAll];
	}
	return self;
}


- (void)viewWillAppear:(BOOL)animated{
	username.text = [[self getRhythmEngine].user getAttributeNamed:kUserName];
	[rhythmsTable reloadData];
}


-(void) viewDidAppear:(BOOL)animated {
   if (self.selectedPath) {
      [rhythmsTable deselectRowAtIndexPath: self.selectedPath animated:YES];      
   }
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
  self.rhythms = nil;
   self.selectedPath = nil;
  [super dealloc];
}


@end
