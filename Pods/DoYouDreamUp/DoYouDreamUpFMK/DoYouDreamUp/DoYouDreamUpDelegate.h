//
//  DoYouDreamUpDelegate.h
//  DoYouDream
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Protocol that allows to get callback about connection status, receive messages and notifications.
@protocol DoYouDreamUpDelegate <NSObject>




#pragma mark - Lifecycle
///Callback to notify that the connection failed with the given error
///@param error the given error
-(void) dydu_connexionDidFailWithError:(nonnull NSError *)error;

///Callback to notify that the connection closed correctly
-(void) dydu_connexionDidClosed;

///Callback to notify that the connection opened
///@param contextId the contextId used in the current connexion, could be nil at this step for the first login
/// use the dydu_contextIdChanged to get information about changes
-(void) dydu_connexionDidOpenWithContextId:(nullable NSString*)contextId;


@optional

///This method is called each time a valid message is receved
///@param message message received
///@param extraParameters a set of variables including: guiAction, urlRedirect, operatorName, typeResponse. Check the variables inside the values entry at http://doyoudreamup.github.io/servlet-doc/responses/talkResponse.html
-(void) dydu_receivedTalkResponseWithMsg:(nonnull NSString*)message withExtraParameters:(nullable NSDictionary*)extraParameters;

///This method is called when notification is send by the service.
///It can inform about a status change like human operator not available anymore
///@param message the text message
///@param code a code statut you can test on
-(void) dydu_receivedNotification:(nonnull NSString *)message withCode:(nonnull NSString*)code;


///This method is called when we received an answer after an history call.
///@param interactions the content of the history see the format at http://doyoudreamup.github.io/servlet-doc/responses/historyResponse.html
///@param contextId (optional) the contextId reference asked for.
-(void) dydu_history:(nullable NSArray *)interactions forContextId:(nullable NSString*)contextId;

///Callback of the topQuestions call
///@param questions answer format at :http://doyoudreamup.github.io/servlet-doc/responses/topknowledgeResponse.html
///@param tag the tag asked for.
-(void) dydu_topQuestions:(nullable NSArray *)questions withTag:(nullable NSString*)tag;



///Callaback of the survey structure resquest
///@param name Survey name
///@param title Survey title
///@param text Survey description
///@param fields the structure of the survey documentation available here: http://doyoudreamup.github.io/servlet-doc/responses/surveyConfigurationResponse.html
///@param errorMessage optional error message
-(void) dydu_surveyReceivedStructureWithName:(nullable NSString *)name
                                       title:(nullable NSString*)title
                                        text:(nullable NSString *)text
                                      fields:(nullable NSArray *)fields
                                errorMessage:(nullable NSString*)errorMessage;

///Callback that confirme that we sent the survey.
///Limited interested now, cause we don't have a status result
- (void) dydu_surveyPosted;


///The contextIdChanged to a new value
///@param contextId the new value of the contextId
- (void) dydu_contextIdChanged:(nonnull NSString *)contextId;


@end
