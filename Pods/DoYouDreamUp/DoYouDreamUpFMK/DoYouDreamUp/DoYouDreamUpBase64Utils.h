//
//  DoYouDreamUpBase64Utils.h
//  DoYouDreamUp
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoYouDreamUpBase64Utils : NSObject

+ (nullable NSDictionary *) encodeStringToBase64WithDictionary:(nullable NSDictionary *)dict;
//+ (nullable NSDictionary *) decodeStringToBase64WithDictionary:(nullable NSDictionary *)dict;
+ (nullable id) decodeToBase64:(nullable id)obj;

@end
