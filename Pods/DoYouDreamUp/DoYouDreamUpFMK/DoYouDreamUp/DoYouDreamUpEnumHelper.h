//
//  EnumToStringHelper.h
//  DoYouDreamUp
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import <Foundation/Foundation.h>

/// This class regroups the enumeration used in this DoYouDreamUp project
@interface DoYouDreamUpEnumHelper : NSObject

///@enum Enumeration for Connection State
typedef enum {
    Idle,
    Connecting,
    ConnectingOnBackup,
    Connected,
    ConnectedOnBackup
} ConnectionState;

///@enum ChatSolutionUsedType Enumeration for Solution Used
typedef enum {
    Assistant,
    Livechat,
    FieldBox,
    Vocal,
    StaticFAQ
} ChatSolutionUsedType;

///@enum DateType values
typedef enum {
    Today,
    Yesterday,
    Last7days,
    Last30days
} PeriodSupported;


/// Get the string for the SolutionUsedType
/// @param solution the enum value to get the string value
/// @return the string representing the value
+ (NSString*)solutionUsedTypeToString:(ChatSolutionUsedType)solution;

/// Get the string for the DateType
/// @param period the enum value to get the string value
/// @return the string representing the value
+ (NSString*)dateTypeToString:(PeriodSupported)period;

/// Get the string for the ConnectionState
/// @param state the enum value to get the string value
/// @return the string representing the value
+ (NSString*)connectionStateToString:(ConnectionState)state;




@end
