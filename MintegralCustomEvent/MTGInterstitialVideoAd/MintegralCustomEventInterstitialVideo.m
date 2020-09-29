//
//  MintegralCustomEventInterstitialVideo.m
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralCustomEventInterstitialVideo.h"
#import "MintegralHelper.h"

#if __has_include(<MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>)
    #import <MTGSDK/MTGSDK.h>
    #import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>
#elif __has_include(<MTGSDK/MTGInterstitialVideoAdManager.h>)
    #import <MTGSDK/MTGSDK.h>
    #import <MTGSDK/MTGInterstitialVideoAdManager.h>
#else
    #import "MTGSDK.h"
    #import "MTGInterstitialVideoAdManager.h"
#endif

@interface MintegralCustomEventInterstitialVideo() <MTGInterstitialVideoDelegate>

@property (nonatomic, copy) NSString *adUnit;
@property (nonatomic, copy) NSString *adPlacement;
@property (nonatomic,strong) NSTimer  *queryTimer;
@property (nonatomic, readwrite, strong) MTGInterstitialVideoAdManager *mtgInterstitialVideoAdManager;

@end

@implementation MintegralCustomEventInterstitialVideo
@synthesize delegate;


#pragma mark GADCustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    
    NSDictionary *mintegralInfoDict = [MintegralHelper dictionaryWithJsonString:serverParameter];
    
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
    
    
    if (!_mtgInterstitialVideoAdManager) {
        _mtgInterstitialVideoAdManager = [[MTGInterstitialVideoAdManager alloc] initWithPlacementId:self.adPlacement unitId:self.adUnit delegate:self];
    }
    
    [_mtgInterstitialVideoAdManager loadAd];
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController {

    [_mtgInterstitialVideoAdManager showFromViewController:rootViewController];
}

#pragma mark MVInterstitialVideoAdLoadDelegate implementation

- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialDidReceiveAd:)]) {
        [self.delegate customEventInterstitialDidReceiveAd:self];
    }
}


- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
        NSError *customEventError = [NSError errorWithDomain:customEventErrorDomain code:error.code userInfo:error.userInfo];
        [self.delegate customEventInterstitial:self didFailAd:customEventError];
    }
}

- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWillPresent:)]) {
        [self.delegate customEventInterstitialWillPresent:self];
    }
}

- (void)onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{}


- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWillDismiss:)]) {
        [self.delegate customEventInterstitialWillDismiss:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialDidDismiss:)]) {
        [self.delegate customEventInterstitialDidDismiss:self];
    }
}

- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWasClicked:)]) {
        [self.delegate customEventInterstitialWasClicked:self];
    }
    // todo
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

- (void)checkVideoReady{

}





@end
