//
//  MintegralCustomEventNativeAd.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralCustomEventNativeAd.h"
#import "MintegralMediatedNativeAd.h"
#import <MTGSDK/MTGSDK.h>

#import "MintegralHelper.h"


@interface MintegralCustomEventNativeAd()<MTGNativeAdManagerDelegate>

@property (nonatomic, readwrite, strong) MTGNativeAdManager *mtgNativeAdManager;


@property (nonatomic,copy) GADMediationNativeLoadCompletionHandler nativeLoadCompletionHandler;
@property(nonatomic, weak, nullable) id<GADMediationNativeAdEventDelegate> customEventNativeDelegate;

@property (nonatomic, readwrite, copy) NSString * localNativeUnitId;
@property (nonatomic, copy) NSString *localNativePlacementId;
@property (nonatomic) BOOL video_enabled;

@end



@implementation MintegralCustomEventNativeAd

@synthesize body;
@synthesize callToAction;
@synthesize advertiser;
@synthesize extraAssets;
@synthesize headline;
@synthesize icon;
@synthesize images;
@synthesize price;
@synthesize starRating;
@synthesize store;



+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

/// Returns the adapter version.
+ (GADVersionNumber)adapterVersion{
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

/// Returns the ad SDK version.
+ (GADVersionNumber)adSDKVersion{
    NSString *versionString = MTGSDKVersion;
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
      version.majorVersion = [versionComponents[0] integerValue];
      version.minorVersion = [versionComponents[1] integerValue];
      version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
  }


/*
 deprecated:  GADCustomEventInterstitial

 - (void)requestNativeAdWithParameter:(NSString *)serverParameter
                              request:(GADCustomEventRequest *)request
                              adTypes:(NSArray *)adTypes
                              options:(NSArray *)options
                   rootViewController:(UIViewController *)rootViewController
 */

/// Asks the adapter to load a native ad with the provided ad configuration. The adapter must call
/// back completionHandler with the loaded ad, or it may call back with an error. This method is
/// called on the main thread, and completionHandler must be called back on the main thread.
-(void)loadNativeAdForAdConfiguration:(GADMediationNativeAdConfiguration *)adConfiguration completionHandler:(GADMediationNativeLoadCompletionHandler)completionHandler{
    
    
    self.nativeLoadCompletionHandler = completionHandler;

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
        _localNativeUnitId = [mintegralInfoDict objectForKey:@"unitId"];
    }
    if ([mintegralInfoDict objectForKey:@"placementId"]) {
        _localNativePlacementId = [mintegralInfoDict objectForKey:@"placementId"];
    }
    NSString *fbPlacementId = nil;
    if ([mintegralInfoDict objectForKey:@"fbPlacementId"]) {
        fbPlacementId = [mintegralInfoDict objectForKey:@"fbPlacementId"];
    }
    
    NSUInteger numsOfAdsRequest = 1;
    if ([mintegralInfoDict objectForKey:@"numsOfAdsRequest"]) {
        numsOfAdsRequest = [[mintegralInfoDict objectForKey:@"numsOfAdsRequest"] unsignedIntegerValue];
    }
    
    BOOL autoCacheImage = YES;
    if ([mintegralInfoDict objectForKey:@"autoCacheImage"]) {
        autoCacheImage = [[mintegralInfoDict objectForKey:@"autoCacheImage"] boolValue];
    }
    
    //get video parameter
    _video_enabled = YES;
    if ([mintegralInfoDict objectForKey:@"video_enabled"]) {
        _video_enabled = [[mintegralInfoDict objectForKey:@"video_enabled"] boolValue];
    }
    //add num parameter
//    MTGAdTemplateType reqNum = [mintegralInfoDict objectForKey:@"reqNum"] ? [[mintegralInfoDict objectForKey:@"reqNum"] integerValue]:1;
    
    MTGAdCategory adCategory = MTGAD_CATEGORY_ALL;
    if ([mintegralInfoDict objectForKey:@"adCategory"]) {
        adCategory = [[mintegralInfoDict objectForKey:@"adCategory"] integerValue];
    }
    
    MTGAdTemplateType templateType = MTGAD_TEMPLATE_BIG_IMAGE;
    if ([mintegralInfoDict objectForKey:@"templateType"]) {
        templateType = [[mintegralInfoDict objectForKey:@"templateType"] integerValue];
    }

    MTGTemplate *template = [MTGTemplate templateWithType:templateType adsNum:1];
    NSArray *templates = @[template];
    
    
    // Part of the adapter's job is to examine the ad types and options, and then create a request for
    // the mediated network's SDK that matches them.
    //
    // Care needs to be taken to make sure the adapter respects the publisher's wishes in regard to
    // native ad formats. For example, if your ad network only provides app install ads, and the
    // publisher requests content ads alone, the adapter must report an error by calling the
    // connector's adapter:didFailAd: method with an error code set to kGADErrorInvalidRequest. It
    // should *not* request an app install ad anyway, and then attempt to map it to the content ad
    // format.
    
    BOOL containImageAdLoader = NO;
    for (id option in adConfiguration.options) {
        if ([option isKindOfClass:GADNativeAdImageAdLoaderOptions.class]) {
            containImageAdLoader = YES;
        }
    }
    if (!containImageAdLoader) {
        NSString *description = @"At least one ad type must be selected.";
        NSDictionary *userInfo =
        @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description};
        NSError *error =
        [NSError errorWithDomain:customEventErrorDomain code:GADErrorInvalidRequest userInfo:userInfo];

        if (self.nativeLoadCompletionHandler) {
            self.nativeLoadCompletionHandler(self,error);
        }
        return;
    }
    

    
    // The Google Mobile Ads SDK requires the image assets to be downloaded automatically unless the
    // publisher specifies otherwise by using the GADNativeAdImageAdLoaderOptions object's
    // disableImageLoading property. If your network doesn't have an option like this and instead only
    // ever returns URLs for images (rather than the images themselves), your adapter should download
    // image assets on behalf of the publisher. This should be done after receiving the native ad
    // object from your network's SDK, and before calling the connector's
    // adapter:didReceiveMediatedNativeAd: method.
    
