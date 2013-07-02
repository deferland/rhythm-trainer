#import <Foundation/Foundation.h>

@interface Downloader : NSObject {
    NSString* urlString;
    NSMutableData *receivedData;
    NSURLConnection *currentConnection;
}

- (Downloader*) initWithFileName: (NSString*)fileToDownload ;
- (void) startDownload;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *currentConnection;
@property (nonatomic, retain) NSString* urlString;

@end
