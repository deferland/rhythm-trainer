//
//  AboutController.m
//  Rhythms
//
//  Created by Julio Barros on 7/29/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "AboutController.h"


@implementation AboutController

-(void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:filePath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[(UIWebView *)self.view loadRequest:request]; 
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	if (navigationType ==   UIWebViewNavigationTypeLinkClicked){
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	} 
	return YES;
}


-(IBAction) goBack:(id) sender{
	[self.navigationController popViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [super dealloc];
}


@end
