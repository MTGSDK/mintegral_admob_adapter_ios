//
//  MintegralMediatedNativeAd.h
//  Admob_SampleApp
//
//  Created by Harry on 2020/5/9.
//  Copyright © 2020 Chark. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MTGSDK/MTGSDK.h>
#import <GoogleMobileAds/GADNativeAd.h>


NS_ASSUME_NONNULL_BEGIN

@interface MintegralMediatedNativeAd : NSObject <GADMediationNativeAd>

- (null_unspecified instancetype)init NS_UNAVAILABLE;


- (nullable instancetype)initWithNativeManager:(nonnull MTGNativeAdManager *)nativeManager mtgCampaign:(nonnull MTGCampaign *)campaign  withUnitId:(nonnull NSString *)unitId videoSupport:(BOOL)videoSupport  NS_DESIGNATED_INITIALIZER;

@property(nonatomic, weak, nullable)id<GADMediationNativeAdEventDelegate>  adEventDelegate;



@end

NS_ASSUME_NONNULL_END
