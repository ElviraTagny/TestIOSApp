//
//  DYDUCommunicatorWebSocket.h
//  DoYouDream
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoYouDreamUpDelegate.h"
#import "DoYouDreamUpEnumHelper.h"


/// @class DoYouDreamUpManager
/// @discussion  This class is the heart of DoYouDreamUpManager SDK
/// Start by using the configureWithDelegate method and provide a delegate that implement the protocol DoYouDreamUpDelegate
/// to handle the connection success/error and message callback.
@interface DoYouDreamUpManager : NSObject//SRWebSocketDelegate

#pragma mark - Init
/// @name Init

/// Singleton access of the DoYouDreamUp fmk
/// @return The singleton instance
+(nonnull DoYouDreamUpManager*)sharedInstance;

/// Configure your instance
///
/// @param delegate the delegate that will handle the callback
/// @param botID your application bot ID
/// @param consultationSpace optionnal, provide a space. If nil, "Default" will be used.
/// @param aLanguage provide the current language used to discuss (fr, en)
/// @param testMode true if you are testing
/// @param solution enum of type @see ChatSolutionUsedType
/// @param isPureLiveChat use the service with a live chat operator or not
/// @param url the url to the server
/// @param backupUrl the url to the backup server (optional)
- (void) configureWithDelegate:(nullable id<DoYouDreamUpDelegate>)delegate
                         botId:(nonnull NSString*)botID
                         space:(nullable NSString *)consultationSpace
                      language:(nonnull NSString *)aLanguage
                      testMode:(BOOL)testMode
                  solutionUsed:(ChatSolutionUsedType)solution
                  pureLivechat:(BOOL)isPureLiveChat
                     serverUrl:(nonnull NSString*)url
               backupServerUrl:(nullable NSString*)backupUrl;


#pragma mark - Instance Methods
/// @name Instance Methods

/// Define the language of the app
/// @param language is the new language to be define on 2 chars (ex: fr)
- (void) setLanguage:(nonnull NSString *)language;

/// Define a consultation space.
/// @param space the space to define. If nil, "Default" will be used
- (void) setConsultationSpace:(nullable NSString *)space;

#pragma mark - Connection
/// @name Connection

/// Connect to the chat service
/// @return false if already connected or configuration error, true otherwise 
-(BOOL) connect;

/// Disconnect to the serveur
-(void) disconnect;

/// Check if there is a current connection
/// @return false if the server is not connected
-(BOOL) isConnected;

#pragma mark - Talk
/// @name Talk

/// Send a question. The answer is provided by the delegate @see [DoYouDreamUpDelegate dydu_receivedTalkResponseWithMsg:withExtraParameters:]
/// @return false if the server is not connected
/// @param message the message to send
-(BOOL) talk:(nonnull NSString*)message;

/// Send a question
/// The answer is provided by the delegate @see [DoYouDreamUpDelegate dydu_receivedTalkResponseWithMsg:withExtraParameters:]
/// @param message the message to send
/// @param parameters provide contextual information from user actions
/// @return false if the server is not connected
-(BOOL) talk:(nonnull NSString*)message extraParameters:(nullable NSDictionary *)parameters;

#pragma mark TalkExtra
/// @name TalkExtra


/// User is on a specific screen. This information is persisted,
/// you have to change it for each new screen before calling the talk command
/// @param currentScreenCode the current screen to have context information
-(void) userIsOnScreenCode:(nonnull NSString*)currentScreenCode;

/// Set or delete a variable for the current session
/// @param name the name of the variable (key)
/// @param value the value if empty or nil it will remove the variable
/// @return false if the server is not connected
- (BOOL) defineVariableName:(nonnull NSString*)name withValue:(nullable NSString*)value;

/// Define what the user is typing
///@param content that the user is currently typing.
///@return false if the action cannot be performed
-(BOOL) userTypingContent:(nullable NSString*)content;


#pragma mark - History
/// @name History

/// Get the history for a specific discussion(ie contextId)
/// The answer is provided by the delegate @see [DoYouDreamUpDelegate dydu_history:forContextId:]
/// @param contextId a specific contextId to get the history
/// @return false if the server is not connected
-(BOOL) historyWithContextId:(nullable NSString*)contextId;

/// Get the history for the current contextID.
/// The answer is provided by the delegate @see [DoYouDreamUpDelegate dydu_history:forContextId:]
/// @return false if the server is not connected
-(BOOL) history;



