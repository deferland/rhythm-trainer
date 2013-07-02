//
//  RhythmsAppDelegate.h
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright E-String Technologies, Inc. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelResult.h"

@class RhythmsViewController;

@class RhythmEngine;
@class Rhythm;

@interface RhythmsAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;

	RhythmEngine *rhythmEngine;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RhythmEngine *rhythmEngine;

@end

