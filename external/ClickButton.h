//
//  ClickButton.h
//  WordTower
//
//  Created by Christopher Garrett on 3/5/10.
//  Copyright 2010 ZWorkbench, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTButton.h"

@interface ClickButton : DTButton {
   UIColor *enabledColor;
}

@property(nonatomic, retain) NSString *soundName;
@property(nonatomic, retain) UIColor *enabledColor;

- (void) bounce;
- (void) click;
- (void) useDarkBlueBorder;
- (void) useGreenBorder;

@end
