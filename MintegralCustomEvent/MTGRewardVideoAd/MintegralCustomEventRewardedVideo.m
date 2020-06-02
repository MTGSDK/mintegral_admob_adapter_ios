//
//  MintegralCustomEventRewardedVideo.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral, Inc. All rights reserved.
//

#import "MintegralCustomEventRewardedVideo.h"
#import "MintegralAdNetworkExtras.h"
#import "MintegralHelper.h"

#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>


@interface MintegralCustomEventRewardedVideo () <MTGRewardAdLoadDelegate,MTGRewardAdShowDelegate>{
  

}

@property(nonatomic,copy)NSString *localAdUnit;
@property(nonatomic,copy)NSString *localAdPlacement;
@property(nonatomic,copy)NSString *rewardId;
@property(nonatomic,copy)NSString *userId;

@property (nonatomic,copy) GADMediationRewardedLoadCompletionHandler rewardedLoadCompletionHandler;
@property(nonatomic, weak, nullable) id<GADMediationRewardedAdEventDelegate> delegate;

@end

@implementation MintegralCustomEventRewardedVideo


#pragma mark - GADMediationAdapter

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {

    // OPTIONAL: Create your own class implementing GADAdNetworkExtras and return that class type
    // here for your publishers to use. This class does not use extras.
    
    return [MintegralAdNetworkExtras class];
}

+ (GADVersionNumber)adSDKVersion {
  NSString *versionString = MTGRewardVideoSDKVersion;
  NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
  GADVersionNumber version = {0};
  if (versionComponents.count == 3) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion = [versionComponents[2] integerValue];
  }
  return version;
}

+ (GADVersionNumber)version {
  NSString *versionString = MintegralAdapterVersion;
  NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
  GADVersionNumber version = {0};
  if (versionComponents.count == 4) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];

    // Adapter versions have 2 patch versions. Multiply the first patch by 100.
    version.patchVersion = [versionComponents[2] integerValue] * 100
      + [versionComponents[3] integerValue];
  }
  return version;
}


+(void)_initMintegralSDKWithAppId:(NSString *)appId appKey:(NSString *)appKey consentGDPR:(NSString *)consentGDPR{
    
    if ([consentGDPR isEqualToString:@"0"] ) {
        [MintegralHelper consentGDPR:NO];
    }

    if ([consentGDPR isEqualToString:@"1"] ) {
        [MintegralHelper consentGDPR:YES];
    }

    if (![MintegralHelper isSDKInitialized]) {

        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralHelper sdkInitialized];
    }

}



#pragma mark - GADMediationRewardedAd
- (void)loadRewardedAdForAdConfiguration:
(nonnull GADMediationRewardedAdConfiguration *)adConfiguration
           completionHandler:
(nonnull GADMediationRewardedLoadCompletionHandler)completionHandler{

    NSString *parameter = adConfiguration.credentials.settings[@"parameter"];
    NSDictionary *dict = [MintegralHelper dictionaryWithJsonString:parameter];
    NSString *appId = [dict objectForKey:@"appId"];
    NSString *appKey = [dict objectForKey:@"appKey"];
    NSString *consentGDPR = [dict objectForKey:@"consent"];
    [MintegralCustomEventRewardedVideo _initMintegralSDKWithAppId:appId appKey:appKey consentGDPR:consentGDPR];

    self.localAdUnit = dict[@"unitId"];
    self.localAdPlacement = dict[@"placementId"];
    MintegralAdNetworkExtras *extraItem = adConfiguration.extras;
    self.userId = extraItem.userId;

    self.rewardedLoadCompletionHandler = completionHandler;
    [[MTGRewardAdManager sharedInstance] loadVideoWithPlacementId:self.localAdPlacement unitId:self.localAdUnit delegate:self];
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {

    if ([[MTGRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId:self.localAdPlacement unitId:self.localAdUnit]) {

        NSString *rewardId = self.rewardId;
        NSString *userId = self.userId;
        
        [[MTGRewardAdManager sharedInstance] showVideoWithPlacementId:self.localAdPlacement unitId:self.localAdUnit withRewardId:rewardId userId:userId delegate:self viewController:viewController];
    }else{
        NSError *error =
          [NSError errorWithDomain:kMintegralAdapterErrorDomain
                              code:0
                          userInfo:@{NSLocalizedDescriptionKey : @"Unable to display ad."}];
        [self.delegate didFailToPresentWithError:error];
    }
}

#pragma mark - MTGRewardAdLoadDelegate

- (void)onAdLoadSuccess:(NSString *)placementId unitId:(NSString *)unitId {
    
}

- (void)onVideoAdLoadSuccess:(NSString *)placementId unitId:(NSString *)unitId {
    self.delegate = self.rewardedLoadCompletionHandler(self,nil);
}

- (void)onVideoAdLoadFailed:(NSString *)placementId unitId:(NSString *)unitId error:(NSError *)error {
    if (self.rewardedLoadCompletionHandler) {
        self.rewardedLoadCompletionHandler(nil, error);
    }
}


#pragma mark - MTGRewardAdShowDelegate

- (void)onVideoAdShowSuccess:(NSString *)placementId unitId:(NSString *)unitId {
    
    [self.delegate willPresentFullScreenView];
    [self.delegate reportImpression];
    
    [self.delegate didStartVideo];

}

- (void)onVideoAdShowFailed:(NSString *)placementId unitId:(NSString *)unitId withError:(NSError *)error {
    
}

- (void)onVideoPlayCompleted:(NSString *)placementId unitId:(NSString *)unitId {
   
    [self.delegate didEndVideo];
}

- (void)onVideoEndCardShowSuccess:(NSString *)placementId unitId:(NSString *)unitId {
    
}

- (void)onVideoAdClicked:(NSString *)placementId unitId:(NSString *)unitId {
    [self.delegate reportClick];
}

- (void)onVideoAdDismissed:(NSString *)placementId unitId:(NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(MTGRewardAdInfo *)rewardInfo {
    
    if (!converted) {
        return;
    }
    
    GADAdReward * reward = [[GADAdReward alloc] initWithRewardType:rewardInfo.rewardName
                                                      rewardAmount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ld",(long)rewardInfo.rewardAmount]]];
    [self.delegate didRewardUserWithReward:reward];
}

- (void)onVideoAdDidClosed:(NSString *)placementId unitId:(NSString *)unitId {
    
    [self.delegate willDismissFullScreenView];
    [self.delegate didDismissFullScreenView];
}




@end
