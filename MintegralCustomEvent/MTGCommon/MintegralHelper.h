//
//  MintegralHelper.h
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MintegralAdapterVersion  @"5.7.1.0"



static NSString *const kMintegralAdapterErrorDomain = @"com.mintegral.MintegralAdapter";
static NSString *const customEventErrorDomain = @"com.mintegral.CustomEvent";

@interface MintegralHelper : NSObject


+(BOOL)isSDKInitialized;

+(void)sdkInitialized;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+(void)setGDPRInfo:(NSDictionary *)info;





@end
