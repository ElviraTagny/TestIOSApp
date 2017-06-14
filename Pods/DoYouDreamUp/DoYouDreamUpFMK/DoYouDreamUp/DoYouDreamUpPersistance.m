//
//  PersistantInformation.m
//  DoYouDreamUp
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import "DoYouDreamUpPersistance.h"

#define kKeyUserDefaultClientUniqueIdentifier @"DYDU_UniversalUniqueIdentifier"
#define kKeyUserDefaultContextID @"DYDU_ContextID"
#define kKeyUserDefaultScreenCode @"DYDU_ScreenCode"
#define kKeyUserDefaultUserID @"DYDU_UserID"
#define kKeyLogEnable @"DYDU_log_enable"
@implementation DoYouDreamUpPersistance

+ (nullable NSString*) clientId {
    return [DoYouDreamUpPersistance userDefaultStringForKey:kKeyUserDefaultClientUniqueIdentifier];
}
+ (void) storeClientId:(nullable NSString*)cliendId {
    [DoYouDreamUpPersistance storeObject:cliendId forKey:kKeyUserDefaultClientUniqueIdentifier];
}



+ (nullable NSString*) contextId {
   return [DoYouDreamUpPersistance userDefaultStringForKey:kKeyUserDefaultContextID];
}

+ (void) storeContextId:(nullable NSString*)contextId {
    [DoYouDreamUpPersistance storeObject:contextId forKey:kKeyUserDefaultContextID];
}



+ (nullable NSString*) screenCode {
    return [DoYouDreamUpPersistance userDefaultStringForKey:kKeyUserDefaultScreenCode];
}

+ (void) storeScreenCode:(nullable NSString*)screencode {
    [DoYouDreamUpPersistance storeObject:screencode forKey:kKeyUserDefaultScreenCode];
}

+ (nullable NSString*) userID {
    return [DoYouDreamUpPersistance userDefaultStringForKey:kKeyUserDefaultUserID];
}

+ (void) storeUserID:(nullable NSString*)userID {
    [DoYouDreamUpPersistance storeObject:userID forKey:kKeyUserDefaultUserID];
}

+ (nullable NSString*) userDefaultStringForKey:(NSString*)key {
    NSUserDefaults *standardUserDefault = [NSUserDefaults standardUserDefaults];
    NSString * screenCode = [standardUserDefault objectForKey:key];
    return screenCode;
}

+ (BOOL) userDefaultBoolForKey:(NSString*)key {
    NSUserDefaults *standardUserDefault = [NSUserDefaults standardUserDefaults];
    NSNumber * val = [standardUserDefault objectForKey:key];
    if (val == nil) return NO;
    else return [val boolValue];
}

+ (void) storeObject:(nullable id)value forKey:(nonnull NSString*)key {
    NSUserDefaults *standardUserDefault = [NSUserDefaults standardUserDefaults];
    [standardUserDefault setObject:value forKey:key];
    [standardUserDefault synchronize];
}

+ (BOOL) logEnable {
    return [DoYouDreamUpPersistance userDefaultBoolForKey:kKeyLogEnable];
}

+ (void) storeLogEnable:(BOOL)isEnable {
    [DoYouDreamUpPersistance storeObject:@(isEnable) forKey:kKeyLogEnable];
}


@end
