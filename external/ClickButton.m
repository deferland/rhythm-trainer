//
//  ClickButton.m
//  WordTower
//
//  Created by Christopher Garrett on 3/5/10.
//  Copyright 2010 ZWorkbench, Inc.. All rights reserved.
//

#import "ClickButton.h"

@implementation ClickButton

@synthesize soundName, enabledColor;

- (id)initWithFrame:(CGRect)aRect {
   [super initWithFrame: aRect];
   [self addTarget: self action: @selector(click) forControlEvents: UIControlEventTouchUpInside];
   self.enabledColor = self.backgroundColor;
   return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
   [super initWithCoder: aDecoder];
   [self addTarget: self action: @selector(click) forControlEvents: UIControlEventTouchUpInside];   
   self.enabledColor = self.backgroundColor;
   return self;
}

- (void) click {
}

- (void) bounce {
   CAKeyframeAnimation * animation;
   animation = [CAKeyframeAnimation animationWithKeyPath: @"position.y"];
   animation.duration = 10.0;
   animation.delegate = self;
   animation.removedOnCompletion = NO;
   animation.fillMode = kCAFillModeForwards;
   animation.beginTime = CACurrentMediaTime ();
   
   // Create arrays for values and associated timings.
   NSMutableArray *values = [NSMutableArray array];
   NSMutableArray *timings = [NSMutableArray array];
   float bounceHeight = 20.0;
   while (bounceHeight > 1) {
      // Bounce up
      CGFloat bounceBottom = self.center.y;
      float bounceTop = bounceBottom - bounceHeight;
      [values addObject:[NSNumber numberWithFloat:bounceTop]];
      [timings addObject:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut]];
      // Return to rest
      [values addObject:[NSNumber numberWithFloat: bounceBottom]];
      [timings addObject: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn]];
      // Reduce the height of the bounce by the spring's tension
      bounceHeight *= 0.8;
   }
   animation.values = values;
   animation.timingFunctions = timings;
   [self.layer addAnimation: animation forKey: @"bounce"];
   
}

- (void) setEnabled: (BOOL) enabled {
   if (enabled) {
      self.backgroundColor = self.enabledColor;
   } else {
      [self.layer removeAllAnimations];
      self.backgroundColor = [UIColor grayColor];      
   }
}

- (void) configure {
   [super configure];
   self.cornerRadius = 13.0;
   self.layer.borderWidth = 2.0;
   self.layer.borderColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.3].CGColor;
}

- (void) useDarkBlueBorder {
   self.layer.borderColor = [UIColor colorWithRed:0.023 green:0.039 blue:0.208 alpha:1.000].CGColor;   
}

- (void) useGreenBorder {
   self.layer.borderColor = [UIColor colorWithRed:0.345 green:0.505 blue:0.298 alpha:1.000].CGColor;   
}

- (void) dealloc {
   [self.layer removeAllAnimations];
   [self removeTarget: self action: @selector(click) forControlEvents: UIControlEventTouchUpInside];
   self.enabledColor = nil;
   [super dealloc];
}

@end
