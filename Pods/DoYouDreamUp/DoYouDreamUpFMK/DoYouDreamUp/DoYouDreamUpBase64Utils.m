//
//  DoYouDreamUpBase64Utils.m
//  DoYouDreamUp
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import "DoYouDreamUpBase64Utils.h"
#define kKeyType @"type"
#import "MF_Base64Additions.h"

@implementation DoYouDreamUpBase64Utils


+ (NSDictionary *) encodeStringToBase64WithDictionary:(NSDictionary *)dict {
    if (dict == nil || ![dict isKindOfClass:[NSMutableDictionary class]]) return dict;
    
    for (NSString * key in [dict allKeys]) {
        if (![key isEqualToString:kKeyType]) {
            id value = [dict valueForKey:key];
            //NSLog(@"key=%@", key);
            if ([value isKindOfClass:[NSMutableString class]]||[value isKindOfClass:[NSString class]]) {
                NSString * valueString = (NSString *) value;
                NSString * base64String = [valueString base64String];
                [dict setValue:base64String forKey:key];
            }
            else if ([value isKindOfClass:[NSMutableDictionary class]]) {
                NSDictionary * subDictionary = [self encodeStringToBase64WithDictionary:value];
                [dict setValue:subDictionary forKey:key];
            }
        }
    }
    return dict;
}

+ (nullable id) decodeToBase64:(nullable id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        NSString * decodedString = [NSString stringFromBase64String:obj];
        return decodedString;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = obj;
        dict = dict.mutableCopy;
        for (NSString * key in [dict allKeys]) {
            id value = [dict valueForKey:key];
            id valueDecoded = [DoYouDreamUpBase64Utils decodeToBase64:value];
            [dict setValue:valueDecoded forKey:key];
        }
        return dict;
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        NSArray * array = obj;
        NSMutableArray * newArray = [NSMutableArray arrayWithCapacity:array.count];
        for (id item in array) {
            id result = [self decodeToBase64:item];
            [newArray addObject:result];
        }
        return newArray;
    }
    else {
        NSAssert(true, @"Type not supported %@", [obj class]);
    }
    return nil;
}

@end
