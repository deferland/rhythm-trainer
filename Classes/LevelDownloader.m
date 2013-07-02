//
//  LevelDownloader.m
//  Rhythms
//
//  Created by andrew t on 8/29/10.
//  Copyright 2010 ZWorkbench, Inc.. All rights reserved.
//

#import "UpdateChecker.h"
#import "LevelDownloader.h"
#import "ZipArchive.h"
#import "Level.h"
#import "ModelConstants.h"
#import "Stage.h"
#import "Rhythm.h"


#define MSG_ERR_INSTALL @"Sorry. Can't install this pack"
#define MSG_ERR_DOWNLOAD @"Sorry. Can't download  this pack"

static LevelDownloader* inst;

@implementation LevelDownloader

@synthesize curPackName, downloadInProgress, paymentInProgress, paymentSucceeded;

#pragma mark functions that starts the purchase and download transaction
- (void) startDownload:(NSString*) packName
{    
    BOOL success = YES;

    self.curPackName = packName;
    
    self.paymentInProgress = NO;
    self.paymentSucceeded = NO;
    self.downloadInProgress = NO;
    
    //level contents may remain after previous attempts, when user cancelled a transaction
    success = [self installRhythm:packName dryRun:YES];
    if (success == YES)
    {
        NSLog(@"previously downloaded  pack '%@' found on disk. skip downloading, go to payment ", packName);
        [self startPaymentTransaction];
        return;
    }
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[self pathToFile]] ) {
        NSLog(@"Level '%@' has already been downloaded. Skipping downloading.", self.curPackName); 
        
        if ([self unzipLevelPack: [self pathToFile] deleteWhenDone: YES])
        {
            success = [self installRhythm:packName dryRun:YES];
            
            if (success == YES)
            {
                [self startPaymentTransaction];
                return;
            }
            else
                NSLog(@"Failed to install '%@'. Start downloading new", [self fileName]);
        }       
        else
            NSLog(@"Failed to unzip a level '%@'.", [self fileName]);
        
        [[NSFileManager defaultManager] removeItemAtPath:[self pathToFile] error:nil];
    }
    
    [self initWithFileName:[self fileName]];
    [super startDownload];
    self.downloadInProgress = YES;
    [self->delegate downloadStarted];
    
}

#pragma mark NSURLConnection event handlers 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [super connection:connection didReceiveResponse:response];
    NSLog(@"%s",__FUNCTION__);
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );

    
    NSLog(@"response: %@,  response.suggestedFileName:%@, response.statusCode:%d", 
          response, [response suggestedFilename], [httpResponse statusCode]);
    
    int statusCode = [httpResponse statusCode];
    
    if (statusCode == 404)
    {
        self.downloadInProgress = NO;
        //error will be reported to user that "can't install additional stages"
        [self->delegate packDownloadFailed:MSG_ERR_DOWNLOAD]; 
        
        return;
    }
    
    self->total_expected_size = 0;
    if ([response expectedContentLength] ==NSURLResponseUnknownLength)
        NSLog(@"length unknow");
    else
    {
        NSLog(@"expected length: %lld", [response expectedContentLength]);
        self->total_expected_size = [response expectedContentLength];
        self->downloaded_size = 0;
        
    }
    
    // Payment transaction might be start here. 
    // Advantage - totaly it takes shorter time
    // Downside - we can't cancel the transation if downloaded packs contain errors
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [super connection:connection didReceiveData:data];
    
    self->downloaded_size += [data length];
    double val = (double)self->downloaded_size;

        double progressVal = val/self->total_expected_size;
    
    NSLog(@" downloaded %lld \t %f \t %f", self->downloaded_size,val, progressVal);

    
    [self->delegate reportDownloadProgress: progressVal];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [super connection:connection didFailWithError:error];
    NSLog(@"%s",__FUNCTION__);
    self.downloadInProgress = NO;
    [self->delegate packDownloadFailed:MSG_ERR_DOWNLOAD];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   
    BOOL success = NO;
    NSLog(@"%s",__FUNCTION__);
    [super connectionDidFinishLoading:connection];
   
    if (self.downloadInProgress == NO)
    {
        //downloading has been faced with page not found 404 situation.
        //skip all further steps
        return;
    }
    
     self.downloadInProgress = NO;
    
    if ([self.receivedData writeToFile:[self pathToFile] atomically:YES]) 
    {
        if ([self unzipLevelPack: [self pathToFile] deleteWhenDone: YES])
        {
            success = [self installRhythm:self.curPackName dryRun:YES];
        }
        else
        {
            NSLog(@"Failed to unzip a level '%@'", self.curPackName);
            [[NSFileManager defaultManager] removeItemAtPath:[self pathToFile] error:nil];
        }        
    }
    else
        NSLog(@" Failed to write file for level '%@'",self.curPackName);
    
    
    if (success == NO)
    {
        [self->delegate packDownloadFailed:MSG_ERR_INSTALL];
        // TBD cancell payment transaction
    }else {
        [self->delegate packDidDownload];
        
        if (self.paymentInProgress == NO)
        {
            NSLog(@"Downloading finished after payment had been completed");
            //comment next line if you going to start payment transactioin from 'startDownload'            
            [self startPaymentTransaction]; 
        }
        
        if (self.paymentSucceeded == YES)
        {
            NSLog(@"Downloading finished after payment had been SUCCESSFULLY completed");
            BOOL success = [self installRhythm:self.curPackName dryRun:NO];
            if (success == NO)
            {
                [self->delegate packDownloadFailed:MSG_ERR_INSTALL];
            }else {
                [self->delegate packInstalled];
            }
        }
        
    }
    
}


