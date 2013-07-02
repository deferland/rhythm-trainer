//
//  AddUserController.h
//  Rhythms
//
//  Created by Julio Barros on 8/10/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RhythmBaseController.h"

@interface AddUserController : RhythmBaseController <UITextFieldDelegate> {
	IBOutlet UITextField *name;

}

-(IBAction) addUser:(id) sender;

@end
