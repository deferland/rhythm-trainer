//
//  AddUserController.m
//  Rhythms
//
//  Created by Julio Barros on 8/10/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "AddUserController.h"
#import "User.h"
#import "ModelConstants.h"

@implementation AddUserController

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
	return YES;
}

-(IBAction) addUser:(id) sender{
	User *user = [[User alloc] init];
	[user setAttributeNamed:kUserName value:name.text];
	[user save];
	[self.navigationController popViewControllerAnimated:YES];
	[user release];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
