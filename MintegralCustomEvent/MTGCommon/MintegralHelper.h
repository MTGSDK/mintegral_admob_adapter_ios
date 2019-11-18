//
//  MintegralHelper.h
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MintegralAdapterVersion  @"5.8.4.0"



static NSString *const kMintegralAdapterErrorDomain = @"com.mintegral.MintegralAdapter";
static NSString *const customEventErrorDomain = @"com.mintegral.CustomEvent";

@interface MintegralHelper : NSObject


+(BOOL)isSDKInitialized;

+(void)sdkInitialized;

+(void)consentGDPR:(BOOL)consent;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;






@end
