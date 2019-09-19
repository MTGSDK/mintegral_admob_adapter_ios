//
//  MintegralAdNetworkExtras.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralAdNetworkExtras.h"


@implementation MintegralAdNetworkExtras

- (id<GADAdNetworkExtras>)adNetworkExtrasWithDictionary:(NSDictionary<NSString *, NSString *> *)extras{

    MintegralAdNetworkExtras *extra = [[MintegralAdNetworkExtras alloc] init];

    if ([extras objectForKey:@"userId"]) {
        extra.userId = [extras objectForKey:@"userId"];
    }
    return extra;
}

@end