#pragma mark - WelcomeCall
/// @name WelcomeCall

/// Trigger a welcome for statistique purpose
-(BOOL) welcomecall;




#pragma mark - Survey
/// @name Survey

/// Get the survey structure for a provided id
/// The answer is provided by the delegate @see [DoYouDreamUpDelegate dydu_surveyReceivedStructureWithName:title:text:fields:errorMessage:]
/// @param surveyId the identifier of the survey you want to retreive information
/// @return false if the server is not connected
- (BOOL) surveyGetStructureWithId:(nonnull NSString*)surveyId;

/// Post the survey answers
/// The confirmation is provided by the delegate @see [DoYouDreamUpDelegate dydu_surveyPosted]
/// @param answers is a dictionary with you answers key is the id of the field and the value contains the data
/// @param surveyId is the identifier of the survey
/// @return false if the server is not connected
- (BOOL) surveyPostAnswers:(nonnull NSDictionary*)answers forId:(nonnull NSString*)surveyId;


#pragma mark - Feeback - deprecated used Survey instead
/// @name Feedback

/// Send a feedback with satisfaction return.
/// @param satisfied true if satisfied, false if not satisfied
/// @return false if the server is not connected
/// @deprecated please use surveyGetStructureWithId
-(BOOL) feedbackWithSatisfaction:(BOOL)satisfied __attribute__((deprecated));

/// Send a feedback with a reason of insatisfaction
/// @param codeInsatisfactionReason the code a integer from 0 to 3
/// @return false if the server is not connected
/// @deprecated please use surveyGetStructureWithId
-(BOOL) feedbackInsatisfactionReason:(int) codeInsatisfactionReason __attribute__((deprecated));

/// Send a feedback with a comment
/// @param comment a feedback
/// @return false if the server is not connected
/// @deprecated please use surveyGetStructureWithId
-(BOOL) feedbackWithComment:(nonnull NSString*)comment __attribute__((deprecated));

#pragma mark - Top Questions (top knowledge)
/// @name Top Questions

/// Get the top questions asked for the given parmeters
/// The answer is provided by the delegate @see [DoYouDreamUpDelegate dydu_topQuestions:withTag:]
/// @param period the period to filter
/// @param maxItems the number of max number of result
/// @return false if the server is not connected
- (BOOL) topQuestionsForPeriod:(PeriodSupported)period maxItems:(int)maxItems;

/// Get the top questions asked for the given parmeters
/// The answer is provided by the delegate @see [DoYouDreamUpDelegate dydu_topQuestions:withTag:]
/// @param period the period to filter
/// @param tag the tag filter. An empty string means any tag. Otherwise, it should be an existing tag name
/// @param maxItems the number of max number of result
/// @return false if the server is not connected
- (BOOL) topQuestionsForPeriod:(PeriodSupported)period tag:(nullable NSString*)tag maxItems:(int)maxItems;

/// Get the top questions asked for the given parmeters
/// The answer is provided by the delegate @see [DoYouDreamUpDelegate dydu_topQuestions:withTag:]
/// @param period the period to filter
/// @param tag the tag filter. An empty string means any tag. Otherwise, it should be an existing tag name
/// @param maxItems the number of max number of result
/// @param includeTagChildren if true results from children tags are included
/// @param ignoreManualContent if true results from manual content is ignored otherwise not
/// @return false if the server is not connected
- (BOOL) topQuestionsForPeriod:(PeriodSupported)period
                           tag:(nullable NSString*)tag
                      maxItems:(int)maxItems
            includeTagChildren:(BOOL)includeTagChildren
           ignoreManualContent:(BOOL)ignoreManualContent;


#pragma mark - Class methods
/// @name Class methods

/// The userId allows to identify a user, optional and by default to nil for an anonymous session.
/// This value is persisted over time
/// @param userID the string that allows to identify the user
+ (void) setUserID:(nullable NSString *)userID;

///Get the last used contextId available.
///@return the string, nil if no exchanges made.
+ (nullable NSString*) contextId;

/// Reset the contextID, we'll generate a new one contextId at the next talk
+ (void)resetContextId;

///Enable or disable the frameworks logs (basic mode on/off very verbose)
///@param isEnabled enable some extra information about the sdk, by default only the error are displayed
+ (void) displayLog:(BOOL)isEnabled;

@end
