//
//  MintegralCustomEventNativeAd.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralCustomEventNativeAd.h"
#import "MintegralMediatedNativeAd.h"
#import "MintegralHelper.h"

#if __has_include(<MTGSDK/MTGSDK.h>)
    #import <MTGSDK/MTGSDK.h>
#else
    #import "MTGSDK.h"
#endif

@interface MintegralCustomEventNativeAd()<MTGNativeAdManagerDelegate>

@property (nonatomic, readwrite, strong) MTGNativeAdManager *mtgNativeAdManager;
@property (nonatomic, readwrite, strong) NSArray *adTypes;

@property (nonatomic, readwrite, copy) NSString * localNativeUnitId;
@property (nonatomic, copy) NSString *localNativePlacementId;
@property (nonatomic) BOOL video_enabled;

@end



@implementation MintegralCustomEventNativeAd

@synthesize delegate;


- (void)requestNativeAdWithParameter:(NSString *)serverParameter
                             request:(GADCustomEventRequest *)request
                             adTypes:(NSArray *)adTypes
                             options:(NSArray *)options
                  rootViewController:(UIViewController *)rootViewController
{

    NSDictionary *mintegralInfoDict = [MintegralHelper dictionaryWithJsonString:serverParameter];

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
    MTGAdTemplateType reqNum = [mintegralInfoDict objectForKey:@"reqNum"] ? [[mintegralInfoDict objectForKey:@"reqNum"] integerValue]:1;
    
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
    if (!([adTypes containsObject:kGADAdLoaderAdTypeUnifiedNative])) {
        NSString *description = @"At least one ad type must be selected.";
        NSDictionary *userInfo =
        @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description};
        NSError *error =
        [NSError errorWithDomain:customEventErrorDomain code:kGADErrorInvalidRequest userInfo:userInfo];

        [self.delegate customEventNativeAd:self didFailToLoadWithError:error];

        return;
    }
    
    self.adTypes = adTypes;

    
    // The Google Mobile Ads SDK requires the image assets to be downloaded automatically unless the
    // publisher specifies otherwise by using the GADNativeAdImageAdLoaderOptions object's
    // disableImageLoading property. If your network doesn't have an option like this and instead only
    // ever returns URLs for images (rather than the images themselves), your adapter should download
    // image assets on behalf of the publisher. This should be done after receiving the native ad
    // object from your network's SDK, and before calling the connector's
    // adapter:didReceiveMediatedNativeAd: method.
    
    if(_video_enabled){
        self.mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithPlacementId:_localNativePlacementId unitID:_localNativeUnitId fbPlacementId:fbPlacementId
                videoSupport:_video_enabled forNumAdsRequested: reqNum
                presentingViewController:nil];
    }else{
        self.mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithPlacementId:_localNativePlacementId unitID:_localNativeUnitId fbPlacementId:fbPlacementId  supportedTemplates:templates autoCacheImage:autoCacheImage adCategory:adCategory presentingViewController:nil];
    }
    
    self.mtgNativeAdManager.delegate = self;
    [self.mtgNativeAdManager loadAds];
}

/// Indicates if the custom event handles user clicks. Return YES if the custom event should handle
/// user clicks. In this case, the Google Mobile Ads SDK doesn't track user clicks and the custom
/// event must notify the Google Mobile Ads SDK of clicks using
/// +[GADMediatedNativeAdNotificationSource mediatedNativeAdDidRecordClick:]. Return NO if the
/// custom event doesn't handles user clicks. In this case, the Google Mobile Ads SDK tracks user
/// clicks itself and the custom event is notified of user clicks via -[GADMediatedNativeAdDelegate
/// mediatedNativeAd:didRecordClickOnAssetWithName:view:viewController:].
- (BOOL)handlesUserClicks{
    return YES;
}

/// Indicates if the custom event handles user impressions tracking. If this method returns YES, the
/// Google Mobile Ads SDK will not track user impressions and the custom event must notify the
/// Google Mobile Ads SDK of impressions using +[GADMediatedNativeAdNotificationSource
/// mediatedNativeAdDidR ecordImpression:]. If this method returns NO,
/// the Google Mobile Ads SDK tracks user impressions and notifies the custom event of impressions
/// using -[GADMediatedNativeAdDelegate mediatedNativeAdDidRecordImpression:].
- (BOOL)handlesUserImpressions{
    return YES;
}



#pragma mark - nativeAdManager delegate
- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds nativeManager:(nonnull MTGNativeAdManager *)nativeManager {

    if (nativeAds.count == 0) {

        NSString *description = @"No Fill.";
        NSDictionary *userInfo =
        @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description};
        NSError *error =
        [NSError errorWithDomain:customEventErrorDomain code:kGADErrorNoFill userInfo:userInfo];
        [self.delegate customEventNativeAd:self didFailToLoadWithError:error];

        return;
    }

    MTGCampaign *campaign = nativeAds.firstObject;

    
    MintegralMediatedNativeAd *mediatedAd =
    [[MintegralMediatedNativeAd alloc] initWithNativeManager:self.mtgNativeAdManager mtgCampaign:campaign withUnitId:self.localNativeUnitId videoSupport:self.video_enabled];
    [self.delegate customEventNativeAd:self didReceiveMediatedUnifiedNativeAd:mediatedAd];
    
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error nativeManager:(nonnull MTGNativeAdManager *)nativeManager {
}
- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error {
    
    NSError *customError = [NSError errorWithDomain:customEventErrorDomain code:error.code userInfo:error.userInfo];
    [self.delegate customEventNativeAd:self didFailToLoadWithError:customError];
}

@end
