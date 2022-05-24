//
//  MintegralCustomEventBannerAd.m
//  
//
//  Created by Lucas on 2019/9/3.
//

#import "MintegralCustomEventBannerAd.h"
#import <MTGSDKBanner/MTGBannerAdView.h>
#import <MTGSDKBanner/MTGBannerAdViewDelegate.h>
#import <MTGSDK/MTGSDK.h>
#import "MintegralHelper.h"

static NSString *const MintegralEventErrorDomain = @"com.google.MintegralCustomEvent";

@interface MintegralCustomEventBannerAd () <MTGBannerAdViewDelegate>

/// The Sample Ad Network banner.
@property(nonatomic, strong) MTGBannerAdView *bannerAdView;
@property (nonatomic, copy) NSString * unitId;
@property (nonatomic, copy) NSString * placementId;


@property (nonatomic,copy) GADMediationBannerLoadCompletionHandler bannerLoadCompletionHandler;
@property(nonatomic, weak, nullable) id<GADMediationBannerAdEventDelegate> customEventBannerDelegate;


@end

@implementation MintegralCustomEventBannerAd

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

+ (GADVersionNumber)adSDKVersion {
    NSString *versionString = MTGBannerSDKVersion;
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



#pragma mark GADCustomEventBanner implementation

//deprecated:  GADCustomEventInterstitial

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    // Create the bannerView with the appropriate size.
 }



/// Asks the adapter to load a banner ad with the provided ad configuration. The adapter must call
/// back completionHandler with the loaded ad, or it may call back with an error. This method is
/// called on the main thread, and completionHandler must be called back on the main thread.
- (void)loadBannerForAdConfiguration:(nonnull GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:
(nonnull GADMediationBannerLoadCompletionHandler)completionHandler{


    self.bannerLoadCompletionHandler = completionHandler;

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
    
    if ([mintegralInfoDict objectForKey:@"unitId"]) {
        self.unitId = [mintegralInfoDict objectForKey:@"unitId"];
    }
    
    if ([mintegralInfoDict objectForKey:@"placementId"]) {
        self.placementId = [mintegralInfoDict objectForKey:@"placementId"];
    }
    
    UIViewController * vc =  [UIApplication sharedApplication].keyWindow.rootViewController;
    
    _bannerAdView = [[MTGBannerAdView alloc] initBannerAdViewWithAdSize:adConfiguration.adSize.size placementId:self.placementId unitId:self.unitId rootViewController:vc];
    _bannerAdView.delegate = self;
    _bannerAdView.autoRefreshTime = 0;
    [_bannerAdView loadBannerAd];
    
}


#pragma mark -- GADMediationBannerAd

/// The banner ad view.
//@property(nonatomic, readonly, nonnull) UIView *view;
- (UIView *)view {
  return self.bannerAdView;
}

/// Tells the ad to resize the banner. Implement if banner content is resizable.
- (void)changeAdSizeTo:(GADAdSize)adSize{
    CGPoint point = _bannerAdView.frame.origin;
    _bannerAdView.frame = CGRectMake(point.x, point.y, adSize.size.width, adSize.size.height);
}

#pragma mark -- MTGBannerAdViewDelegate
- (void)adViewLoadSuccess:(MTGBannerAdView *)adView {

    if (self.bannerLoadCompletionHandler) {
        self.customEventBannerDelegate =  self.bannerLoadCompletionHandler(self,nil);
    }
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView {
    if (self.bannerLoadCompletionHandler) {
        self.bannerLoadCompletionHandler(self,error);
    }
}

- (void)adViewWillLogImpression:(MTGBannerAdView *)adView{
    
    if ([self.customEventBannerDelegate respondsToSelector:@selector(reportImpression)]) {
        [self.customEventBannerDelegate reportImpression];
    }
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView {
    if ([self.customEventBannerDelegate respondsToSelector:@selector(reportClick)]) {
        [self.customEventBannerDelegate reportClick];
    }
}

- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView {
    ;
}

- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView {
    if ([self.customEventBannerDelegate respondsToSelector:@selector(willPresentFullScreenView)]) {
        [self.customEventBannerDelegate willPresentFullScreenView];
    }
}

- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView {

    if ([self.customEventBannerDelegate respondsToSelector:@selector(willDismissFullScreenView)]) {
        [self.customEventBannerDelegate willDismissFullScreenView];
    }
    
    if ([self.customEventBannerDelegate respondsToSelector:@selector(didDismissFullScreenView)]) {
        [self.customEventBannerDelegate didDismissFullScreenView];
    }
}

- (void)adViewClosed:(MTGBannerAdView *)adView {
    ;//no ops
}

@end
