//
//  MintegralMediatedNativeAppInstallAd.h
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MTGSDK/MTGSDK.h>
#import <GoogleMobileAds/GADNativeAppInstallAd.h>


@interface MintegralMediatedNativeAppInstallAd : NSObject<GADMediatedNativeAppInstallAd>

- (null_unspecified instancetype)init NS_UNAVAILABLE;

- (nullable instancetype)initAppInstallAdWithNativeManager:(nonnull MTGNativeAdManager *)nativeManager mtgCampaign:(nonnull MTGCampaign *)campaign  withUnitId:(nonnull NSString *)unitId videoSupport:(BOOL)videoSupport NS_DESIGNATED_INITIALIZER;

@end
