//
//  MintegralAdNetworkExtras.h
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GADAdNetworkExtras.h>

@interface MintegralAdNetworkExtras : NSObject<GADAdNetworkExtras>


/*!
 * @brief NSString with user identifier that will be passed if the ad is incentivized.
 * @discussion Optional. The value passed as 'user' in the an incentivized server-to-server call.
 */
@property (nonatomic, copy) NSString *userId;



@end
