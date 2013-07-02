//
//  RhythmBaseController.h
//  Rhythms
//
//  Created by Julio Barros on 8/1/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RhythmsAppDelegate.h"
#import "RhythmEngine.h"

@interface RhythmBaseController : UIViewController {

}

-(RhythmEngine *) getRhythmEngine;
-(RhythmsAppDelegate *) getAppDelegate;
-(UIImage *) imageForStage;

@end
