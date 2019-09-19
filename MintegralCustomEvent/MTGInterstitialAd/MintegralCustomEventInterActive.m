//
//  MintegralCustomEventInterActive.m
//  MediationExample
//
//  Copyright © 2018年 Mintegral. All rights reserved.
//

#import "MintegralCustomEventInterActive.h"
#import <MTGSDKInterActive/MTGInterActiveManager.h>
#import <MTGSDK/MTGSDK.h>

#import "MintegralHelper.h"


@interface MintegralCustomEventInterActive () < MTGInterActiveDelegate >

 
@property(nonatomic, strong) MTGInterActiveManager *interActiveAd;

@end

@implementation MintegralCustomEventInterActive
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

    NSString *interActiveAdUnitId = nil;
    if ([mintegralintegralInfoDict objectForKey:@"unitId"]) {
        interActiveAdUnitId = [mintegralintegralInfoDict objectForKey:@"unitId"];
    }
    
    if (![MintegralHelper isSDKInitialized]) {
        
        [MintegralHelper setGDPRInfo:mintegralintegralInfoDict];
        //init SDK
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralHelper sdkInitialized];
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    
    if (!_interActiveAd) {
        _interActiveAd = [[MTGInterActiveManager alloc] initWithUnitID:interActiveAdUnitId withViewController:vc];
        
        _interActiveAd.delegate = self;
    }
    
    [_interActiveAd loadAd];
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController {

    [_interActiveAd showAd];
}

#pragma mark MVIntersActiveAdManagerDelegate implementation

- (void) onInterActiveLoadSuccess:(MTGInterActiveResourceType)resourceType adManager:(MTGInterActiveManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialDidReceiveAd:)]) {
        [self.delegate customEventInterstitialDidReceiveAd:self];
    }
}

- (void) onInterActiveLoadFailed:(nonnull NSError *)error adManager:(MTGInterActiveManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
        NSError *customEventError = [NSError errorWithDomain:customEventErrorDomain code:error.code userInfo:error.userInfo];
        [self.delegate customEventInterstitial:self didFailAd:customEventError];
    }
}

- (void) onInterActiveShowSuccess:(MTGInterActiveManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWillPresent:)]) {
        [self.delegate customEventInterstitialWillPresent:self];
    }
}

- (void) onInterActiveShowFailed:(nonnull NSError *)error adManager:(MTGInterActiveManager *_Nonnull)adManager{
    
}

- (void) onInterActiveAdDismissed:(MTGInterActiveManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWillDismiss:)]) {
        [self.delegate customEventInterstitialWillDismiss:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialDidDismiss:)]) {
        [self.delegate customEventInterstitialDidDismiss:self];
    }
}

- (void) onInterActiveAdClick:(MTGInterActiveManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWasClicked:)]) {
        [self.delegate customEventInterstitialWasClicked:self];
    }
}


@end
