//
//  MintegralHelper.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralHelper.h"
#import <MTGSDK/MTGSDK.h>

static BOOL mintegralSDKInitialized = NO;

@implementation MintegralHelper

+(BOOL)isSDKInitialized{
    
    return mintegralSDKInitialized;
}

+(void)sdkInitialized{
    
#ifdef DEBUG
    
    if (DEBUG) {
        NSLog(@"The version of current Mintegral Adapter is: %@",MintegralAdapterVersion);
    }
#endif
    
    Class _class = NSClassFromString(@"MTGSDK");
    SEL selector = NSSelectorFromString(@"setChannelFlag:");
    
    NSString *pluginNumber = @"Y+H6DFttYrPQYcIT+F2F+F5/Hv==";
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([_class respondsToSelector:selector]) {
        [_class performSelector:selector withObject:pluginNumber];
    }
    #pragma clang diagnostic pop
    
    mintegralSDKInitialized = YES;
}




+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err == nil && [result isKindOfClass:[NSDictionary class]]) {
        
        return result;
    }
    
    return nil;
}

+(void)consentGDPR:(BOOL)consent{
    if ([[MTGSDK sharedInstance] respondsToSelector:@selector(consentStatus)]) {

        [[MTGSDK sharedInstance] setConsentStatus:consent];
    }
}

@end
