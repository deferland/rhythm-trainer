//
//  LevelTableHeader.m
//  Rhythms
//
//  Created by atverd on 09.09.10.
//  Copyright 2010 ZWorkbench, Inc.. All rights reserved.
//

#import "LevelTableHeader.h"


@implementation LevelTableHeader

- (void) drawRect:(CGRect)rect {
    NSLog(@"%s",__FUNCTION__);
        
    CGContextRef ctx = UIGraphicsGetCurrentContext();     
    
    self.alpha = 1.0;
    
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 2.0);
    CGContextSetLineWidth(ctx, 0.2);
    
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height-1);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height-1);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };    
    
    CGFloat components[8] =  {0.5, 0.5, 0.4, 0.5,
                              1.0, 1.0, 1.0, 1.0};
    
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    
    CGPoint myStartPoint, myEndPoint;
    myStartPoint.x = 0.0;
    myStartPoint.y = 0.0;
    myEndPoint.x = 0.0;
    myEndPoint.y = self.bounds.size.height;//1.0;
    CGContextDrawLinearGradient (ctx, myGradient, myStartPoint, myEndPoint, 0);
    
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    
    CGContextDrawPath(ctx, kCGPathStroke);    
     
    [super drawRect:rect];
}

@end
