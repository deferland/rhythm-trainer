//
//  LevelSelectionController.h
//  Rhythms
//
//  Created by Julio Barros on 7/30/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RhythmBaseController.h"
#import "PackDownloader.h"
#import "ClickButton.h"
#import "LevelTableHeader.h"

@class ScoreModeController;

@interface LevelSelectionController : RhythmBaseController <DownloadEventHandler> {
	IBOutlet UITableView *levelsTable;
	IBOutlet UILabel *username;
	IBOutlet UILabel *timeSignatureLabel;
    IBOutlet LevelTableHeader *headerView;
    IBOutlet ClickButton *buyBtn;
    IBOutlet UILabel *productDescription;
    IBOutlet UILabel *productPrice;


    UIProgressView* progressView;    
    UIActivityIndicatorView* activityView;
    UIAlertView* progressAlert;
    
	NSArray *levels;
	
	NSIndexPath *selectedPath;
}

@property (nonatomic, retain) NSString* levelToUpdate;
@property (nonatomic, retain) NSArray *levels;
@property (nonatomic, retain) NSIndexPath *selectedPath;

@property (nonatomic, retain) UIView *downloadInProgressView;

-(IBAction) buyBtnPressed:(id) sender;

- (void) createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity;
- (void) closeProgressingAlertWindow;
- (void) showBuyAlert:(NSString*) msg;
- (void) showDownloadSucceededAlert;
- (void) showDownloadFailedAlert:(NSString*) msg;



@end
