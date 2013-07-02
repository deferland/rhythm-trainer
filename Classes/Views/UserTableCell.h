//
//  UserTableCell.h
//  Rhythms
//
//  Created by Julio Barros on 8/10/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserTableCell : UITableViewCell {
	IBOutlet UILabel *name;
	IBOutlet UILabel *levelsCompleted;
	IBOutlet UILabel *accuracy;
	IBOutlet UILabel *score;
}

@property (nonatomic,retain) UILabel *name;
@property (nonatomic,retain) UILabel *levelsCompleted;
@property (nonatomic,retain) UILabel *accuracy;
@property (nonatomic,retain) UILabel *score;

@end
