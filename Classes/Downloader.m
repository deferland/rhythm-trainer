//
//  Downloader.m
//  Rhythms
//
//  Created by andrew t on 8/3/10.
//  Based on levelPackDownloader by Christopher Garrett.
//

#import "Downloader.h"

#import "ZipArchive.h"
#import "ModelConstants.h"


#define APP_VERSION "ver1"

#define DOWNLOAD_URL @"http://rhythm1.heroku.com/"

@implementation Downloader

@synthesize receivedData, currentConnection, urlString;


- (Downloader*) initWithFileName: (NSString*)fileToDownload
{    
    NSString* tempStr = DOWNLOAD_URL;    
    NSString* tempStr2 = [tempStr stringByAppendingString:fileToDownload];
    
    self.urlString = [tempStr2 stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];

    return self;        
}

- (void) startDownload {
    self.receivedData = nil;
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString: self.urlString]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
    self.currentConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
    if (self.currentConnection) {
        self.receivedData=[NSMutableData data];
    }   
}


#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.currentConnection = nil;
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@  urlString:%@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey],
          self.urlString);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data", [self.receivedData length]);
    self.currentConnection = nil;
}



- (void) dealloc {
    self.receivedData = nil;       
    self.currentConnection = nil;
    self.urlString = nil;
    [super dealloc];
}

@end
