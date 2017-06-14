//
//  EnumToStringHelper.m
//  DoYouDreamUp
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import "DoYouDreamUpEnumHelper.h"

@implementation DoYouDreamUpEnumHelper


+ (NSString*)solutionUsedTypeToString:(ChatSolutionUsedType)formatType {
    NSString *result = nil;
    
    switch(formatType) {
        case Assistant:
            result = @"ASSISTANT";
            break;
        case Livechat:
            result = @"LIVECHAT";
            break;
        case FieldBox:
            result = @"FIELDBOX";
            break;
        case StaticFAQ:
            result = @"STATICFAQ";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected SolutionUsedType FormatType."];
    }
    
    return result;
}


+ (NSString*)dateTypeToString:(PeriodSupported)period {
    NSString *result = nil;
    
    switch(period) {
        case Today:
            result = @"Today";
            break;
        case Yesterday:
            result = @"Yesterday";
            break;
        case Last7days:
            result = @"Last7Days";
            break;
        case Last30days:
            result = @"Last30Days";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected DateType FormatType."];
    }
    
    return result;
}


+ (NSString*)connectionStateToString:(ConnectionState)state {
    NSString *result = nil;
    
    switch(state) {
        case Idle:
            result = @"IDLE";
            break;
        case Connected:
            result = @"CONNECTED";
            break;
        case ConnectedOnBackup:
            result = @"CONNECTED_BACKUP";
            break;
        case Connecting:
            result = @"CONNECTING";
            break;
        case ConnectingOnBackup:
            result = @"CONNECTING_SERVER_BACKUP";
            break;
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected Connection State."];
    }
    
    return result;
}

@end
