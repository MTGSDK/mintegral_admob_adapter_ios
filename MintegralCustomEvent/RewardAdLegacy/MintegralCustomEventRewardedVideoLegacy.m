//
//  MintegralCustomEventRewardedVideo.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral, Inc. All rights reserved.
//

#import "MintegralCustomEventRewardedVideoLegacy.h"
#import "MintegralAdapterDelegate.h"
#import "MintegralAdNetworkExtras.h"
#import "MintegralHelper.h"

#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>


@interface MintegralCustomEventRewardedVideoLegacy () {
    /// Connector from Google Mobile Ads SDK to receive ad configurations.
    __weak id<GADMAdNetworkConnector> _connector;
    
    /// Connector from Google Mobile Ads SDK to receive reward-based video ad configurations.
    __weak id<GADMRewardBasedVideoAdNetworkConnector> _rewardBasedVideoAdConnector;
    
    /// Handles delegate notifications.
    MintegralAdapterDelegate *_adapterDelegate;

    
    /// Handle reward-based video ads from SDK.
    MTGRewardAdManager *_rewardBasedVideoAd;

}

@property(nonatomic,copy)NSString *localAppId;
@property(nonatomic,copy)NSString *localAppKey;
@property(nonatomic,copy)NSString *localAdUnit;
@property(nonatomic,copy)NSString *rewardId;
@property(nonatomic,copy)NSString *userId;

@end

@implementation MintegralCustomEventRewardedVideoLegacy

+ (NSString *)adapterVersion {
    return MintegralAdapterVersion;
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    // OPTIONAL: Create your own class implementing GADAdNetworkExtras and return that class type
    // here for your publishers to use. This class does not use extras.
    
    return [MintegralAdNetworkExtras class];
}



#pragma mark Reward-based Video Ad Methods

/// Initializes and returns a adapter with a reward based video ad connector.
- (instancetype)initWithRewardBasedVideoAdNetworkConnector:
(id<GADMRewardBasedVideoAdNetworkConnector>)connector {
    if (!connector) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _rewardBasedVideoAdConnector = connector;
        _adapterDelegate = [[MintegralAdapterDelegate alloc] initWithRewardBasedVideoAdAdapter:self
                                                                rewardBasedVideoAdconnector:connector];
    }
    return self;
}

/// Tells the adapter to set up reward based video ads. When set up fails, the SDK may try to
/// set up the adapter again.
- (void)setUp {

    NSString *parameter = [_rewardBasedVideoAdConnector credentials][@"parameter"];
    
    NSDictionary *mintegralInfoDict = [MintegralHelper dictionaryWithJsonString:parameter];

    if ([mintegralInfoDict objectForKey:@"appId"]) {
        _localAppId = [mintegralInfoDict objectForKey:@"appId"];
    }
    
    if ([mintegralInfoDict objectForKey:@"appKey"]) {
        _localAppKey = [mintegralInfoDict objectForKey:@"appKey"];
    }

    if ([mintegralInfoDict objectForKey:@"unitId"]) {
        _localAdUnit = [mintegralInfoDict objectForKey:@"unitId"];
    }
    
    if ([mintegralInfoDict objectForKey:@"rewardId"]) {
        _rewardId = [mintegralInfoDict objectForKey:@"rewardId"];
    }

    id<GADMRewardBasedVideoAdNetworkConnector> strongConnector = _rewardBasedVideoAdConnector;
    if (!_localAppId || !_localAppKey || !_localAdUnit) {


        NSError *error = [NSError errorWithDomain:kMintegralAdapterErrorDomain code:kGADErrorInvalidArgument userInfo:@{NSLocalizedDescriptionKey: @"Mintegral SDK init failed for the invalid Aragument"}];

        [strongConnector adapter:self didFailToSetUpRewardBasedVideoAdWithError:error];
        return;
    }
    
    NSString *consentGDPR = [mintegralInfoDict objectForKey:@"consent"];
    if ([consentGDPR isEqualToString:@"0"] ) {
        [MintegralHelper consentGDPR:NO];
    }

    if ([consentGDPR isEqualToString:@"1"] ) {
        [MintegralHelper consentGDPR:YES];
    }

    if (![MintegralHelper isSDKInitialized]) {
        
        //init SDK
        [[MTGSDK sharedInstance] setAppID:_localAppId ApiKey:_localAppKey];
        [MintegralHelper sdkInitialized];
    }

    _rewardBasedVideoAd = [MTGRewardAdManager sharedInstance];

    [strongConnector adapterDidSetUpRewardBasedVideoAd:self];
}

/// Tells the adapter to request a reward based video ad, if checkAdAvailability is true. Otherwise,
/// the connector notifies the adapter that the reward based video ad failed to load.
- (void)requestRewardBasedVideoAd {

    [_rewardBasedVideoAd loadVideo:_localAdUnit delegate:(id<MTGRewardAdLoadDelegate>)_adapterDelegate];
}



/// Tells the adapter to present the reward based video ad with the provided view controller, if the
/// ad is available. Otherwise, logs a message with the reason for failure.
- (void)presentRewardBasedVideoAdWithRootViewController:(UIViewController *)viewController {

    MintegralAdNetworkExtras *extras = [_rewardBasedVideoAdConnector networkExtras];
    NSString *userId = extras.userId;
    
    if ([_rewardBasedVideoAd isVideoReadyToPlay:_localAdUnit]) {
        // The reward based video ad is available, present the ad.
        [_rewardBasedVideoAd showVideo:_localAdUnit withRewardId:_rewardId userId:userId delegate:(id<MTGRewardAdShowDelegate>)_adapterDelegate viewController:viewController];
    } else {
        // Because publishers are expected to check that an ad is available before trying to show one,
        // the above conditional should always hold true. If for any reason the adapter is not ready to
        // present an ad, however, it should log an error with reason for failure.
        NSLog(@"No ads to show ...  log from MobvsitaAdapter");
    }
}


- (BOOL)hasAdAvailable
{
    return [_rewardBasedVideoAd isVideoReadyToPlay:_localAdUnit];
}



/// Tells the adapter to remove itself as a delegate or notification observer from the underlying ad
/// network SDK.
- (void)stopBeingDelegate{
    
}


@end
