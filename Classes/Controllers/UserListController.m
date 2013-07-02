//
//  UserListController.m
//  Rhythms
//
//  Created by Julio Barros on 7/27/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "UserListController.h"
#import "AddUserController.h"
#import "RhythmSelectionController.h"
#import "User.h"
#import "UserTableCell.h"
#import "LevelResult.h"

@implementation UserListController

@synthesize rhythmSelectionController;
@synthesize addUserController;
@synthesize users;
@synthesize addButton;


- (NSInteger) tableView:(UITableView *) table numberOfRowsInSection:(NSInteger) section {
	return users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath{
	User *user = [users objectAtIndex:indexPath.row];
	
    NSArray *cellTest = [[NSBundle mainBundle] loadNibNamed:@"UserTableCell" owner:self options:nil]; 	
	UserTableCell *cell = nil;
    id firstObj = [cellTest objectAtIndex:0];
    if ( [firstObj isKindOfClass:[UITableViewCell class]] )
        cell = [cellTest objectAtIndex:0];
    else
        cell = [cellTest objectAtIndex:1];
	
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	NSArray *levelResults = [LevelResult findByCondition:@"user_id = ?",[NSNumber numberWithInt:[user primaryKey]]];
	int score = 0;
	double accuracy = 0.0;
	for (LevelResult *levelResult in levelResults){
		score += [[levelResult getAttributeNamed:kScore] intValue];
		accuracy += [[levelResult getAttributeNamed:kAccuracy] doubleValue] / [levelResults count];
	}
	
	cell.name.text = [user getAttributeNamed:kUserName];
	if ([levelResults count] == 1)
		cell.levelsCompleted.text = @"1 level completed";
	else
		cell.levelsCompleted.text = [NSString stringWithFormat:@"%d levels completed",[levelResults count]];

	cell.accuracy.text = [NSString stringWithFormat:@"%.0f\%%",accuracy*100];
	cell.score.text = [NSString stringWithFormat:@"%d points",score];
	
	return cell;
}

- (void) gotoNextScreen{
	if (rhythmSelectionController == nil)
		self.rhythmSelectionController = [[[RhythmSelectionController alloc] initWithNibName:@"RhythmSelection" bundle:nil] autorelease];
	
	[self.navigationController pushViewController:rhythmSelectionController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 35.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	selectedPath = indexPath;
	User *user = [users objectAtIndex: indexPath.row];
	[self getRhythmEngine].user = user;
	[self getRhythmEngine].playMode = TEST;
	[self gotoNextScreen];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	self.title = @"Users";
	editingButton.title = @"Add/Edit Users";

}

- (void) viewWillAppear:(BOOL) animated {

	self.users = [NSMutableArray arrayWithArray:[User findByCondition:@" 1 = 1 order by UPPER(name)"]];
	[usersTable reloadData];
}

-(void) viewDidAppear:(BOOL)animated {
	[usersTable deselectRowAtIndexPath:selectedPath animated:YES];
	[super viewDidAppear:animated];
}

// Free up some memory incase we get a ton of users. 
- (void) viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear:animated];
	self.users = nil;
}

-(void) addUser {
	if (addUserController == nil)
		addUserController = [[[AddUserController alloc] initWithNibName:@"AddUser" bundle:nil] autorelease];
	[self.navigationController pushViewController:addUserController animated:YES];
}


-(IBAction) editUsers:(id) sender{
	[usersTable setEditing:!usersTable.editing animated: YES]; 
	
	if (usersTable.editing){
		if (addButton == nil)
			self.addButton = [[[UIBarButtonItem alloc] initWithTitle:@"Add User" 
                                                            style:UIBarButtonItemStyleBordered 
                                                           target:self 
                                                           action:@selector(addUser)] autorelease];
		self.navigationItem.leftBarButtonItem = addButton;
		editingButton.title = @"Done";
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		editingButton.title = @"Add/Edit Users";
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete){
		User *user = [users objectAtIndex: indexPath.row];

		[LevelResult deleteAllWithCondition:@"user_id = ?",[NSNumber numberWithInt:[user primaryKey]]];
		[user delete];
		[users removeObjectAtIndex: indexPath.row];
		NSArray *paths = [NSArray arrayWithObject: indexPath];
		[usersTable deleteRowsAtIndexPaths:	paths withRowAnimation:YES];
	} else if (editingStyle == UITableViewCellEditingStyleInsert){
		//  Add a user.
	}
}


-(IBAction) showAboutController:(id) sender{
	[self.navigationController pushViewController:aboutController animated:YES];
}

-(IBAction) showInstructionsController:(id) sender{
	[self.navigationController pushViewController:instructionsController animated:YES];
}

-(IBAction) showSetupController:(id) sender{
	[self.navigationController pushViewController:setupController animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
   self.addUserController = nil;
  self.rhythmSelectionController = nil;
  self.addButton = nil;
   self.users = nil;
  [addUserController release];
    [super dealloc];
}


@end