#pragma mark iTunes processing functions 

- (BOOL) startPaymentTransaction{
   
    NSLog(@"%s",__FUNCTION__);
    self.paymentInProgress = YES;
    self.paymentSucceeded = NO;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    SKProduct* product = [[UpdateChecker instance] productDataForName:self.curPackName]; 
    NSString* productID = product.productIdentifier;
    
    if (productID == nil)
        return NO;
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productID];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    [self->delegate paymentStarted];
    
    return YES;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"%s",__FUNCTION__);
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                NSLog(@"unknow payment transaction state");
                break;
        }
    }
}


- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"%s",__FUNCTION__);
    self.paymentInProgress = NO;
    self.paymentSucceeded = YES;
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [self->delegate paymentCompleted];    
    
    if (self.downloadInProgress == NO)
    {
        BOOL success = [self installRhythm:self.curPackName dryRun:NO];
        if (success == NO)
        {
            [self->delegate packDownloadFailed:MSG_ERR_INSTALL];
        }else {
            [self->delegate packInstalled];
        }
    }
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"%s",__FUNCTION__);
  //#  [self recordTransaction: transaction];
   //# [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"%s",__FUNCTION__);
    self.paymentInProgress = NO;
    [self->delegate paymentFailed];
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


#pragma mark stages installment function 

- (BOOL) installRhythm: (NSString*) rhythmName dryRun:(BOOL) dryRun{        
    BOOL res = NO;
    
    NSString *stagePath = [[self defaultDownloadPath] stringByAppendingPathComponent:rhythmName];
        
    if ( [[NSFileManager defaultManager] fileExistsAtPath:stagePath]== NO )
    {
        NSLog(@"Can't find dir '%@'",stagePath);
        return NO;
    }
                           
    NSArray *stages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:stagePath error:NULL];
                           
    for (NSString *levelName in stages)
    {        
        res = [self installStages:rhythmName levelName:levelName dryRun:dryRun];
        if (res == NO)
            return NO;        
    }
    
    if (res == YES)  //mark the rhythm as 'upgraded'
    {
        NSString* condition = [NSString stringWithFormat:@"directory_name == '%@'", rhythmName];
        NSArray* foundRhythms = [Rhythm findByCondition:condition];
        
        if ([foundRhythms count] > 1)
        {
            NSLog(@"More than one '%@' rhythms found while trying to set upgraded flag", rhythmName );
            return NO;
        }
        if ( dryRun == NO)
        {
            Rhythm* rhythm = [foundRhythms objectAtIndex:0];
            if (rhythm != nil)
            {        
                [rhythm setAttributeNamed:kUpgraded value:@"yes"];
                [rhythm save];
            }
            else {
                NSLog(@"can't find rhythm '%@'",rhythmName);
                return NO;
            }
        }
    }
                           
    return YES;
}


