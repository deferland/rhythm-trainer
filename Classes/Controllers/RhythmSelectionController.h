//
//  RhythmSelectionController.h
//  Rhythms
//
//  Created by Julio Barros on 7/27/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RhythmBaseController.h"

@class LevelSelectionController;

@interface RhythmSelectionController : RhythmBaseController  <UITableViewDataSource, UITableViewDelegate>  {
	IBOutlet UILabel *username;
	IBOutlet UITableView *rhythmsTable;
	NSArray *rhythms;

	NSIndexPath *selectedPath;

}

@property (nonatomic,retain) NSArray *rhythms;
@property (nonatomic,retain) NSIndexPath *selectedPath;

@end
