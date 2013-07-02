//
//  RhythmBaseController.m
//  Rhythms
//
//  Created by Julio Barros on 8/1/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "RhythmBaseController.h"
#import "RhythmsAppDelegate.h"
#import "Stage.h"

@implementation RhythmBaseController

-(RhythmEngine *) getRhythmEngine{
	RhythmsAppDelegate *rad = (RhythmsAppDelegate *)[[UIApplication sharedApplication] delegate];
	return rad.rhythmEngine;
}


-(RhythmsAppDelegate *) getAppDelegate{
	return (RhythmsAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(UIImage *) imageForStage{
	UIImage *image =  [UIImage imageWithContentsOfFile: [[self getRhythmEngine].stage getImagePath]];
	return image;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft  || interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}

@end
