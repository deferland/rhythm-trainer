//
//  PrePlaySplashController.m
//  Rhythms
//
//  Created by Julio Barros on 10/22/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "PrePlaySplashController.h"


@implementation PrePlaySplashController


-(IBAction) continue:(id) sender{
	GameController *gameController = [[[GameController alloc] init] autorelease];
	[self.navigationController pushViewController:gameController animated:NO];
}

- (void)dealloc {
   NSLog(@"Preplay splash controller dealloc");
    [super dealloc];
}


@end
