//
//  MintegralAdapterDelegate.h
//  MediationExample
//
//  Copyright © 2017年 Mintegral, Inc. All rights reserved.
//

#import "MintegralAdapterProtocol.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Foundation/Foundation.h>
#import <GoogleMobileAds/Mediation/GADMRewardBasedVideoAdNetworkAdapterProtocol.h>
#import <GoogleMobileAds/Mediation/GADMRewardBasedVideoAdNetworkConnectorProtocol.h>

@protocol GADMAdNetworkAdapter;
@protocol GADMAdNetworkConnector;
@protocol GADMRewardBasedVideoAdNetworkAdapter;
@protocol GADMRewardBasedVideoAdNetworkConnector;

@interface MintegralAdapterDelegate : NSObject


/// Returns a MintegralAdapterDelegate with a reward-based video ad adapter and reward-based video ad
/// connector.
- (instancetype)initWithRewardBasedVideoAdAdapter:(id<GADMRewardBasedVideoAdNetworkAdapter>)adapter
                      rewardBasedVideoAdconnector:
(id<GADMRewardBasedVideoAdNetworkConnector>)connector;

- (instancetype)init NS_UNAVAILABLE;


@end
