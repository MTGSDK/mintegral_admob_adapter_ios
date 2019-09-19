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

+(void)setGDPRInfo:(NSDictionary *)info{
    
    /// authority_all_info
    NSString *authority_all_info = nil;
    if ([info objectForKey:@"authority_all_info"]) {
        authority_all_info = [info objectForKey:@"authority_all_info"];
    }
    if(authority_all_info){
        if([authority_all_info isEqualToString:@"0"]){
            [[MTGSDK sharedInstance] setUserPrivateInfoType:MTGUserPrivateType_ALL agree:NO];
        }else if([authority_all_info isEqualToString:@"1"]){
            [[MTGSDK sharedInstance] setUserPrivateInfoType:MTGUserPrivateType_ALL agree:YES];
        }
    }
    
    /// authority_general_data
    NSString *authority_general_data = nil;
    if ([info objectForKey:@"authority_general_data"]) {
        authority_general_data = [info objectForKey:@"authority_general_data"];
    }
    if(authority_general_data){
        if([authority_general_data isEqualToString:@"0"]){
            [[MTGSDK sharedInstance] setUserPrivateInfoType:MTGUserPrivateType_GeneralData agree:NO];
        }else if([authority_general_data isEqualToString:@"1"]){
            [[MTGSDK sharedInstance] setUserPrivateInfoType:MTGUserPrivateType_GeneralData agree:YES];
        }
    }
    
    /// authority_device_id
    NSString *authority_device_id = nil;
    if ([info objectForKey:@"authority_device_id"]) {
        authority_device_id = [info objectForKey:@"authority_device_id"];
    }
    if(authority_device_id){
        if([authority_device_id isEqualToString:@"0"]){
            [[MTGSDK sharedInstance] setUserPrivateInfoType:MTGUserPrivateType_DeviceId agree:NO];
        }else if([authority_device_id isEqualToString:@"1"]){
            [[MTGSDK sharedInstance] setUserPrivateInfoType:MTGUserPrivateType_DeviceId agree:YES];
        }
    }
    
    /// authority_gps
    NSString *authority_gps = nil;
    if ([info objectForKey:@"authority_gps"]) {
        authority_gps = [info objectForKey:@"authority_gps"];
    }
    if(authority_gps){
        if([authority_gps isEqualToString:@"0"]){
            [[MTGSDK sharedInstance] setUserPrivateInfoType:MTGUserPrivateType_Gps agree:NO];
        }else if([authority_gps isEqualToString:@"1"]){
            [[MTGSDK sharedInstance] setUserPrivateInfoType:MTGUserPrivateType_Gps agree:YES];
        }
    }
    
    MTGUserPrivateTypeInfo *userPrivateTypeInfo = [[MTGSDK sharedInstance] userPrivateInfo];
    NSString *privateInfo = [NSString stringWithFormat: @"isGeneralDataAllowed = %d ,isDeviceIdAllowed = %d ,isGpsAllowed = %d",userPrivateTypeInfo.isGeneralDataAllowed,userPrivateTypeInfo.isDeviceIdAllowed,userPrivateTypeInfo.isGpsAllowed];
    NSLog(@"%@", privateInfo);
}

@end
