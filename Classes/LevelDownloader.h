//
//  LevelDownloader.h
//  Rhythms
//
//  Created by andrew t on 8/29/10.
//  Copyright 2010 ZWorkbench, Inc.. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import "Downloader.h"


@protocol DownloadEventHandler


- (void) downloadStarted;
- (void) packDidDownload;
- (void) packDownloadFailed:(NSString*) msg;
- (void) reportDownloadProgress: (double) progressVal;
- (void) packInstalled;

#pragma mark payment events handlers  

- (void) paymentStarted;
- (void) paymentCompleted;
- (void) paymentFailed;

@end


@interface LevelDownloader : Downloader <SKPaymentTransactionObserver> {

    NSString* curPackName;
    long long total_expected_size;
    long long  downloaded_size;
    id delegate;
    BOOL paymentSucceeded;
    BOOL paymentInProgress;
    BOOL downloadInProgress;
}    

@property (nonatomic,retain) NSString* curPackName;
@property (nonatomic) BOOL paymentInProgress;
@property (nonatomic) BOOL paymentSucceeded;
@property (nonatomic) BOOL downloadInProgress;


#pragma mark functions that starts the purchase and download transaction

- (void) startDownload:(NSString*) packName;

#pragma mark NSURLConnection event handlers 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

#pragma mark iTunes processing functions 

- (BOOL) startPaymentTransaction;
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;


#pragma mark stages installment function 
- (BOOL) installRhythm: (NSString*) rhythmName dryRun:(BOOL) dryRun;
- (BOOL) installStages: (NSString*) rhythmName  levelName:(NSString*) levelFullName dryRun:(BOOL) dryRun;
- (BOOL) unzipLevelPack: (NSString *) fileName deleteWhenDone: (BOOL) deleteWhenDone;

#pragma mark path functions 

- (NSString*) fileName;
- (NSString*) pathToFile;
- (NSString*) defaultDownloadPath;

#pragma mark Lifecycle

+ (LevelDownloader*) instance;
+ (void) release_instance;
- (void) setDelegate: (id) delegate_;

@end
