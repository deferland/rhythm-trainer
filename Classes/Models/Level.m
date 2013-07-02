//
//  Level.m
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "Level.h"
#import "Stage.h"
#import "ModelConstants.h"

@implementation Level

@synthesize stages;
@synthesize rhythm;

- (id) init
{
	self = [super init];
	if (self != nil) {
		_rank = -1;
        self->curStageIndex = 0;
	}
    
	return self;
}

- (BOOL) nextStageAvailable{
    if  (self->curStageIndex < [stages count])
        return YES;
    else
        return NO;
}


- (int) stageIndex{
    return self->curStageIndex;
}

- (Stage*) firstStage{
    if (stages == nil || [stages count] == 0 )
		return nil;    

    self->curStageIndex = 0;
    Stage* res = [stages objectAtIndex: self->curStageIndex ];
    self->curStageIndex++;
    return res;
    
}

- (Stage*) nextStage{
    NSLog(@"Level '%@' %s : curStageIndex %d of %d ", self->name ,__FUNCTION__, self->curStageIndex, [stages count]);    
	if (stages == nil || [stages count] == 0 || self->curStageIndex == [stages count])
		return nil;    
    
    Stage* res = [stages objectAtIndex: self->curStageIndex ];
    self->curStageIndex++;
    return res;
}

-(Stage *) randomStage{
	if (stages == nil || [stages count] == 0)
		return nil;
	
	int index = random() % [stages count];
	return [stages objectAtIndex:index];    
}

-(void) loadAllStages{
	NSNumber *lpk = [NSNumber numberWithInt: [self primaryKey]];
	self.stages = [NSMutableArray array];
	[stages addObjectsFromArray: [Stage findByCondition:@"level_id = ?",lpk]];
	for (Stage *stage in self.stages){
		stage.level = self;
	}
    [self shuffle];
}

- (BOOL) hasDownloadedStages
{
    NSString *sql = [[NSString alloc] initWithFormat: @"select * from Stages where file_name  like '%@-%%' and downloaded = 1", 
                     [self getAttributeNamed:kDirectoryName]];
	QueryResult *result = [[ActiveRecord connection] prepareAndExecute: sql];
    [sql release];
	if ([result rowCount] > 0)
        return YES;
                     
	return NO;    
}

int randomSort(id obj1, id obj2, void *context ) {
    // returns random number -1 0 1
	return (random()%3 - 1);	
}

- (void)shuffle {
    // call custom sort function
	[self.stages sortUsingFunction:randomSort context:nil];    
}

// The numeric version of the name
-(int) rank{
	if (_rank < 0)
		_rank = [[self name] intValue];
	return _rank;
}

-(void) dealloc{
  self.stages = nil;
  self.rhythm = nil;
  [super dealloc];
}

@end
