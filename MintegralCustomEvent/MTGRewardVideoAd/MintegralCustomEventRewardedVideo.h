//
//  MintegralCustomEventRewardedVideo.h
//  MediationExample
//
//  Copyright © 2017年 Mintegral, Inc. All rights reserved.
//


#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Foundation/Foundation.h>

#import "MintegralAdapterProtocol.h"


@interface MintegralCustomEventRewardedVideo : NSObject<GADMRewardBasedVideoAdNetworkAdapter,MintegralAdapterDataProvider>


- (BOOL)hasAdAvailable;


@end
