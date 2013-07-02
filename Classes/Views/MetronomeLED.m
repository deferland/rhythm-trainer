//
//  MetronomeLED.m
//  Rhythms
//
//  Created by Julio Barros on 12/1/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "MetronomeLED.h"


@implementation MetronomeLED


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

-(void) on:(BOOL) turnOn{
	if (turnOn)
		[self setBackgroundColor:[UIColor redColor]];
	else
		[self setBackgroundColor:[UIColor whiteColor]];
}


- (void)dealloc {
    [super dealloc];
}


@end
