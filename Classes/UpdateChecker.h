//
//  UpdateChecker.h
//  UpdateChecker downloads 'new-levels.plist' file from the update site.  Builds the list of packs that can be purchased,
//  Requests product information for each pack from iTunes store
//
//  Created by andrew t on 8/28/10.
//  Copyright 2010 ZWorkbench, Inc.. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import "Downloader.h"
#import "ActiveRecord.h"


@interface UpdateChecker : Downloader <SKProductsRequestDelegate> {
@public
    NSDictionary *productIds;  //key - level or rhythm name. e.g. '2-4_level_3' or '2-4' object - string with apple product ID
    NSMutableDictionary *productData;  //key - level or rhythm name. e.g. '2-4_level_3' or '2-4' 
                                       //object - SKProductData 
}

- (void) startCheck;
- (void) requestProductData;
- (UpdateChecker*) init;

- (SKProduct*) productDataForName: (NSString*) name;

+ (UpdateChecker*) instance;
+ (void) release_instance;

@end
