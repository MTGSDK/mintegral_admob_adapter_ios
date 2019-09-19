//
//  MintegralMediatedNativeAppInstallAd.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralMediatedNativeAppInstallAd.h"
#import <MTGSDK/MTGMediaView.h>


@interface MintegralMediatedNativeAppInstallAd ()<GADMediatedNativeAdDelegate,MTGNativeAdManagerDelegate,MTGMediaViewDelegate>


@property (nonatomic, readwrite, strong) MTGNativeAdManager *mtgNativeAdManager;
@property(nonatomic, strong) MTGCampaign *campaign;

@property (nonatomic) MTGMediaView *mediaView;
@property (nonatomic) BOOL video_enabled;
@property (nonatomic, readwrite, copy) NSString *unitId;

@property(nonatomic, copy) NSArray *mappedImages;
@property(nonatomic, strong) GADNativeAdImage *mappedIcon;
@property(nonatomic, copy) NSDictionary *extras;

@end

@implementation MintegralMediatedNativeAppInstallAd

- (nullable instancetype)initAppInstallAdWithNativeManager:(nonnull MTGNativeAdManager *)nativeManager mtgCampaign:(nonnull MTGCampaign *)campaign withUnitId:(NSString *)unitId videoSupport:(BOOL)videoSupport{

    if (!campaign) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        _mtgNativeAdManager = nativeManager;
        _mtgNativeAdManager.delegate = self;
        
        _campaign = campaign;
        if (campaign.imageUrl) {
            UIImage *img;
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:campaign.imageUrl]];
            img = [UIImage imageWithData:imgData];
            _mappedImages = @[ [[GADNativeAdImage alloc] initWithImage:img] ];
        }
        
        NSURL *iconURL = nil;
        if (campaign.iconUrl) {
            iconURL = [[NSURL alloc] initWithString:campaign.iconUrl];
            _mappedIcon = [[GADNativeAdImage alloc] initWithURL:iconURL scale:1.0];
        }
        
        // If video ad is enabled, use mediaView, otherwise use coverImage.
        if (videoSupport) {
            [self MTGmediaView];
        }
        //NSLog(@"videoSupport value: %@" ,videoSupport?@"YES":@"NO");
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
    _mappedIcon = nil;
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

- (GADNativeAdImage *)icon {
    return self.mappedIcon;
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


- (NSDictionary *)extraAssets {
    return self.extras;
}

- (id<GADMediatedNativeAdDelegate>)mediatedNativeAdDelegate {
    return self;
}


#pragma mark - MVSDK NativeAdManager Delegate

- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd;
{
    
//report to admob
    [GADMediatedNativeAdNotificationSource mediatedNativeAdDidRecordClick:self];
}


- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error{

//    [GADMediatedNativeAdNotificationSource mediatedNativeAdDidDismissScreen:self];
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type nativeManager:(nonnull MTGNativeAdManager *)nativeManager{
    if (type == MTGAD_SOURCE_API_OFFER) {
        [GADMediatedNativeAdNotificationSource mediatedNativeAdDidRecordImpression:self];
    }
}

#pragma mark - GADMediatedNativeAdDelegate implementation

- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd
         didRenderInView:(UIView *)view
          viewController:(UIViewController *)viewController {
//  Here you would pass the UIView back to the mediated network's SDK.
    for (UIView *subView in view.subviews) {
        subView.userInteractionEnabled = NO;
    }

    [_mtgNativeAdManager registerViewForInteraction:view withCampaign:_campaign];
}

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

#pragma mark - MVMediaViewDelegate implementation

-  (UIView *GAD_NULLABLE_TYPE)mediaView{
    [_mediaView setMediaSourceWithCampaign:_campaign unitId:_unitId];
    return _mediaView;
}

- (BOOL)hasVideoContent{
    if(self.video_enabled){
        return [_mediaView isVideoContent];
    }else{
        return self.video_enabled;
    }
}

-(MTGMediaView *)MTGmediaView{
    
    if (_mediaView) {
        return _mediaView;
    }
    
    MTGMediaView *mediaView = [[MTGMediaView alloc] initWithFrame:CGRectZero];
    mediaView.delegate = self;
    _mediaView = mediaView;
    
    return mediaView;
}

@end
