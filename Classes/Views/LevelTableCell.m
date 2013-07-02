//
//  LevelTableCell.m
//  Rhythms
//
//  Created by Julio Barros on 8/19/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "LevelTableCell.h"


@implementation LevelTableCell

@synthesize name;
@synthesize description;
@synthesize accuracy;
@synthesize stagesNum;
@synthesize buyBtn;


- (void)dealloc {
   self.name = nil;
   self.description = nil;
   self.accuracy = nil;
   [super dealloc];
}


@end