//    if(_video_enabled){
//        self.mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithPlacementId:_localNativePlacementId unitID:_localNativeUnitId fbPlacementId:fbPlacementId
//                videoSupport:_video_enabled forNumAdsRequested: reqNum
//                presentingViewController:nil];
//    }else{
        
        self.mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithPlacementId:_localNativePlacementId unitID:_localNativeUnitId supportedTemplates:templates autoCacheImage:autoCacheImage adCategory:adCategory presentingViewController:adConfiguration.topViewController];
//    }
    

    self.mtgNativeAdManager.delegate = self;
    [self.mtgNativeAdManager loadAds];

}




#pragma mark - nativeAdManager delegate

- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds nativeManager:(nonnull MTGNativeAdManager *)nativeManager {

    if (nativeAds.count == 0) {

        NSString *description = @"No Fill.";
        NSDictionary *userInfo =
        @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description};
        
        
        NSError *error =
        [NSError errorWithDomain:customEventErrorDomain code:GADErrorNoFill userInfo:userInfo];
        if (self.nativeLoadCompletionHandler) {
            self.nativeLoadCompletionHandler(self,error);
        }
        return;
    }

    MTGCampaign *campaign = nativeAds.firstObject;

    
    MintegralMediatedNativeAd *mediatedAd =
    [[MintegralMediatedNativeAd alloc] initWithNativeManager:self.mtgNativeAdManager mtgCampaign:campaign withUnitId:self.localNativeUnitId videoSupport:self.video_enabled];
    
    if (self.nativeLoadCompletionHandler) {
        self.customEventNativeDelegate = self.nativeLoadCompletionHandler(mediatedAd,nil);
    }
    mediatedAd.adEventDelegate = self.customEventNativeDelegate;

}


//- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error
- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error nativeManager:(nonnull MTGNativeAdManager *)nativeManager
{
    
    NSError *customError = [NSError errorWithDomain:customEventErrorDomain code:error.code userInfo:error.userInfo];
    if (self.nativeLoadCompletionHandler) {
        self.nativeLoadCompletionHandler(self,customError);
    }
}


@end
