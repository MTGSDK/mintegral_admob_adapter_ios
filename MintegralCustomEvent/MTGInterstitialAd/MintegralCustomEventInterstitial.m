//
//  MintegralCustomEventInterstitial.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralCustomEventInterstitial.h"
#import <MTGSDKInterstitial/MTGInterstitialAdManager.h>
#import <MTGSDK/MTGSDK.h>

#import "MintegralHelper.h"


@interface MintegralCustomEventInterstitial () <MTGInterstitialAdLoadDelegate,MTGInterstitialAdShowDelegate>

/// The Mintegral Ad Network interstitial.
@property(nonatomic, strong) MTGInterstitialAdManager *interstitialAd;

@end

@implementation MintegralCustomEventInterstitial

@synthesize delegate;

#pragma mark GADCustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    
    NSDictionary *mintegralintegralInfoDict = [MintegralHelper dictionaryWithJsonString:serverParameter];
    
    NSString *appId = nil;
    if ([mintegralintegralInfoDict objectForKey:@"appId"]) {
        appId = [mintegralintegralInfoDict objectForKey:@"appId"];
    }
    
    NSString *appKey = nil;
    if ([mintegralintegralInfoDict objectForKey:@"appKey"]) {
        appKey = [mintegralintegralInfoDict objectForKey:@"appKey"];
    }

    NSString *InterstitialAdUnitId = nil;
    if ([mintegralintegralInfoDict objectForKey:@"unitId"]) {
        InterstitialAdUnitId = [mintegralintegralInfoDict objectForKey:@"unitId"];
    }

    NSString *consentGDPR = [mintegralintegralInfoDict objectForKey:@"consent"];
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
    
    MTGInterstitialAdCategory adCategory = MTGInterstitial_AD_CATEGORY_ALL;
    if ([mintegralintegralInfoDict objectForKey:@"adCategory"]) {
        NSString *category = [NSString stringWithFormat:@"%@",[mintegralintegralInfoDict objectForKey:@"adCategory"]];
        adCategory = (MTGInterstitialAdCategory)[category integerValue];
    }
    
    if (!_interstitialAd) {
        _interstitialAd = [[MTGInterstitialAdManager alloc] initWithUnitID:InterstitialAdUnitId adCategory:adCategory];
    }
    
    [_interstitialAd loadWithDelegate:self];
    
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController {

    [_interstitialAd showWithDelegate:self presentingViewController:rootViewController];
}

#pragma mark MVInterstitialAdManagerDelegate implementation
- (void) onInterstitialLoadSuccess{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialDidReceiveAd:)]) {
        [self.delegate customEventInterstitialDidReceiveAd:self];
    }
}

- (void) onInterstitialLoadFail:(nonnull NSError *)error{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
        NSError *customEventError = [NSError errorWithDomain:customEventErrorDomain code:error.code userInfo:error.userInfo];
        [self.delegate customEventInterstitial:self didFailAd:customEventError];
    }
}

- (void) onInterstitialShowSuccess{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWillPresent:)]) {
        [self.delegate customEventInterstitialWillPresent:self];
    }
}

- (void) onInterstitialShowFail:(nonnull NSError *)error{
    
}

- (void) onInterstitialClosed{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWillDismiss:)]) {
        [self.delegate customEventInterstitialWillDismiss:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialDidDismiss:)]) {
        [self.delegate customEventInterstitialDidDismiss:self];
    }
}

- (void) onInterstitialAdClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWasClicked:)]) {
        [self.delegate customEventInterstitialWasClicked:self];
    }
}


@end
