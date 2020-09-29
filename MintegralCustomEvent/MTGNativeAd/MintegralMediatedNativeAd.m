//
//  MintegralMediatedNativeAd.m
//  Admob_SampleApp
//
//  Created by Harry on 2020/5/9.
//  Copyright © 2020 Chark. All rights reserved.
//

#import "MintegralMediatedNativeAd.h"
#if __has_include(<MTGSDK/MTGSDK.h>)
    #import <MTGSDK/MTGSDK.h>
#else
    #import "MTGSDK.h"
#endif

@interface MintegralMediatedNativeAd ()<MTGNativeAdManagerDelegate,MTGMediaViewDelegate>

@property (nonatomic, readwrite, strong) MTGNativeAdManager *mtgNativeAdManager;
@property(nonatomic, strong) MTGCampaign *campaign;

@property (nonatomic) MTGMediaView *mediaView;
@property (nonatomic) BOOL video_enabled;
@property (nonatomic, readwrite, copy) NSString *unitId;

@property(nonatomic, copy) NSArray *mappedImages;
@property(nonatomic, strong) GADNativeAdImage *mappedLogo;
@property(nonatomic, copy) NSDictionary *extras;

@end

@implementation MintegralMediatedNativeAd

- (nullable instancetype)initWithNativeManager:(nonnull id )nativeManager mtgCampaign:(nonnull id)campaign  withUnitId:(NSString *)unitId videoSupport:(BOOL)videoSupport{
    
    if (!campaign) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        _mtgNativeAdManager = (MTGNativeAdManager *)nativeManager;
        _mtgNativeAdManager.delegate = self;
        
        _campaign = (MTGCampaign *)campaign;
        if (_campaign.imageUrl) {
            UIImage *img;
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_campaign.imageUrl]];
            img = [UIImage imageWithData:imgData];
            _mappedImages = @[ [[GADNativeAdImage alloc] initWithImage:img] ];
        }
        
        NSURL *iconURL = nil;
        if (_campaign.iconUrl) {
            iconURL = [[NSURL alloc] initWithString:_campaign.iconUrl];
            _mappedLogo = [[GADNativeAdImage alloc] initWithURL:iconURL scale:1.0];
        }
        
        // If video ad is enabled, use mediaView, otherwise use coverImage.
        if (videoSupport) {
            [self MVmediaView];
        }
        
        _video_enabled = videoSupport;
        _unitId = unitId;
    }
    return self;
}


-(void)dealloc{
    _mtgNativeAdManager.delegate = nil;
    _mtgNativeAdManager = nil;
    
    _mediaView.delegate = nil;
    _mediaView = nil;
    
    _campaign = nil;
    _unitId = nil;
    
    _mappedImages = nil;
    _mappedLogo = nil;
    _extras = nil;
}

- (NSString *)headline {
    return self.campaign.appName;
}

- (NSArray *)images {
    return self.mappedImages;
}

- (NSString *)body {
    return self.campaign.appDesc;
}

- (GADNativeAdImage *)logo {
    return self.mappedLogo;
}

- (GADNativeAdImage *)icon {
    return self.mappedLogo;
}

- (NSString *)callToAction {
    return self.campaign.adCall;
}

- (NSDecimalNumber *)starRating {
    
    NSString *star = [NSString stringWithFormat:@"%@",[_campaign valueForKey:@"star"]];
    return [NSDecimalNumber decimalNumberWithString:star];
}

- (NSString *)store {
    
    return @"";
}

- (NSString *)price {
    return @"";
}

-(NSString *)advertiser{
    return @"";
}

- (NSDictionary *)extraAssets {
    return self.extras;
}


- (id)mediatedNativeAdDelegate {
    return self;
}

-  (UIView *GAD_NULLABLE_TYPE)mediaView{
    [_mediaView setMediaSourceWithCampaign:_campaign unitId:_unitId];
    return _mediaView;
}

- (BOOL)hasVideoContent{
    return self.video_enabled;
    
//    if(self.video_enabled){
//        return [_mediaView isVideoContent];
//    }else{
//        return self.video_enabled;
//    }
}

-(MTGMediaView *)MVmediaView{
    
    if (_mediaView) {
        return _mediaView;
    }
    
    MTGMediaView *mediaView = [[MTGMediaView alloc] initWithFrame:CGRectZero];
    mediaView.delegate = self;
    _mediaView = mediaView;
    
    return mediaView;
}


#pragma mark - MTGSDK NativeAdManager Delegate
- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd nativeManager:(nonnull MTGNativeAdManager *)nativeManager {
    //report to admob
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordClick:self];
}


- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error{
    
    //    [GADMediatedNativeAdNotificationSource mediatedNativeAdDidDismissScreen:self];
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type nativeManager:(nonnull MTGNativeAdManager *)nativeManager{
    if (type == MTGAD_SOURCE_API_OFFER) {
        [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordImpression:self];
    }
}

#pragma mark - GADMediatedNativeAdDelegate implementation

// Because the Sample SDK handles click and impression tracking via methods on its native
// ad object, there's no need to pass it a reference to the UIView being used to display
// the native ad. So there's no need to implement mediatedNativeAd:didRenderInView:viewController
// here. If your mediated network does need a reference to the view, this method can be used to
// provide one.

- (void)mediatedNativeAd:(id)mediatedNativeAd
         didRenderInView:(UIView *)view
          viewController:(UIViewController *)viewController {
    //  Here you would pass the UIView back to the mediated network's SDK.
    
    for (UIView *subView in view.subviews) {
        subView.userInteractionEnabled = NO;
    }
    
    [_mtgNativeAdManager registerViewForInteraction:view withCampaign:_campaign];
}

- (void)didRenderInView:(nonnull UIView *)view
       clickableAssetViews:
           (nonnull NSDictionary<GADUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
    nonclickableAssetViews:
        (nonnull NSDictionary<GADUnifiedNativeAssetIdentifier, UIView *> *)nonclickableAssetViews
         viewController:(nonnull UIViewController *)viewController {
    
    for (UIView *subView in view.subviews) {
        subView.userInteractionEnabled = NO;
    }
    
    [_mtgNativeAdManager registerViewForInteraction:view withCampaign:_campaign];
    
}

/// Tells the receiver that an impression is recorded. This method is called only once per mediated
/// native ad.
- (void)didRecordImpression {
    
}

/// Tells the receiver that a user click is recorded on the asset named |assetName|. Full screen
/// actions should be presented from viewController. This method is called only if
/// -[GADMAdNetworkAdapter handlesUserClicks] returns NO.
- (void)didRecordClickOnAssetWithName:(nonnull GADUnifiedNativeAssetIdentifier)assetName
                                 view:(nonnull UIView *)view
                       viewController:(nonnull UIViewController *)viewController {
    
}

/// Tells the receiver that it has untracked |view|. This method is called when the mediated native
/// ad is no longer rendered in the provided view and the delegate should stop tracking the view's
/// impressions and clicks. The method may also be called with a nil view when the view in which the
/// mediated native ad has rendered is deallocated.
- (void)didUntrackView:(nullable UIView *)view {
    
}


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

#pragma mark - MTGMediaViewDelegate


- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd mediaView:(MTGMediaView *)mediaView {
    
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordClick:self];
    
}
@end
