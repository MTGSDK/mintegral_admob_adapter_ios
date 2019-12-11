//
//  MintegralAdapterDelegate.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral, Inc. All rights reserved.
//

#import "MintegralAdapterDelegate.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>
#import "MintegralHelper.h"
#import "MintegralCustomEventRewardedVideoLegacy.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

#define TIMERDURATION 3.0
#define SUMTIME 10.0

static int secondCount = 0;


@interface MintegralAdapterDelegate ()<MTGRewardAdLoadDelegate,MTGRewardAdShowDelegate> {
    /// Connector from Google AdMob SDK to receive ad configurations.
    __weak id<GADMAdNetworkConnector> _connector;
    
    /// Adapter for receiving notification of ad request.
    __weak id<GADMAdNetworkAdapter> _adapter;
    
    /// Connector from Google Mobile Ads SDK to receive reward-based video ad configurations.
    __weak id<GADMRewardBasedVideoAdNetworkConnector> _rewardBasedVideoAdConnector;
    
    /// Adapter for receiving notification of reward-based video ad request.
    __weak id<GADMRewardBasedVideoAdNetworkAdapter> _rewardBasedVideoAdAdapter;
    
    
    __strong NSTimer  *_queryTimer;

}

@end


@implementation MintegralAdapterDelegate

- (instancetype)initWithRewardBasedVideoAdAdapter:(id<GADMRewardBasedVideoAdNetworkAdapter>)adapter
                      rewardBasedVideoAdconnector:
(id<GADMRewardBasedVideoAdNetworkConnector>)connector {
    self = [super init];
    if (self) {
        _rewardBasedVideoAdConnector = connector;
        _rewardBasedVideoAdAdapter = adapter;
    }
    return self;
}



#pragma mark - MVRewardAdManagerDelegate

//MVRewardAdLoadDelegate
- (void)onVideoAdLoadSuccess:(nullable NSString *)unitId{
    
    id<GADMRewardBasedVideoAdNetworkConnector> strongConnector = _rewardBasedVideoAdConnector;
    id<GADMRewardBasedVideoAdNetworkAdapter> strongAdapter = _rewardBasedVideoAdAdapter;
    
    MintegralCustomEventRewardedVideoLegacy *adapter = (MintegralCustomEventRewardedVideoLegacy *)strongAdapter;
    
    if ([adapter hasAdAvailable]) {
        [strongConnector adapterDidReceiveRewardBasedVideoAd:strongAdapter];
        
        [self stopTimer];
    }else{
        [self fireTimer];
    }
}

- (void)onVideoAdLoadFailed:(nullable NSString *)unitId error:(nonnull NSError *)error{
    
    id<GADMRewardBasedVideoAdNetworkConnector> strongConnector = _rewardBasedVideoAdConnector;
    id<GADMRewardBasedVideoAdNetworkAdapter> strongAdapter = _rewardBasedVideoAdAdapter;
    NSError *adapterError = [NSError errorWithDomain:kMintegralAdapterErrorDomain code:error.code userInfo:error.userInfo];
    [strongConnector adapter:strongAdapter didFailToLoadRewardBasedVideoAdwithError:adapterError];
}

//MVRewardAdShowDelegate
- (void)onVideoAdShowSuccess:(nullable NSString *)unitId{
    
    id<GADMRewardBasedVideoAdNetworkConnector> strongConnector = _rewardBasedVideoAdConnector;
    id<GADMRewardBasedVideoAdNetworkAdapter> strongAdapter = _rewardBasedVideoAdAdapter;
    
    [strongConnector adapterDidOpenRewardBasedVideoAd:strongAdapter];
    [strongConnector adapterDidStartPlayingRewardBasedVideoAd:strongAdapter];

}
- (void)onVideoAdShowFailed:(nullable NSString *)unitId withError:(nonnull NSError *)error{

}

- (void)onVideoAdClicked:(nullable NSString *)unitId{
    
    id<GADMRewardBasedVideoAdNetworkConnector> strongConnector = _rewardBasedVideoAdConnector;
    id<GADMRewardBasedVideoAdNetworkAdapter> strongAdapter = _rewardBasedVideoAdAdapter;
    [strongConnector adapterDidGetAdClick:strongAdapter];

}

- (void)onVideoAdDismissed:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(nullable MTGRewardAdInfo *)rewardInfo{
    
    id<GADMRewardBasedVideoAdNetworkConnector> strongConnector = _rewardBasedVideoAdConnector;
    id<GADMRewardBasedVideoAdNetworkAdapter> strongAdapter = _rewardBasedVideoAdAdapter;
    
    if (!converted || !rewardInfo) {
        [strongConnector adapterDidCloseRewardBasedVideoAd:strongAdapter];
        return;
    }
    
    NSNumber *rewardNumber = [NSNumber numberWithInteger:rewardInfo.rewardAmount];
    NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[rewardNumber decimalValue]];

    GADAdReward *rewardItem = [[GADAdReward alloc] initWithRewardType:rewardInfo.rewardName
                               rewardAmount:decNum];
    [strongConnector adapter:strongAdapter didRewardUserWithReward:rewardItem];
    
    
    
    
    [strongConnector adapterDidCloseRewardBasedVideoAd:strongAdapter];

}



- (void)checkVideoReady{
    
    id<GADMRewardBasedVideoAdNetworkConnector> strongConnector = _rewardBasedVideoAdConnector;
    id<GADMRewardBasedVideoAdNetworkAdapter> strongAdapter = _rewardBasedVideoAdAdapter;

    if (secondCount > SUMTIME) {
        
        NSString *errorMsg  = @"Mintegral Ads load time out";
        NSError *adapterError = [NSError errorWithDomain:kMintegralAdapterErrorDomain code:kGADErrorTimeout userInfo:@{NSLocalizedDescriptionKey : errorMsg}];

        [strongConnector adapter:strongAdapter didFailToLoadRewardBasedVideoAdwithError:adapterError];
        
        [self stopTimer];
        return ;
    }
    
    secondCount += TIMERDURATION;
    
    MintegralCustomEventRewardedVideoLegacy *adapter = (MintegralCustomEventRewardedVideoLegacy *)strongAdapter;
    
    if ([adapter hasAdAvailable]) {
        [strongConnector adapterDidReceiveRewardBasedVideoAd:strongAdapter];
        
        [self stopTimer];
    }
}
    
-(void)fireTimer{
    
    if (secondCount > 0) return;

    secondCount = 0;

    _queryTimer = [NSTimer  scheduledTimerWithTimeInterval:TIMERDURATION target:self selector:@selector(checkVideoReady) userInfo:nil repeats:YES];
    [_queryTimer fire];
    
}

-(void)stopTimer{
    
    secondCount = 0;

    if (_queryTimer.isValid) {
        [_queryTimer invalidate];
        _queryTimer = nil;
    }
    
}


@end
