//
//  Stage.h
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveRecord.h"



@class Level;

@interface Stage : ActiveRecord {
	Level *level;
	NSArray *timingSequence;
	NSMutableArray *notes;
}

@property (nonatomic, assign) Level *level; // Should not retain parent or it will cause a circular reference
@property (nonatomic,retain) NSArray *timingSequence;
@property (nonatomic,retain) NSMutableArray *notes;

-(double) totalTicks;
-(NSString *) getImagePath;
-(NSString*) getResourcePath: (NSString*)fileType;
-(NSArray *) loadTimingSequence;

@end
