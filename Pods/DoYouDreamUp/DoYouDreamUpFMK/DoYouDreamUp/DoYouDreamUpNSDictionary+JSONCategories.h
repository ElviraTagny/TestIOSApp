//
//  NSDictionary+JSONCategories.h
//  DoYouDream
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary(JSONCategories)

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;
-(NSString*) jsonEncodedKeyValueString;

@end
