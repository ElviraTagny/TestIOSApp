//
//  DoYouDreamUp
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import "DoYouDreamUpNSDictionary+JSONCategories.h"
#import "DoYouDreamUpConstants.h"

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress {
    NSData* data = [NSData dataWithContentsOfURL:
					[NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
												options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON {
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
												options:kNilOptions
												  error:&error];
    if (error == nil) {
		DYDUErrorLog(@"ERROR json encoding %@", error);
		return nil;
	}
    return result;
}


-(NSString*) jsonEncodedKeyValueString {
	
	NSError *error = nil;
	NSData *data = [NSJSONSerialization dataWithJSONObject:self
												   options:kNilOptions
													 error:&error];
	if(error) {
		DYDUErrorLog(@"ERROR json encoding %@", error);
	}
	
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}



@end