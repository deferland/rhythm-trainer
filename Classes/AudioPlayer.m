//
//  AudioPlayer.m
//  Rhythms
//
//  Created by Julio Barros on 9/23/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer
@synthesize soundFile;

- (id) init
{
	self = [super init];
	if (self != nil) {
	  song = [[GBMusicTrack alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"CLARINT2" ofType:@"wav"]];
	  [song setRepeat:YES];
		[song setGain:.4];
	}
	return self;
}


- (IBAction) startSound {
  [song play];
}

- (IBAction) stopSound {
  [song pause];
}

- (void)dealloc {
  [song release];
  [super dealloc];
}

@end
