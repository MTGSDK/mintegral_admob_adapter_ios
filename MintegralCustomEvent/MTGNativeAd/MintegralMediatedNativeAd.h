//
//  MintegralMediatedNativeAd.h
//  Admob_SampleApp
//
//  Created by Harry on 2020/5/9.
//  Copyright © 2020 Chark. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMobileAds/GADNativeAd.h>


NS_ASSUME_NONNULL_BEGIN

@interface MintegralMediatedNativeAd : NSObject <GADMediatedUnifiedNativeAd>

- (null_unspecified instancetype)init NS_UNAVAILABLE;


- (nullable instancetype)initWithNativeManager:(nonnull  id)nativeManager mtgCampaign:(nonnull id)campaign  withUnitId:(nonnull NSString *)unitId videoSupport:(BOOL)videoSupport NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
