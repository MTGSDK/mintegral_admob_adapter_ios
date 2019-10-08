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
@property (nonatomic, readwrite, copy) NSString * localNativeUnitId;

@end

@implementation MintegralCustomEventBannerAd
@synthesize delegate;

#pragma mark GADCustomEventBanner implementation

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    // Create the bannerView with the appropriate size.
    
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
    
    UIViewController * vc =  [UIApplication sharedApplication].keyWindow.rootViewController;
    _bannerAdView = [[MTGBannerAdView alloc]initBannerAdViewWithAdSize:adSize.size unitId:_localNativeUnitId rootViewController:vc];
    _bannerAdView.delegate = self;
    [_bannerAdView loadBannerAd];
    
}

#pragma mark -- MTGBannerAdViewDelegate
- (void)adViewLoadSuccess:(MTGBannerAdView *)adView {
    [self.delegate customEventBanner:self didReceiveAd:adView];
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView {
    [self.delegate customEventBanner:self didFailAd:error];
    
}

- (void)adViewWillLogImpression:(MTGBannerAdView *)adView{
    
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView {
    [self.delegate customEventBannerWasClicked:self];
}

- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView {
    [self.delegate customEventBannerWillLeaveApplication:self];
}

- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView {
 
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventBannerWillPresentModal:)]) {
        [self.delegate customEventBannerWillPresentModal:self];
    }
}

- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventBannerWillDismissModal:)]) {
        [self.delegate customEventBannerWillDismissModal:self];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventBannerDidDismissModal:)]) {
        [self.delegate customEventBannerDidDismissModal:self];
    }
}


@end
