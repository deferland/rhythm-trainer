//
//  UserListController.h
//  Rhythms
//
//  Created by Julio Barros on 7/27/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RhythmBaseController.h"

#import "AboutController.h"
#import "InstructionsController.h"
#import "SetupController.h"

@class AddUserController;
@class RhythmSelectionController;

@interface UserListController : RhythmBaseController  <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *usersTable;
	IBOutlet UIBarButtonItem *addButton;
	
	IBOutlet UIBarButtonItem *editingButton;
	
	NSMutableArray *users;

	RhythmSelectionController *rhythmSelectionController;
	AddUserController *addUserController;
	
	NSIndexPath *selectedPath;
	
	IBOutlet AboutController *aboutController;
	IBOutlet InstructionsController *instructionsController;
	IBOutlet SetupController *setupController;
}

@property (nonatomic,retain) AddUserController *addUserController;
@property (nonatomic,retain) RhythmSelectionController *rhythmSelectionController;
@property (nonatomic,retain) NSMutableArray *users;
@property (nonatomic,retain) UIBarButtonItem *addButton;

-(IBAction) editUsers:(id) sender;

-(IBAction) showAboutController:(id) sender;
-(IBAction) showInstructionsController:(id) sender;
-(IBAction) showSetupController:(id) sender;

-(void) addUser;

@end
