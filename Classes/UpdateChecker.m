//
//  UpdateChecker.m
//  Rhythms
//
//  Created by andrew t on 8/28/10.
//  Copyright 2010 ZWorkbench, Inc.. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "UpdateChecker.h"


#define PLIST_NAME @"new-levels.plist"

static UpdateChecker* inst;


@implementation UpdateChecker

- (UpdateChecker*) init
{
    if (self = [super init])
    {
        [super initWithFileName:PLIST_NAME];
        self->productIds = [[NSDictionary alloc] init];
        self->productData = [[NSMutableDictionary alloc] init];
        
        return self;
    }
    return nil;
}

- (void) startCheck
{  
    [super startDownload];
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
    NSLog(@" %s ", __FUNCTION__);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@" %s ", __FUNCTION__); 
    [super connectionDidFinishLoading:connection];
    
    NSString *errorMessage;
    [self->productIds release];
    
    self->productIds = (NSDictionary *)[NSPropertyListSerialization
                                            propertyListFromData: self.receivedData
                                            mutabilityOption: NSPropertyListImmutable
                                            format: nil
                                            errorDescription: &errorMessage];
    if (errorMessage) {
        NSLog(@"Error decoding dictionary: %@", errorMessage);
        NSLog(@"XML content:");
        NSLog(@"%@", [[[NSString alloc] initWithData: self.receivedData encoding: NSUTF8StringEncoding] autorelease]);
        [errorMessage release]; // nonstandard release, per docs for NSPropertyListSerialization
        return;
    } 
    
    NSLog(@"raw data from plist xml: %@ ", self->productIds);
    
    [self->productIds retain];
    [self requestProductData];
}    


#pragma mark Product Data request methods 

- (void) requestProductData{
    if ([SKPaymentQueue canMakePayments])
    {
        NSEnumerator* enumerator = [self->productIds objectEnumerator];
        NSMutableSet* productIdSet = [[[NSMutableSet alloc] init] autorelease];
        
        // create a set of product identifiers
        for (NSString* productID in enumerator)
            [productIdSet addObject:productID];
        
        NSLog(@"UpdateChecker: ---productIdSet---\n%@\n---", productIdSet);    
        
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: productIdSet];        
        
        request.delegate = self;
        [request start];
    }
    else 
    {
        NSLog(@"can't make in app purchase");
    }    
    //No leak here: request is released in productRequest: didReceiveResponse:
}

- (SKProduct*) productDataForName:(NSString *)name
{
    return [self->productData objectForKey:name];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
   if ([response.invalidProductIdentifiers count] > 0) {
      NSLog(@"Invalid products! %@", response.invalidProductIdentifiers);
   }
    NSLog(@"%s",__FUNCTION__);
    
    [self->productData removeAllObjects];
    
    NSMutableDictionary* idToNameIndex = [[[NSMutableDictionary alloc] init] autorelease];
    NSEnumerator* enumer = [self->productIds keyEnumerator];
        
    for (NSString* levelName in enumer) {
        NSLog(@" > %@", levelName);
        NSString* productId = [self->productIds objectForKey:levelName];
        [idToNameIndex setObject: levelName forKey: productId];
    }
    
    NSLog(@"---idToNameIndex---\n%@\n----",idToNameIndex);
    
     
    for (SKProduct* product in response.products) {
        NSString* level = [idToNameIndex objectForKey:product.productIdentifier];
        [self->productData setObject:product forKey:level];        
    }
    
    NSLog(@"--products--\n%@ \n -----",self->productData);
    [request autorelease];
    
}

#pragma mark Lifecycle

+ (UpdateChecker*) instance
{
    if (inst == nil)
    {
        inst = [[UpdateChecker alloc] init];
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

- (void) dealloc{
    [self->productIds release];
    [self->productData release];
    [super dealloc];
}

@end
