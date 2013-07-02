//
//  InstructionsController.m
//  Rhythms
//
//  Created by Julio Barros on 7/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "InstructionsController.h"


@implementation InstructionsController


-(void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"instructions" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:filePath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[(UIWebView *)self.view loadRequest:request]; 
}


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
