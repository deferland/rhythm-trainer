//
//  UserTableCell.m
//  Rhythms
//
//  Created by Julio Barros on 8/10/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "UserTableCell.h"


@implementation UserTableCell

@synthesize name;
@synthesize levelsCompleted;
@synthesize accuracy;
@synthesize score;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
   self.name = nil;
   self.accuracy =nil;
   self.levelsCompleted = nil;
   self.score = nil;
    [super dealloc];
}


@end
