//
//  LevelSelectionController.m
//  Levels
//
//  Created by Julio Barros on 7/30/08.
//  Updated by Andrew Tverdohlebov on 09/01/10  Added functionality for buying additional stages
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>
#import "LevelSelectionController.h"
#import "ScoreModeController.h"
#import "Level.h"
#import "LevelTableCell.h"
#import "LevelResult.h"
#import "Stage.h"
#import "User.h"
#import "ModelConstants.h"
#import "LevelResult.h"
#import "UpdateChecker.h"
#import "PackDownloader.h"

#define TAG_SUCCESS_ALERT   1
#define TAG_BUY_ALERT       2
#define TAG_FAILED_ALERT    3


@implementation LevelSelectionController
@synthesize levels, selectedPath, levelToUpdate, downloadInProgressView;

- (NSInteger) tableView:(UITableView *) table numberOfRowsInSection:(NSInteger) section {
	return levels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath{
	LevelTableCell *cell = nil;

   NSArray *cellTest = [[NSBundle mainBundle] loadNibNamed:@"LevelTableCell" owner:self options:nil]; 	
   id firstObj = [cellTest objectAtIndex:0];
   if ( [firstObj isKindOfClass:[UITableViewCell class]] ) {
      cell = [cellTest objectAtIndex:0];      
   } else {
      cell = [cellTest objectAtIndex:1];      
   }
	
	Level *level = [levels objectAtIndex: indexPath.row];

	RhythmEngine *rhythmEngine = [self getRhythmEngine];
	
	NSArray *levelResults = [LevelResult findByCondition:@"user_id = ? and rhythm_id= ? and level_id = ?",
							 [NSNumber numberWithInt:[rhythmEngine.user primaryKey]],
							 [NSNumber numberWithInt:[rhythmEngine.rhythm primaryKey]],
							 [NSNumber numberWithInt:[level primaryKey]]];
	
	NSLog(@"For user_id = %@ and rhythm_id= %@ and level_id = %@ levelResults=%@",
							 [NSNumber numberWithInt:[rhythmEngine.user primaryKey]],
							 [NSNumber numberWithInt:[rhythmEngine.rhythm primaryKey]],
							 [NSNumber numberWithInt:[level primaryKey]],
		  levelResults);
	if ([levelResults count] > 0){
		LevelResult *levelResult = [levelResults objectAtIndex:0];
		cell.accuracy.text = [NSString stringWithFormat:@"%.0f\%%",[[levelResult getAttributeNamed:kAccuracy] floatValue] * 100];
	} else {
		cell.accuracy.text = @"";
	}
    
    //counting stages
    NSString* condition = [NSString stringWithFormat:@" level_id = %d", [level primaryKey]];
    NSArray* stages = [Stage findByCondition:condition];
    NSInteger count = [stages count];
    NSString* stagesNum = nil;
    
    if (count == 1)
        stagesNum = @"1 stage";
    else    
        stagesNum = [NSString stringWithFormat:@"%d stages", count];
    
    cell.stagesNum.text = stagesNum;
    
	NSString *descriptionImage = [NSString stringWithFormat:@"%@_%@.png",[[rhythmEngine rhythm] getAttributeNamed:kDirectoryName],[level name]];
	cell.description.image = [UIImage imageNamed:descriptionImage];
	
	NSString *name = [level getAttributeNamed:kName];
	cell.name.text =  [NSString stringWithFormat:@"Level %@",name];
   
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	self.selectedPath = indexPath;
	Level *selectedLevel = [levels objectAtIndex:indexPath.row];
	[[self getRhythmEngine] setLevel: selectedLevel];
	
   ScoreModeController *scoreModeController = [[[ScoreModeController alloc] initWithNibName:@"ScoreMode" bundle:nil] autorelease];      
	
	[self.navigationController pushViewController:scoreModeController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* res = nil;
    Rhythm* rhythm = [self getRhythmEngine].rhythm;
    [rhythm refresh];
    NSString* rhythmName = [rhythm getAttributeNamed:kDirectoryName];
    
    SKProduct* productData = [[UpdateChecker instance] productDataForName:rhythmName];
    if (productData != nil)        
    {
        //checking if pack has already been downloaded
        if ( [[rhythm getAttributeNamed:kUpgraded] isEqual:@"no" ] )
        {          
            res = self->headerView;
            self->productPrice.text = [productData.price stringValue];
            self->productDescription.text = productData.localizedDescription;
            self->productDescription.lineBreakMode = UILineBreakModeWordWrap;
            self->productDescription.numberOfLines = 0;
            
            // calculate hieght
            CGSize maximumLabelSize = CGSizeMake(296,100);            
            CGSize expectedLabelSize = [self->productDescription.text sizeWithFont: productDescription.font 
                                                                 constrainedToSize:maximumLabelSize 
                                                                     lineBreakMode:productDescription.lineBreakMode];
            CGRect newFrame = self->productDescription.frame;
            
            if (expectedLabelSize.height < 40.0)
                expectedLabelSize.height = 40;
            
            newFrame.size.height = expectedLabelSize.height;
            self->productDescription.frame = newFrame;            
            
            NSLog(@" expected height %f", expectedLabelSize.height);            
            
            CGRect viewBounds = headerView.bounds;
            
            viewBounds.size.height= expectedLabelSize.height+5;
            
            headerView.bounds = viewBounds;
            
        }
    }
    
    return res;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    NSLog(@" %s ", __FUNCTION__);

    return self->headerView.frame.size.height;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Available Levels";
    
    self->progressView = nil;
    self->activityView = nil;
    self->progressAlert = nil;
}

-(void) viewDidAppear:(BOOL)animated {
   if (self.selectedPath) {
      [levelsTable deselectRowAtIndexPath: self.selectedPath animated:YES];      
   }
	[super viewDidAppear:animated];
}

NSInteger alphaSort(id r1, id r2, void *reverse){
	NSString *string1 = (NSString*) [r1 getAttributeNamed:kName];
	NSString *string2 = (NSString*) [r2 getAttributeNamed:kName];
	
    if ((NSInteger *)reverse == NO) {
        return [string2 localizedCaseInsensitiveCompare:string1];
    }
    return [string1 localizedCaseInsensitiveCompare:string2];	
}

NSInteger numericSort(id r1, id r2, void *reverse){
	NSNumber *num1 = [NSNumber numberWithInt:[[r1 getAttributeNamed:kName] intValue]];
	NSNumber *num2 = [NSNumber numberWithInt:[[r2 getAttributeNamed:kName] intValue]];
	
    if ((NSInteger *)reverse == NO) {
        return [num2 compare:num1];
    }
    return [num1 compare:num2];	
}


- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	RhythmEngine *rhythmEngine = [self getRhythmEngine];
	username.text = [rhythmEngine.user getAttributeNamed:kUserName];
	Rhythm *rhythm = [self getRhythmEngine].rhythm;
	timeSignatureLabel.text = [rhythm getAttributeNamed:kName];
	NSNumber *rpk = [NSNumber numberWithInt: [rhythm primaryKey]];
	self.levels = [Level findByCondition:@"rhythm_id = ?",rpk];
	int reverseSort = NO;
	self.levels = [levels sortedArrayUsingFunction:numericSort context:&reverseSort];
	for (Level *level in levels){
		level.rhythm = rhythm;
		[level loadAllStages];
	}
	[levelsTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark buyBtnPressed

-(IBAction) buyBtnPressed:(id) sender
{        
    if ([sender isKindOfClass: [ClickButton class]])
    {
        ClickButton* btn = sender;
        NSLog(@"%s  btn %d",__FUNCTION__, btn.tag );
        
        [self showBuyAlert:@"Would you like to buy new stages ?"];

    }else
        NSLog(@"bad luck");
}


#pragma mark download process callbacks

- (void) downloadStarted {
    [self createProgressionAlertWithMessage:@"Downloading" withActivity: NO];
}

- (void) packDidDownload {
    NSLog(@"packDidDownload");
 
    [self->progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self->progressAlert release];
    self->progressAlert = nil;
    
    PackDownloader* downloader = [PackDownloader instance];
    if (downloader.paymentInProgress == YES){
        [self createProgressionAlertWithMessage:@"Processing payment transaction" withActivity: YES];       
    }    
    
} 

- (void) packDownloadFailed:(NSString*) msg
{
    [self showDownloadFailedAlert:msg];
    [self->progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self->progressAlert release];
    self->progressAlert = nil;
}

- (void) reportDownloadProgress: (double) progressVal
{
    NSLog(@"progress: %f", progressVal);
    self->progressView.progress = progressVal;
}

- (void) packInstalled{
    [self viewWillAppear:YES];    
}


#pragma mark payment callbacks 

- (void) paymentStarted{
    PackDownloader* downloader = [PackDownloader instance];
    if (downloader.downloadInProgress == NO){
        [self createProgressionAlertWithMessage:@"Processing payment transaction" withActivity: YES];       
    }
    
}

- (void) paymentCompleted{
    PackDownloader* downloader = [PackDownloader instance];
    if (downloader.downloadInProgress == NO){
        [self->progressAlert dismissWithClickedButtonIndex:0 animated:YES];
        [self->progressAlert release];
        self->progressAlert = nil;
        
        [self viewWillAppear:YES];
    }
}

- (void) paymentFailed{
    PackDownloader* downloader = [PackDownloader instance];
    if (downloader.downloadInProgress == NO){
        [self->progressAlert dismissWithClickedButtonIndex:0 animated:YES];
        [self->progressAlert release];
        self->progressAlert = nil;
        
        //probably display notice
    }    
}



#pragma mark alert windows functions


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(alertView.tag == TAG_BUY_ALERT)  // 'BuyAlert' tag
    {
        // second button pressed (yes)
		if (buttonIndex == 1){
            Rhythm* rhythm = [self getRhythmEngine].rhythm;
            NSString* rhythmName = [rhythm getAttributeNamed:kDirectoryName];
            
            
            [[PackDownloader instance] setDelegate:self];
            [[PackDownloader instance] startDownload:rhythmName];
		}
        else if (buttonIndex == 0){
            NSLog(@"~~button index 0 pressed !!!");
        }
        
	}
    else if(alertView.tag == TAG_SUCCESS_ALERT){
        if (buttonIndex == 0){
            NSLog(@"~~button index 0 pressed !!!");
            [self viewWillAppear:YES];      // making Levels list reload
        }        
    }    
}


- (void) createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity
{
    self->progressAlert = [[UIAlertView alloc] initWithTitle: message
                                               message: @"Please wait..."
                                              delegate: self
                                     cancelButtonTitle: nil
                                     otherButtonTitles: nil];
    
    
    // Create the progress bar and add it to the alert
    if (activity) {
        self->activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self->activityView.frame = CGRectMake(139.0f-18.0f, 93.0f, 37.0f, 37.0f);
        [self->progressAlert addSubview:self->activityView];
        [self->activityView startAnimating];
    } else {
        self->progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
        [self->progressAlert addSubview:self->progressView];
        [self->progressView setProgressViewStyle: UIProgressViewStyleBar];
    }
    [self->progressAlert  show];    
}

- (void) closeProgressingAlertWindow{
    [self->progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self->progressView release];
    [self->activityView release];
    [self->progressAlert release];
    
    self->progressView = nil;
    self->activityView = nil;
    self->progressAlert = nil;
}

- (void) showBuyAlert:(NSString*) msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:@""
                                                   delegate:self  cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = TAG_BUY_ALERT;
    [alert show];
    [alert release];
}

- (void) showDownloadSucceededAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New stages have been successfully downloaded" message:@""
                                                   delegate:self  cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    alert.tag = TAG_SUCCESS_ALERT;
    [alert show];
    [alert release];
}    


- (void) showDownloadFailedAlert:(NSString*) msg{
    if (msg == nil)
        msg = @"Sorry can't download";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:@""
                                                   delegate:nil  cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    alert.tag = TAG_FAILED_ALERT;
    [alert show];
    [alert release];
}    

#pragma mark lifecycle

- (void)dealloc {
    NSLog(@"LevelSelectionController dealloc");
    [self->progressView release];
    [self->activityView release];
    [self->progressAlert release];

    self->progressView = nil;
    self->activityView = nil;
    self->progressAlert = nil;

    self.levels = nil;
    self.selectedPath = nil;
    [super dealloc];
}


@end
