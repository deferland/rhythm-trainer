//
//  Level.h
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActiveRecord.h"

@class Stage;
@class Rhythm;

@interface Level : ActiveRecord {
	NSString *name;
	NSString *description;
	NSMutableArray *stages;
	Rhythm *rhythm;
	int _rank;
    int curStageIndex;
}

@property (nonatomic, retain) Rhythm *rhythm;
@property (nonatomic, retain) NSMutableArray *stages;

- (int) stageIndex;
- (Stage*) firstStage;    

-(Stage *) randomStage;
-(void) loadAllStages;
-(int) rank;
- (BOOL) hasDownloadedStages;

- (BOOL) nextStageAvailable;
- (Stage*) nextStage;

- (void) shuffle;

@end
