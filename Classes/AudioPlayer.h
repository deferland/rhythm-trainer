//
//  AudioPlayer.h
//  Rhythms
//
//  Created by Julio Barros on 9/23/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

#import "GBMusicTrack.h" 
@interface AudioPlayer : NSObject {
  GBMusicTrack *song;

	NSString *soundFile;
}

@property (nonatomic,retain) NSString *soundFile;

- (void) startSound;
- (void) stopSound;

@end
