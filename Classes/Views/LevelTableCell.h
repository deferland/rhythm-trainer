//
//  LevelTableCell.h
//  Rhythms
//
//  Created by Julio Barros on 8/19/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "ClickButton.h"


@interface LevelTableCell : UITableViewCell {
	IBOutlet UILabel *name;
	IBOutlet UIImageView *description;
	IBOutlet UILabel *accuracy;
    IBOutlet UILabel *stagesNum;
    IBOutlet ClickButton *buyBtn;
}

@property (nonatomic,retain) UILabel *name;
@property (nonatomic,retain) UIImageView *description;
@property (nonatomic,retain) UILabel *accuracy;
@property (nonatomic,retain) UILabel *stagesNum;
@property (nonatomic,retain) ClickButton *buyBtn;


@end
