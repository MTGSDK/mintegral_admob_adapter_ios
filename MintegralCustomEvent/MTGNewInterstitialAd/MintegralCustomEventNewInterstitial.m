//
//  MintegralCustomEventNewInterstitial.m
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralCustomEventNewInterstitial.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKNewInterstitial/MTGSDKNewInterstitial.h>

#import "MintegralHelper.h"


@interface MintegralCustomEventNewInterstitial() <MTGNewInterstitialAdDelegate>

@property (nonatomic, copy) NSString *adUnit;
@property (nonatomic, copy) NSString *adPlacement;

@property (nonatomic, readwrite, strong) MTGNewInterstitialAdManager *interstitialAdManager;

@property (nonatomic,copy) GADMediationInterstitialLoadCompletionHandler interstitialLoadCompletionHandler;
@property(nonatomic, weak, nullable) id<GADMediationInterstitialAdEventDelegate> customEventInterstitialDelegate;


@end

@implementation MintegralCustomEventNewInterstitial



+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

+ (GADVersionNumber)adSDKVersion {
  NSString *versionString = MTGNewInterstitialSDKVersion;

  NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
  GADVersionNumber version = {0};
  if (versionComponents.count == 3) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion = [versionComponents[2] integerValue];
  }
  return version;
}

+ (GADVersionNumber)adapterVersion {

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
/// Tells the adapter to set up its underlying ad network SDK and perform any necessary prefetching
/// or configuration work. The adapter must call completionHandler once the adapter can service ad
/// requests, or if it encounters an error while setting up.
+ (void)setUpWithConfiguration:(nonnull GADMediationServerConfiguration *)configuration
             completionHandler:(nonnull GADMediationAdapterSetUpCompletionBlock)completionHandler{
    
    if (completionHandler) {
        completionHandler(nil);
    }
}

/*
 deprecated:  GADCustomEventInterstitial
- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {

    NSDictionary *mintegralInfoDict = [MintegralHelper dictionaryWithJsonString:serverParameter];
    
}
*/

/// Asks the adapter to load an interstitial ad with the provided ad configuration. The adapter
/// must call back completionHandler with the loaded ad, or it may call back with an error. This
/// method is called on the main thread, and completionHandler must be called back on the main
/// thread.
- (void)loadInterstitialForAdConfiguration:
            (nonnull GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:(nonnull GADMediationInterstitialLoadCompletionHandler)
completionHandler{
    self.interstitialLoadCompletionHandler = completionHandler;

    NSString *parameter = adConfiguration.credentials.settings[@"parameter"];
    NSDictionary *mintegralInfoDict = [MintegralHelper dictionaryWithJsonString:parameter];

    NSString *appId = nil;
    if ([mintegralInfoDict objectForKey:@"appId"]) {
        appId = [mintegralInfoDict objectForKey:@"appId"];
    }
    
    NSString *appKey = nil;
    if ([mintegralInfoDict objectForKey:@"appKey"]) {
        appKey = [mintegralInfoDict objectForKey:@"appKey"];
    }
    
    if ([mintegralInfoDict objectForKey:@"unitId"]) {
        self.adUnit = [mintegralInfoDict objectForKey:@"unitId"];
    }
    
    if ([mintegralInfoDict objectForKey:@"placementId"]) {
        self.adPlacement = [mintegralInfoDict objectForKey:@"placementId"];
    }
    
    NSString *consentGDPR = [mintegralInfoDict objectForKey:@"consent"];
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
    
    
    if (!_interstitialAdManager) {
        _interstitialAdManager = [[MTGNewInterstitialAdManager alloc] initWithPlacementId:self.adPlacement unitId:self.adUnit delegate:self];
    }
    
    [_interstitialAdManager loadAd];
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromViewController:(nonnull UIViewController *)viewController {

    [_interstitialAdManager showFromViewController:viewController];
}

#pragma mark MVInterstitialVideoAdLoadDelegate implementation

/**
 *  Called when the ad is successfully load , and is ready to be displayed
 */
- (void)newInterstitialAdResourceLoadSuccess:(MTGNewInterstitialAdManager *_Nonnull)adManager
{
    if (self.interstitialLoadCompletionHandler) {
        self.customEventInterstitialDelegate = self.interstitialLoadCompletionHandler(self,nil);
    }
}


/**
 *  Called when there was an error loading the ad.
 *  @param error       - error object that describes the exact error encountered when loading the ad.
 */
- (void)newInterstitialAdLoadFail:(nonnull NSError *)error adManager:(MTGNewInterstitialAdManager *_Nonnull)adManager
{
    if (self.interstitialLoadCompletionHandler) {
        NSError *_error = [NSError errorWithDomain:customEventErrorDomain code:error.code userInfo:error.userInfo];
        self.interstitialLoadCompletionHandler(nil, _error);
    }
}

/**
 *  Called when the ad displayed successfully
 */
- (void)newInterstitialAdShowSuccess:(MTGNewInterstitialAdManager *_Nonnull)adManager
{
    if (self.customEventInterstitialDelegate && [self.customEventInterstitialDelegate respondsToSelector:@selector(willPresentFullScreenView)]) {
        [self.customEventInterstitialDelegate willPresentFullScreenView];
    }

    if (self.customEventInterstitialDelegate && [self.customEventInterstitialDelegate respondsToSelector:@selector(reportImpression)]) {
        [self.customEventInterstitialDelegate reportImpression];
    }
}

/**
 *  Called when the ad failed to display
 *  @param error       - error object that describes the exact error encountered when showing the ad.
 */
- (void)newInterstitialAdShowFail:(nonnull NSError *)error adManager:(MTGNewInterstitialAdManager *_Nonnull)adManager
{
    if (self.customEventInterstitialDelegate && [self.customEventInterstitialDelegate respondsToSelector:@selector(didFailToPresentWithError:)]) {
        [self.customEventInterstitialDelegate didFailToPresentWithError:error];
    }
}


/**
 *  Called when the ad has been dismissed from being displayed, and control will return to your app
 *  @param converted   - BOOL describing whether the ad has converted
 */
- (void)newInterstitialAdDismissedWithConverted:(BOOL)converted adManager:(MTGNewInterstitialAdManager *_Nonnull)adManager
{
    if (self.customEventInterstitialDelegate && [self.customEventInterstitialDelegate respondsToSelector:@selector(willDismissFullScreenView)]) {
        [self.customEventInterstitialDelegate willDismissFullScreenView];
    }
}

/**
 *  Called when the ad  did closed;
 */
- (void)newInterstitialAdDidClosed:(MTGNewInterstitialAdManager *_Nonnull)adManager{

    if (self.customEventInterstitialDelegate && [self.customEventInterstitialDelegate respondsToSelector:@selector(didDismissFullScreenView)]) {
        [self.customEventInterstitialDelegate didDismissFullScreenView];
    }
}


/**
 *  Called when the ad is clicked
 */
- (void)newInterstitialAdClicked:(MTGNewInterstitialAdManager *_Nonnull)adManager
{
    
    if (self.customEventInterstitialDelegate && [self.customEventInterstitialDelegate respondsToSelector:@selector(reportClick)]) {
        [self.customEventInterstitialDelegate reportClick];
    }
}







@end