- (BOOL) installStages: (NSString*) rhythmName  levelName:(NSString*) levelFullName dryRun:(BOOL) dryRun
{   
    if (dryRun)
        NSLog(@"checking if level %@ can be installed", levelFullName);
    else
        NSLog(@"installing level %@", levelFullName);
    
    NSString* levCondition = [NSString stringWithFormat:@" directory_name = '%@'", levelFullName];
    NSArray* foundLevels = [Level findByCondition:levCondition];
    
    if ([foundLevels count] == 0)
    {
        NSLog(@"level '%@' is not in database. Can't install stages", levelFullName); 
        return NO;
    }

    if ([foundLevels count] > 1)
    {
        NSLog(@"More than one levels '%@' in the database. Can't install stages", levelFullName); 
        return NO;
    }
    Level* level = [foundLevels objectAtIndex:0];
    
    NSString *stagePath = [[[self defaultDownloadPath] stringByAppendingPathComponent:rhythmName]
                                                       stringByAppendingPathComponent:levelFullName];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:stagePath]== NO )
    {
        NSLog(@"Can't find dir '%@'",stagePath);
        return NO;
    }
    
    NSArray *stages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:stagePath error:NULL];
    
    for (NSString *stageFile in stages)
    {
        if (![stageFile hasSuffix:@".gif"])
            continue;
        
            stageFile = [stageFile stringByReplacingOccurrencesOfString:@".gif" withString:@""];
                        
            NSString* stageCondition = [NSString stringWithFormat:@" name = '%@'", stageFile];
            NSArray* foundStages = [Stage findByCondition:stageCondition];
            if ([foundStages count] > 0 )
            {
                NSLog(@"WARNING! Stage '%@' is already in database ", stageFile);
                // put return NO; here if we need to fail on stages that are already exist in database 
            }else if (dryRun == NO)
            {
                NSNumber* downloadFlag = [NSNumber numberWithInt:1];
                Stage *stage = [[Stage alloc] init];
                [stage setAttributeNamed:kName value:stageFile];
                [stage setAttributeNamed:kFileName value:stageFile];
                [stage setAttributeNamed:kDownloaded value:downloadFlag];
                [stage setAttributeNamed:kLevelId value:[NSNumber numberWithInt:[level primaryKey]]];
                [stage save];
                [stage release];
            }
    }   

    return YES;        
}


- (BOOL) unzipLevelPack: (NSString *) fileName deleteWhenDone: (BOOL) deleteWhenDone 
{
    BOOL success = NO;
    ZipArchive *zip = [[ZipArchive alloc] init];
    if ([zip UnzipOpenFile: fileName]) {
        success = [zip UnzipFileTo: [self defaultDownloadPath] overWrite: YES];
        [zip UnzipCloseFile];
    }
    [zip release];
    if (deleteWhenDone) {
        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtPath: fileName error: &deleteError];
        // Ignore the error, we're just trying to save space here.
    }
    return success;
}


#pragma mark path functions 

- (NSString*) fileName
{
    return [NSString stringWithFormat:@"%@.zip", self.curPackName];
}

- (NSString*) pathToFile
{
    NSString* path = [self defaultDownloadPath];
    return [path stringByAppendingPathComponent: [self fileName]];
}             

- (NSString*) defaultDownloadPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return path;
}

#pragma mark Lifecycle

+ (LevelDownloader*) instance
{
    if (inst == nil)
    {
        inst = [[LevelDownloader alloc] init];
    }
    return inst;
}

+ (void) release_instance
{
    if( inst != nil)
    {
        [inst release];
        inst = nil;
    }
}


- (void) setDelegate: (id) delegate_
{
    if (self->delegate != nil)
        [ self->delegate release];
    
    self->delegate = delegate_;
    
    [self->delegate retain];
    
}


- (void) dealloc
{
    [self->delegate release];
    [super dealloc];
}


@end
