//
//  RhythmTableCell.h
//  Rhythms
//
//  Created by Julio Barros on 8/11/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RhythmTableCell : UITableViewCell {
	IBOutlet UILabel *name;
	IBOutlet UILabel *levelsCompleted;
	IBOutlet UILabel *accuracy;
}

@property (nonatomic,retain) UILabel *name;
@property (nonatomic,retain) UILabel *levelsCompleted;
@property (nonatomic,retain) UILabel *accuracy;

@end
