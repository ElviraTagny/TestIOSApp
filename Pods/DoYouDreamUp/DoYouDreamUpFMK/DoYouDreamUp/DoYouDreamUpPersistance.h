//
//  PersistantInformation.h
//  DoYouDreamUp
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoYouDreamUpPersistance : NSObject

+ (nullable NSString*) clientId;
+ (void) storeClientId:(nullable NSString*)cliendId;

+ (nullable NSString*) contextId ;
+ (void) storeContextId:(nullable NSString*)contextId;

+ (nullable NSString*) screenCode;
+ (void) storeScreenCode:(nullable NSString*)screencode;

+ (nullable NSString*) userID;
+ (void) storeUserID:(nullable NSString*)userID;

+ (BOOL) logEnable;
+ (void) storeLogEnable:(BOOL)isEnable;

@end
