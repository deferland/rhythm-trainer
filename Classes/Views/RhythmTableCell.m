//
//  RhythmTableCell.m
//  Rhythms
//
//  Created by Julio Barros on 8/11/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "RhythmTableCell.h"


@implementation RhythmTableCell

@synthesize name;
@synthesize levelsCompleted;
@synthesize accuracy;

/* removed to avoid 'depricated' warning
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}
*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
   self.name =nil;
   self.levelsCompleted = nil;
   self.accuracy = nil;
    [super dealloc];
}


@end
