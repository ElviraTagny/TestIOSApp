//
//  DYDUCommunicator.m
//  DoYouDream
//
//  Copyright (c) 2016 Do You Dream Up. All rights reserved.
//

#import "DoYouDreamUpManager.h"
#import <UIKit/UIDevice.h>
#import "DoYouDreamUpNSDictionary+JSONCategories.h"
#import "DoYouDreamUpConstants.h"
#import "DoYouDreamUpBase64Utils.h"
#import "DoYouDreamUpPersistance.h"
#import <Base64/MF_Base64Additions.h>
#import <SocketRocket/SRWebSocket.h>

//Constants
#define kConstantDefaultSpace @"Defaut"
#define kConstantIOS @"ios"
#define KConstantWebsocket @"WebSocket"
#define kTimeOutGetConnexion 4//in secondes
#define kErrorConnectionNotOpened @"Message sent before connexion opened"


//Server information
#define kProtocol @"dyduchat"

//Static keys
#define kKeyParameters @"parameters"
#define kKeyType @"type"
#define kKeyUserInput @"userInput"
#define kKeyContextID @"contextId"
#define kKeySpace @"space"
#define kKeyLanguage @"language"
#define kKeyUserId @"userId"
#define kKeyQualificationMode @"qualificationMode"
#define kKeyOS @"os"
#define kKeyBotId @"botId"
#define kKeyFeedback @"feedback"
#define kKeyFeedbackChoiceKey @"choiceKey"
#define kKeyFeedbackCommentKey @"comment"
#define kKeyTyping @"typing"
#define kKeyVariables @"variables"
#define kKeyUserUrl @"userUrl"
#define kKeySolutionUsed @"solutionUsed"
#define kKeyMode @"mode"
#define kKeyContextType @"contextType"//(Web, Android, iOS)
#define kKeyValuesField @"values"
#define kKeyContent @"content"
#define kKeyDialog @"dialog"
#define kKeyAlreadyCame @"alreadyCame"
#define kKeyDisableLanguageDetection @"disableLanguageDetection"
#define kKeyPureLiveChat @"pureLivechat"
#define kKeyOperator @"operator"
#define kkeySurveyId @"surveyId"
#define kkeySurveyInteractionSurveyAnswer @"interactionSurveyAnswer"
#define kkeyFields @"fields"
#define kkeyClientId @"clientId"

//Message types
#define kTypeTalk @"talk"
#define kTypeTalkResponse @"talkResponse"
#define kTypeHistory @"history"
#define kTypeHistoryResponse @"historyResponse"
#define kTypeFeedback @"feedback"
#define kTypeFeedbackInsatisfactionChoice @"feedbackInsatisfactionChoice"
#define kTypeFeedbackComment @"feedbackComment"
#define kTypeWelcomeCall @"welcomecall"
#define kTypeTyping @"typing"
#define kTypeNotification @"notification"
#define kTypeSurvey @"survey"
#define kTypeSurveyConfiguration @"surveyConfiguration"
#define kTypeSurveyResponse @"surveyResponse"
#define kTypeSurveyConfigurationResponse @"surveyConfigurationResponse"
#define kTypeSurveyConfigurationErrorResponse @"surveyConfigurationErrorResponse"
#define kTypeSetOrDeleteVariable @"setOrDeleteVariable"
#define kTypeTopknowledge @"topknowledge"
#define kTopKnowledgeResponse @"topKnowledgeResponse"
#define kTypeServerAccessibility @"serverAccessibility"
#define kTypeServerAccessibilityResponse @"serverAccessibilityResponse"
#define kTypeSurveyResponseError @"errorResponse"



@interface DoYouDreamUpManager()
@property (nonatomic, strong) SRWebSocket* wssocket;//read in doc

/// Server URL ex: "wss://jp.createmyassistant.com/servlet/chat"
@property (strong, nonatomic) NSString * serverURL;

/// Server URL for backup relay
@property (strong, nonatomic) NSString * serverURLBackup;

/// The botID
@property (strong, nonatomic) NSString * botID;
/// The space of consultation (nil by default).
@property (strong, nonatomic) NSString * space;
/// The language to use for the response. Format is fr, en, nl
@property (strong, nonatomic) NSString * language;
/// Is it a test mode
@property (nonatomic) BOOL testMode;
/// The delegate that will implement the callback methods
@property (nonatomic, assign) id <DoYouDreamUpDelegate> delegate;
@property (nonatomic) ConnectionState connectionState;
@property (nonatomic) unsigned int retryCount;
@property (nonatomic) ChatSolutionUsedType solutionUsed;
@property (nonatomic) BOOL isPureLiveChat;

//Backup
@property (atomic, strong) NSTimer * timerConnexionContext;

@end

@implementation DoYouDreamUpManager

#pragma mark -
#pragma mark Init

+(DoYouDreamUpManager*)sharedInstance {
    static DoYouDreamUpManager *_sharedInstance = nil;
    
    @synchronized(self) {
        if (_sharedInstance == NULL)
            _sharedInstance = [[self alloc] init];
    }
    
    return _sharedInstance;
}



-(void) dealloc {
    self.wssocket=nil;
    self.botID=nil;
    self.space=nil;
    self.language=@"en";
    self.serverURL=nil;
}


//pureLivechat et solutionUsed sdk level ?
-(void) configureWithDelegate:(id<DoYouDreamUpDelegate>)delegate
                        botId:(nonnull NSString*)botID
                        space:(nullable NSString *)space
                     language:(nonnull NSString *)language
                     testMode:(BOOL)testMode
                 solutionUsed:(ChatSolutionUsedType)solution
                 pureLivechat:(BOOL)isPureLiveChat
                    serverUrl:(nonnull NSString*)url
              backupServerUrl:(nullable NSString*)backupUrl {
    
    //Backup retry
    self.connectionState = Idle;
    self.retryCount = 0;
    
    //check
    if (IsEmpty(language)) DYDUErrorLog(@"Error language parameter is empty");
    if (IsEmpty(url))      DYDUErrorLog(@"Error url is empty");
    
    //setter
    self.botID = [botID copy];
    self.space = [space copy];
    if (self.space == nil) {
        self.space = kConstantDefaultSpace;
    }
    self.language = [language copy];
    self.testMode = testMode;
    self.serverURL = [url copy];
    self.serverURLBackup = [backupUrl copy];
    self.solutionUsed = solution;
    self.isPureLiveChat = isPureLiveChat;
    
    self.delegate = delegate;
}


+ (void) displayLog:(BOOL)isEnabled {
    [DoYouDreamUpPersistance storeLogEnable:isEnabled];
}


#pragma mark - Methods

+ (void) setUserID:(nullable NSString *)userID {
    [DoYouDreamUpPersistance storeUserID:userID];
}

- (BOOL) hasBackupServer {
    if (IsEmpty(self.serverURLBackup)) return NO;
    return YES;
}

-(BOOL) connect {
    if (![self isConnected]) {
        DYDUDebugLog(@"Connecting to %@", self.serverURL);
        self.connectionState = Connecting;
        return [self connectServerWithUrl:self.serverURL];
    }
    DYDUWarningLog(@"connect : Already connected");

    return false;
}

//Private internal method for relay on backup server
-(BOOL) connectWithBackupServer {
    // if (![self isConnected]) {
    
    if (![self hasBackupServer]) {
        DYDUWarningLog(@"No serveur backup URL provided");
        return NO;
    }
    
    DYDUDebugLog(@"Connecting with backup server to %@", self.serverURLBackup);
    self.connectionState = ConnectingOnBackup;
    
    return [self connectServerWithUrl:self.serverURLBackup];
}


- (void) triggerTimerConnexionContext {
    DYDUDebugLog(@"triggerTimerConnexionContext");
    self.timerConnexionContext = [NSTimer scheduledTimerWithTimeInterval:kTimeOutGetConnexion
                                                           target:self
                                                         selector:@selector(switchServer)
                                                         userInfo:nil
                                                          repeats:NO];
    //[self.timerConnexionContext fire];
}

- (void) invalidateConnexionTimer {
    if (self.timerConnexionContext !=nil) {
        [self.timerConnexionContext invalidate];
        self.timerConnexionContext = nil;
    }
}


//We connected with success to the server but we can't reach the getConnect method in defined delay (4s)
//This method is handling a switch to the backup server if we are currently in state CONNECTION_STATE_CONNECTING otherwise
//we call connexionDidFailWithError with a -57 code corresponding to a getconnexion timeout connection
- (void)switchServer {
    DYDUErrorLog(@"checkTimerExpired with connection state = %@",[DoYouDreamUpEnumHelper connectionStateToString:self.connectionState]);
    if ( self.timerConnexionContext == nil || ![self.timerConnexionContext isValid]) { return; }
    
    DYDUErrorLog(@"checkTimerExpired - timer is valide");
    [self invalidateConnexionTimer];

    if (self.connectionState==Connected && [self hasBackupServer]) {
        //[self disconnect];//we are connected but can't call the method getConnect because of the callback
        DYDUWarningLog(@"Timeout to reach getConnect with main server occured, connect with backup server");
        [self connectWithBackupServer];
        return;
    }
   
    
    NSString * errorMessage = nil;
    
    if (self.connectionState==ConnectedOnBackup) {
        errorMessage=NSLocalizedString(@"Timeout on AvailabilityService on backup server. Connexion failure.", nil);
    }
    else if (self.connectionState==Connected && ![self hasBackupServer] ) {
        //[self disconnect];//we are connected but can't call the method getConnect
        errorMessage=NSLocalizedString(@"Timeout on AvailabilityService and no backup server defined. Connexion failure.", nil);
    }
    else {
        DYDUDebugLog(@"TimerExpired - current STATE with timerExpired %ld", (long)self.connectionState);
    }

    
    if (errorMessage != nil && [self.delegate respondsToSelector:@selector(dydu_connexionDidFailWithError:)]) {
        
        DYDUErrorLog(@"%@",errorMessage);

        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: errorMessage,
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The server connexion timed out.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning wifi off and on again?", nil)
                                   };
        NSError *error = [NSError errorWithDomain:@"NSDYDPErrorDomain" code:-57 userInfo:userInfo];
        [self.delegate performSelector:@selector(dydu_connexionDidFailWithError:) withObject:error];
    }
}

//private
- (BOOL) connectServerWithUrl:(NSString*)serverUrl {
    
    if (IsEmpty(serverUrl)) {
        DYDUErrorLog(@"serverURL not defined");
        return FALSE;
    }
    
    //protection
    if (self.wssocket != nil) {
        self.wssocket.delegate = nil;
    }
    
    self.wssocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:serverUrl] protocols:[self protocols]];
    
    self.wssocket.delegate = (id <SRWebSocketDelegate>)self;
    
    [self.wssocket open];
    
    return YES;
}


- (void) disconnect {
    if ([self isConnected]) {
        [self.wssocket close];
        
    }
    self.timerConnexionContext = nil;
    self.connectionState = Idle;
    self.wssocket = nil;
}


-(BOOL) isConnected {
    if (self.wssocket.readyState == SR_OPEN) {
        return YES;
    }
    else return NO;
}





















#pragma mark -
#pragma mark Public methods

#pragma mark Welcomecall

-(BOOL) welcomecall {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    
    NSString * jsonTextToSend = [self prepareWelcomeCall];
    [self.wssocket send:jsonTextToSend];
    
    return YES;
}

#pragma mark UserTyping

-(BOOL) userTypingContent:(nullable NSString*)content {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    content = [content copy];
    
    //we deduce the isTyping according to the content
    BOOL isTyping = true;
    if (IsEmpty(content)) isTyping = false;

    NSString * jsonTextToSend = [self prepareTypingMessage:content isTyping:isTyping];
    [self.wssocket send:jsonTextToSend];
    
    return YES;
}

#pragma mark History
-(BOOL) history {
    return [self historyWithContextId:nil];
}

-(BOOL) historyWithContextId:(nullable NSString*)contextId {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    
    if (IsEmpty(contextId)) {
        contextId = [DoYouDreamUpManager contextId];
    }

    NSString * jsonTextToSend = [self prepareHistoryWithContextId:contextId];
    [self.wssocket send:jsonTextToSend];
    return YES;
}

#pragma mark topQuestions - topKnowledge

- (BOOL) topQuestionsForPeriod:(PeriodSupported)period maxItems:(int)maxItems {
    return [self topQuestionsForPeriod:period
                                   tag:nil
                              maxItems:maxItems
                    includeTagChildren:NO
                   ignoreManualContent:NO];
}

- (BOOL) topQuestionsForPeriod:(PeriodSupported)period tag:(nullable NSString*)tag maxItems:(int)maxItems {
    return [self topQuestionsForPeriod:period
                                   tag:tag
                              maxItems:maxItems
                    includeTagChildren:NO
                   ignoreManualContent:NO];
}

- (BOOL) topQuestionsForPeriod:(PeriodSupported)period
                           tag:(nullable NSString*)tag
                      maxItems:(int)maxItems
            includeTagChildren:(BOOL)includeTagChildren
           ignoreManualContent:(BOOL)ignoreManualContent {
    
    
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    
    DYDUDebugLog(@"topknowledge");
    
    
    
    
    NSString * jsonTextToSend = [self prepareTopKnowledgeWithTag:tag
                                              includeTagChildren:includeTagChildren
                                        ignoreManualTopKnowledge:ignoreManualContent
                                                    maxItems:maxItems
                                                      withPeriod:[DoYouDreamUpEnumHelper dateTypeToString:period]];
    
    
    [self.wssocket send:jsonTextToSend];
    return YES;
    
}





#pragma mark setOrDeleteVariable
- (BOOL) defineVariableName:(nonnull NSString*)name withValue:(nullable NSString*)value {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    
    if (IsEmpty(name)) {
        DYDUErrorLog("defineVariableName - parameter name is empty");
        return FALSE;
    }
    if (value == nil) value = @"";//delete case
    name = [name copy];
    value = [value copy];
    
    DYDUDebugLog(@"setOrDeleteVariable");
    NSString * jsonTextToSend = [self prepareSetOrDeleteVariableName:name withValue:value];
    [self.wssocket send:jsonTextToSend];
    return YES;
}

#pragma mark ServerAccessibility

-(BOOL) callServerAccessibility {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    DYDUDebugLog(@"testServerAccessibility calling");
    
    NSString * jsonTextToSend = [self prepareServerAccessibility];
    [self.wssocket send:jsonTextToSend];
    return YES;
}

#pragma mark Talk

-(void) userIsOnScreenCode:(nonnull NSString*)currentScreenCode {
    DYDUDebugLog(@"Defining screen to %@",currentScreenCode);
    [DoYouDreamUpPersistance storeScreenCode:currentScreenCode];
}

- (nonnull NSString *) currentScreenCode {
    NSString * screenCode = [DoYouDreamUpPersistance screenCode];
    if (!IsEmpty(screenCode)) return screenCode;
    else {
        DYDUWarningLog(@"Current screen code not defined");
        return @"";
    }
}


- (BOOL)talk:(nonnull NSString*)message {
    return [self talk:message
       withScreenCode:[self currentScreenCode]
      extraParameters:nil
disableLanguageDetection:NO];
}


-(BOOL) talk:(nonnull NSString*)message extraParameters:(nullable NSDictionary *)parameters {
    return [self talk:message
       withScreenCode:[self currentScreenCode]
      extraParameters:parameters
disableLanguageDetection:NO];
}

-(BOOL) talk:(nonnull NSString*)message
withScreenCode:(nullable NSString*)currentScreenCode
extraParameters:(nullable NSDictionary *)parameters
disableLanguageDetection:(BOOL)disableLanguage {
    
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    
    message = [message copy];
    currentScreenCode = [currentScreenCode copy];
    NSString * jsonTextToSend = [self prepareTalk:message
                                       screenCode:currentScreenCode
                                       parameters:parameters
                         disableLanguageDetection:disableLanguage pureLiveChat:self.isPureLiveChat];
    
    
    [self.wssocket send:jsonTextToSend];
    return YES;
}






- (BOOL) surveyGetStructureWithId:(nonnull NSString*)surveyId {
    
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    if (IsEmpty(surveyId)) {
        DYDUErrorLog("surveyConfigurationWithId - Empty parameters errors");
        return FALSE;
    }
    
    surveyId = [surveyId copy];
    NSString * jsonTextToSend = [self prepareSurveyConfiguration:surveyId];
    [self.wssocket send:jsonTextToSend];
    return YES;
}

- (BOOL) surveyPostAnswers:(nonnull NSDictionary*)answers forId:(nonnull NSString*)surveyId {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    
    if (IsEmpty(surveyId)) {
        DYDUErrorLog("SurveyWithId - Empty parameters errors");
        return FALSE;
    }
    
    //interactionSurveyAnswer !isLiveChat
    NSString * jsonTextToSend = [self prepareSurvey:surveyId
                                        withAnswers:answers
                            interactionSurveyAnswer:!self.isPureLiveChat];
    [self.wssocket send:jsonTextToSend];
    return YES;
}


#pragma mark Feedback

-(BOOL) feedbackWithSatisfaction:(BOOL)isSatisfied {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    
    NSString * message = @"positive";
    if (!isSatisfied) {
        message = @"negative";
    }
    
    NSString * jsonTextToSend = [self prepareFeedbackType:kTypeFeedback withContent:message];
    [self.wssocket send:jsonTextToSend];
    return YES;
}

-(BOOL) feedbackInsatisfactionReason:(int) codeInsatisfactionReason {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    NSString * message = [NSString stringWithFormat:@"%d",codeInsatisfactionReason];
    NSString * jsonTextToSend = [self prepareFeedbackType:kTypeFeedbackInsatisfactionChoice withContent:message];
    [self.wssocket send:jsonTextToSend];
    return YES;
}

-(BOOL) feedbackWithComment:(nonnull NSString*)comment {
    if (![self isConnected]) {
        DYDUErrorLog(kErrorConnectionNotOpened);
        return FALSE;
    }
    NSString * jsonTextToSend = [self prepareFeedbackType:kTypeFeedbackComment withContent:comment];
    [self.wssocket send:jsonTextToSend];
    return YES;
}


- (void) setLanguage:(nonnull NSString *)language {
    _language = language;
}

- (void) setConsultationSpace:(nullable NSString *)space {
    self.space = space;
}

#pragma mark -
#pragma mark Private sending methods

#pragma mark TopKnowledge

- (NSString*) prepareTopKnowledgeWithTag:(nullable NSString*)tag
                     includeTagChildren:(BOOL)isIncludeTagChildren
               ignoreManualTopKnowledge:(BOOL)isIgnoreManualTopKnowledge
                           maxItems:(int)maxItems
                             withPeriod:(nullable NSString*)period {
  
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSString * type = kTypeTopknowledge;
    
    //variables optional to add
    if (IsEmpty(tag)) { tag = @""; }
    [paramDict setValue:tag forKey:@"tag"];
    [paramDict setValue:@(isIncludeTagChildren) forKey:@"includeTagChildren"];
    [paramDict setValue:@(isIgnoreManualTopKnowledge) forKey:@"ignoreManualTopKnowledge"];
    [paramDict setValue:@(maxItems) forKey:@"maxKnowledge"];
    [paramDict setValue:period forKey:@"period"];
    
    //**** Common parmaters ****
    [self addBotIdToDictionary:paramDict];
    [self addSolutionUsedToDictionary:paramDict];
    [self addExchangeModeToDictionary:paramDict];
    [self addSpaceToDictionary:paramDict];
    [self addQualificationModeToDictionary:paramDict];
    [self addLanguageToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}

#pragma mark Prepare


-(NSString *) prepareSetOrDeleteVariableName:(NSString*)name withValue:(NSString *)value {
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSString * type = kTypeSetOrDeleteVariable;
    
    //variables optional to add
    if (!IsEmpty(name)) {
        [paramDict setValue:name forKey:@"name"];
    }
    if (!IsEmpty(value)) {
        [paramDict setValue:value forKey:@"value"];
    }
    
    //**** Common parmaters ****
    [self addBotIdToDictionary:paramDict];
    [self addSolutionUsedToDictionary:paramDict];
    [self addExchangeModeToDictionary:paramDict];
    
    [self addContextIdToDictionary:paramDict withContextId:[DoYouDreamUpManager contextId]];
    [self addQualificationModeToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}


-(NSString *) prepareTalk:(NSString *)message
               screenCode:(NSString*)currentScreenCode
               parameters:(NSDictionary *)parameters
 disableLanguageDetection:(BOOL)disableLanguageDetection
             pureLiveChat:(BOOL)isPureLiveChat {
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSString * type = kTypeTalk;
    
    if (!IsEmpty(message)) {
        [paramDict setValue:message forKey:kKeyUserInput];
    }
    //competency -> not necessary
    [self addClientIdToDictionary:paramDict];
    if (disableLanguageDetection) {
        [self addDisableLanguageDetectionToDictionary:paramDict];
    }
    
    if (isPureLiveChat) {
        [self addPureLiveChatToDictionary:paramDict withValue:isPureLiveChat];
    }
    
    [self addLanguageToDictionary:paramDict];
    [self addSpaceToDictionary:paramDict];
    
    [self addUserIdToDictionary:paramDict withValue:[DoYouDreamUpPersistance userID]];//optional
    
    [self addUserUrlToDictionary:paramDict withUrl:currentScreenCode];
    
    [self addAlreadyCameToDictionary:paramDict];
    
    //variables optional to add
    if (parameters != nil) {
        [paramDict setValue:[NSMutableDictionary dictionaryWithDictionary:parameters] forKey:kKeyVariables];
    }
    
    //**** Common parmaters ****
    [self addBotIdToDictionary:paramDict];
    [self addSolutionUsedToDictionary:paramDict];
    [self addExchangeModeToDictionary:paramDict];
    
    [self addContextIdToDictionary:paramDict withContextId:[DoYouDreamUpManager contextId]];
    [self addQualificationModeToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}

-(NSString *) prepareServerAccessibility {
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    
    NSString * type = kTypeServerAccessibility;
    
    //Params
    [self addClientIdToDictionary:paramDict];
    
    //**** Common parmaters ****
    [self addBotIdToDictionary:paramDict];
    [self addSolutionUsedToDictionary:paramDict];
    [self addExchangeModeToDictionary:paramDict];
    [self addContextIdToDictionary:paramDict withContextId:[DoYouDreamUpManager contextId]];
    [self addQualificationModeToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}

- (NSString *) prepareHistoryWithContextId:(nonnull NSString*)contextId {
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    
    NSString * type = kTypeHistory;
    
    
    //Common field
    [self addContextIdToDictionary:paramDict withContextId:contextId];
    [self addBotIdToDictionary:paramDict];
    [self addSolutionUsedToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}

- (NSString *) prepareFeedbackType:(NSString*)type withContent:(NSString*) content {
    
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    
    if ( [type isEqualToString:kTypeFeedback] ) {
        [paramDict setValue:content forKey:kKeyFeedback];
    }
    else if ([type isEqualToString:kTypeFeedbackInsatisfactionChoice] ) {
        [paramDict setValue:content forKey:kKeyFeedbackChoiceKey];
        
    }
    else if ([type isEqualToString:kTypeFeedbackComment] ) {
        [paramDict setValue:content forKey:kKeyFeedbackCommentKey];
    }
    
    //Common field
    [self addContextIdToDictionary:paramDict withContextId:[DoYouDreamUpManager contextId]];
    [self addBotIdToDictionary:paramDict];
    [self addSolutionUsedToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}


- (NSString*) prepareSurveyConfiguration:(NSString*)surveyId {

    NSString * type = kTypeSurveyConfiguration;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    
    [paramDict setValue:surveyId forKey:kkeySurveyId];
    [self addLanguageToDictionary:paramDict];

    //Common field
    [self addBotIdToDictionary:paramDict];
    [self addContextIdToDictionary:paramDict  withContextId:[DoYouDreamUpManager contextId]];
    [self addSolutionUsedToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}

- (NSString*) prepareSurvey:(NSString*)surveyId
                withAnswers:(NSDictionary*)answers
    interactionSurveyAnswer:(BOOL)isInteractionSurveyAnswer {
    
    NSString * type = kTypeSurvey;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    
    //Specific
    //operator not used
    [paramDict setValue:surveyId forKey:kkeySurveyId];
    [paramDict setValue:@(isInteractionSurveyAnswer) forKey:kkeySurveyInteractionSurveyAnswer];
    if (answers!=nil) {
        [paramDict setValue:answers forKey:kkeyFields];
    }
    
    //Common field
    [self addBotIdToDictionary:paramDict];
    [self addContextIdToDictionary:paramDict withContextId:[DoYouDreamUpManager contextId]];
    [self addSolutionUsedToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}



- (NSString *) prepareTypingMessage:(nullable NSString *)content isTyping:(BOOL)isTyping {
    NSString * type = kTypeTyping;
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    
    NSString * contentToSend = content;
    if (IsEmpty(content)) contentToSend = @"";
    
    //Specific
    [paramDict setValue:contentToSend forKey:kKeyContent];
    [paramDict setValue:@(isTyping) forKey:kKeyTyping];
    
    //Common field
    [self addContextIdToDictionary:paramDict withContextId:[DoYouDreamUpManager contextId]];
    [self addBotIdToDictionary:paramDict];
    [self addSolutionUsedToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}


- (NSString *) prepareWelcomeCall {
    
    NSString * type = kTypeWelcomeCall;
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    
    //Common field
    [self addContextIdToDictionary:paramDict withContextId:[DoYouDreamUpManager contextId]];
    [self addBotIdToDictionary:paramDict];
    [self addQualificationModeToDictionary:paramDict];
    [self addLanguageToDictionary:paramDict];
    [self addSpaceToDictionary:paramDict];
    [self addSolutionUsedToDictionary:paramDict];
    
    return [self encapsulateAndEncodeDictionnary:paramDict withType:type];
}



#pragma mark Helper dictionary construct

- (void)addSpaceToDictionary:(NSMutableDictionary*)paramDict {
    if ( !IsEmpty(self.space) ) {
        [paramDict setValue:self.space forKey:kKeySpace];
    }
    else {
        [paramDict setValue:kConstantDefaultSpace forKey:kKeySpace];
    }
}

- (void)addContextTypeToDictionary:(NSMutableDictionary*)paramDict {
    [paramDict setValue:kConstantIOS forKey:kKeyContextType];
}

- (void)addPureLiveChatToDictionary:(NSMutableDictionary*)paramDict withValue:(BOOL)isEnabled{
    [paramDict setValue:@(isEnabled) forKey:kKeyPureLiveChat ];
}

- (void)addDisableLanguageDetectionToDictionary:(NSMutableDictionary*)paramDict{
    [paramDict setValue:@YES forKey:kKeyDisableLanguageDetection ];
}

- (void)addLanguageToDictionary:(NSMutableDictionary*)paramDict {
    if (self.language != nil) {//send it when we have it
        [paramDict setValue:self.language forKey:kKeyLanguage];
    }
}

- (void)addOSToDictionary:(NSMutableDictionary*)paramDict {
    NSString * osVersion = [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    [paramDict setValue:osVersion forKey:kKeyOS];
}

- (void)addSolutionUsedToDictionary:(NSMutableDictionary*)paramDict {
    [paramDict setValue:[DoYouDreamUpEnumHelper solutionUsedTypeToString:self.solutionUsed] forKey:kKeySolutionUsed];
}

- (void)addBotIdToDictionary:(NSMutableDictionary*)paramDict {
    
    if (self.botID != nil) {//send it when we have it
        [paramDict setValue:self.botID forKey:kKeyBotId];
    }
}


//We use it to add a screencode
- (void)addUserUrlToDictionary:(NSMutableDictionary*)paramDict withUrl:(NSString*)currentScreenCode {
    if (currentScreenCode != nil) {
        [paramDict setValue:currentScreenCode forKey:kKeyUserUrl];
    }
}

- (void)addUserIdToDictionary:(NSMutableDictionary*)paramDict withValue:(nullable NSString*)value{
    if (value != nil) {
        [paramDict setValue:value forKey:kKeyUserId];
    }
}

- (void)addQualificationModeToDictionary:(NSMutableDictionary*)paramDict {
    [paramDict setValue:[NSNumber numberWithBool:self.testMode] forKey:kKeyQualificationMode];
}

- (void)addExchangeModeToDictionary:(NSMutableDictionary*)paramDict {
    [paramDict setValue:KConstantWebsocket forKey:kKeyMode];
}

- (void)addContextIdToDictionary:(NSMutableDictionary*)paramDict withContextId:(NSString*)contextId{
    if (!IsEmpty(contextId)) {
        [paramDict setValue:contextId forKey:kKeyContextID];
    }
}

- (void)addAlreadyCameToDictionary:(NSMutableDictionary*)paramDict {
    BOOL isAlreadyCame = [self isAlreadyCame];
    [paramDict setValue:@(isAlreadyCame) forKey:kKeyAlreadyCame];
}

- (void)addClientIdToDictionary:(NSMutableDictionary*)paramDict {
    NSString * clientID = [DoYouDreamUpManager clientId];
    [paramDict setValue:clientID forKey:kkeyClientId];
}

- (NSString *) encapsulateAndEncodeDictionnary:(NSMutableDictionary*)paramDict withType:(NSString*)type {
    
    [self addOSToDictionary:paramDict];
    [self addContextTypeToDictionary:paramDict];
    
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:type forKey:kKeyType];
    [dictionary setValue:paramDict forKey:kKeyParameters];
    
    
    DYDUDebugLog(@"Dictionary to send : %@", dictionary);
    NSDictionary * encodedDict = [DoYouDreamUpBase64Utils encodeStringToBase64WithDictionary:dictionary];
    
    NSString * jsonTextToSend = [encodedDict jsonEncodedKeyValueString];
    DYDUDebugLog(@"JSON sent : %@", jsonTextToSend);
    return jsonTextToSend;
}





#pragma mark -
#pragma mark Utils


- (nullable NSString *) saveContextIdFromDictionary:(NSDictionary *)dict {
    if (dict == nil) {DYDUWarningLog(@"saveContextIdFromDictionary - Warning empty dict parameter"); return nil;}
    
    NSString * decodedContextID = [dict valueForKey:kKeyContextID];
    if (!IsEmpty(decodedContextID)) {
        NSString * currentContextId = [DoYouDreamUpManager contextId];
        
        //save & notify only changes
        if (IsEmpty(currentContextId) || (![currentContextId isEqualToString:decodedContextID]) ) {
            [DoYouDreamUpPersistance storeContextId:decodedContextID];
            DYDUDebugLog(@"dydu_contextIdChanged %@", decodedContextID);
            if ( [self.delegate respondsToSelector:@selector(dydu_contextIdChanged:)] ) {
                [self.delegate dydu_contextIdChanged:decodedContextID];
            }
        }
    }
    return decodedContextID;
}


- (void) handleResponse:(id)response {
    NSError *jsonParsingError = nil;
    NSData * dataResponse = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *result=[NSJSONSerialization JSONObjectWithData:dataResponse options:0 error:&jsonParsingError];
    if (jsonParsingError != nil) {
        DYDUDebugLog(@"Not supported json type or answer, Parsing Error=%@",jsonParsingError);
    }
    
    //DYDUDebugLog(@"result=%@", result);
    
    NSString * type = [result valueForKey:kKeyType];
    result = [DoYouDreamUpBase64Utils decodeToBase64:result];
    DYDUDebugLog(@"resultDecoded=%@", result);
    
    //********* TALK RESPONSE
    if (type != nil && [type isEqualToString:kTypeTalkResponse]) {
        NSDictionary * valuesDict = [result valueForKey:kKeyValuesField];
        
        [self saveContextIdFromDictionary:valuesDict];
        
        NSString * message = [valuesDict valueForKey:@"text"];
        
        //ignored urlRedirect
        
        if ( [self.delegate respondsToSelector:@selector(dydu_receivedTalkResponseWithMsg:withExtraParameters:)] ) {
            [self.delegate dydu_receivedTalkResponseWithMsg:message withExtraParameters:valuesDict];
        }
    }
    
    //********* GET SERVER AVAILIBILITY RESPONSE
    else if (type != nil && [type isEqualToString:kTypeServerAccessibilityResponse]) {
        
        NSDictionary * valuesDict = [result valueForKey:kKeyValuesField];

        NSNumber * serverAccessible = [valuesDict valueForKey:@"serverAccessible"];
        DYDUDebugLog(@"serverAccessible=%@", serverAccessible);
        
        BOOL connectionSucess = [serverAccessible  boolValue];
        if (connectionSucess && [self.delegate respondsToSelector:@selector(dydu_connexionDidOpenWithContextId:)]) {
            NSString * contextId = [DoYouDreamUpPersistance contextId];
            DYDUDebugLog(@"dydu_connexionDidOpenWithContextId:%@", contextId);
            [self.delegate dydu_connexionDidOpenWithContextId:contextId];
        }
        else {
            DYDUDebugLog(@"Server refuse to take the connexion for state=%@", [DoYouDreamUpEnumHelper connectionStateToString:self.connectionState]);
            [self switchServer];
        }
        [self.timerConnexionContext invalidate];//connexion into the delay, so we invalidate the timer
    }
    //********* NOTIFICATIONS
    else  if (type != nil && [type isEqualToString:kTypeNotification]) {
        NSDictionary * valuesDict = [result valueForKey:kKeyValuesField];
        [self saveContextIdFromDictionary:valuesDict];

        NSString * message = [valuesDict valueForKey:@"text"];
        if (IsEmpty(message)) message = @"";//not null value
        
        NSString * code = [valuesDict valueForKey:@"code"];
        if (IsEmpty(code)) code = @"";//not null value
        
        DYDUDebugLog(@"Notification message received=%@ for code=%@", message, code);
        
        
        if ( [self.delegate respondsToSelector:@selector(dydu_receivedNotification:withCode:)]) {
            [self.delegate dydu_receivedNotification:message withCode:code];
        }
        
    }
    
    //********* SURVEYCONFIGURATION
    else  if (type != nil && ([type isEqualToString:kTypeSurveyConfigurationResponse] || [type isEqualToString:kTypeSurveyConfigurationErrorResponse])) {
        NSDictionary * valuesDict = [result valueForKey:kKeyValuesField];
        
        [self saveContextIdFromDictionary:valuesDict];
        
        NSString * name = [valuesDict valueForKey:@"name"];
        NSString * text = [valuesDict valueForKey:@"text"];
        NSString * title = [valuesDict valueForKey:@"title"];
        NSString * error = [valuesDict valueForKey:@"error"];
        NSObject * fieldsTesting = [valuesDict valueForKey:@"fields"];
        NSArray * fields = nil;
        if (fieldsTesting != nil && [fieldsTesting isKindOfClass:[NSArray class]]) {
            fields = (NSArray*)fieldsTesting;
        }
        DYDUDebugLog(@"Survey decoded name=%@, text=%@ title=%@ fields=%@ - error=%@", name, text, title, fields, error);
        
        if ( [self.delegate respondsToSelector:@selector(dydu_surveyReceivedStructureWithName:title:text:fields:errorMessage:)]) {
            [self.delegate dydu_surveyReceivedStructureWithName:name title:title text:text fields:fields errorMessage:error];
        }
    }
    //********* SURVEYRESPONSE
    else  if (type != nil && [type isEqualToString:kTypeSurveyResponse]) {
        DYDUDebugLog(@"Survey post received");
        if ( [self.delegate respondsToSelector:@selector(dydu_surveyPosted)]) {
            [self.delegate dydu_surveyPosted];
        }
    }
    //********* HISTORY RESPONSE
    else  if (type != nil && [type isEqualToString:kTypeHistoryResponse]) {
        NSDictionary * valuesDict = [result valueForKey:@"values"];
        NSString * historyContextId = [valuesDict valueForKey:kKeyContextID];
        DYDUDebugLog(@"HistoryContextID=%@", historyContextId);
        
        NSArray * interactions = [valuesDict valueForKey:@"interactions"];
        DYDUDebugLog(@"History interactions=%@", interactions);
        
        if (interactions != nil && [interactions isKindOfClass:[NSArray class]]) {
            
            //DEBUG TO DISABLE
            for (NSDictionary * dict in interactions) {
                DYDUDebugLog(@"History decoded=%@", dict);
            }
        }
        
        //call back conditions
        if (( interactions == nil && [valuesDict count]> 1) ||//case no history but we return a call back
            (interactions != nil && [interactions isKindOfClass:[NSArray class]]) ) {
            if ( [self.delegate respondsToSelector:@selector(dydu_history:forContextId:)]) {
                [self.delegate dydu_history:interactions forContextId:historyContextId];
            }
        }
    }
    
    //********* TopKnowledgeResponse renamed as topQuestions for the sdk to be more clear
    
    else if (type != nil && [type isEqualToString:kTopKnowledgeResponse]) {
        
        NSDictionary * valuesDict = [result valueForKey:@"values"];
        
        NSArray * questions = [valuesDict valueForKey:@"knowledgeArticles"];
        NSString * tag = [valuesDict valueForKey:@"tagName"];
        
        //content is stringify
        if (!IsEmpty(questions) && [questions isKindOfClass:[NSString class]]) {
            NSError *jsonParsingErrorQuestions = nil;
            NSData * dataResponse = [((NSString*)questions) dataUsingEncoding:NSUTF8StringEncoding];
            questions=[NSJSONSerialization JSONObjectWithData:dataResponse options:0 error:&jsonParsingErrorQuestions];
            if (jsonParsingErrorQuestions != nil) {
                DYDUDebugLog(@"TopKnowledgeResponse - questions array not supported json type or answer, Parsing Error=%@",jsonParsingErrorQuestions);
            }
            DYDUDebugLog(@"%@",questions);

        }
        
        DYDUDebugLog(@"knowledgeArticlesClass=%@",[questions class]);
        if (questions== nil || [questions count] == 0 || [questions isKindOfClass:[NSArray class]]) {
            if ( [self.delegate respondsToSelector:@selector(dydu_topQuestions:withTag:)] ) {
                [self.delegate dydu_topQuestions:questions withTag:tag];
            }
        }
    }
    else {
        DYDUWarningLog(@"Unsupported type=%@ - Result : %@", type, result);
    }

}


- (void) onError:(NSError *)error {
    if ( [self.delegate respondsToSelector:@selector(dydu_connexionDidFailWithError:)] ) {
        [self.delegate dydu_connexionDidFailWithError:error];
    }
}

#pragma mark URL

- (NSArray *) protocols {
    return @[kProtocol];
}

#pragma mark -
#pragma mark Protocol WebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    if (webSocket != self.wssocket)  { DYDUWarningLog(@"Ignoring not the same websocket obj"); return; }

    
    DYDUDebugLog(@"webSocket:didReceiveMessage %@", message);
    [self handleResponse:message];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    DYDUDebugLog(@"webSocketDidOpen");
    if (webSocket != self.wssocket)  { DYDUWarningLog(@"Ignoring not the same websocket obj"); return; }

    int state = self.connectionState;//save current state
    
    
    if (self.connectionState == Connecting) {
        self.connectionState = Connected;//affect asap the new state
    }
    else  if (self.connectionState == ConnectingOnBackup) {
        self.connectionState = ConnectedOnBackup;//affect asap the new state
    }


    if (state == Connecting || state == ConnectingOnBackup) {
        DYDUDebugLog(@"webSocketDidOpen - calling switch server");
        [self triggerTimerConnexionContext];
        /* ******************************** TO RENABLE ******************************** */
        //********************* TODO DISABLED TEMP
        
      /*  if ( state == CONNECTION_STATE_CONNECTING)  {
            
        DYDUDebugLog(@"webSocketDidOpen - getContextID disableddd !!!! ********** WARNING");
        }
        
        if ( state == CONNECTION_STATE_CONNECTING_BACKUP)
         */

        [self callServerAccessibility];
    }
    else {
        DYDUWarningLog(@"Unspported state %@", [DoYouDreamUpEnumHelper connectionStateToString:state]);
    }
    
    //Backup mode moved to context
    //
    // else {
    //    if ([self.delegate respondsToSelector:@selector(dydu_connexionDidOpen)]) {
    //        [self.delegate dydu_connexionDidOpen];
    //    }
    //}
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    DYDUDebugLog(@"webSocket:didFailWithError for connection state=\"%@\" error=\"%@\"",[DoYouDreamUpEnumHelper connectionStateToString:self.connectionState],error);
    if (webSocket != self.wssocket)  { DYDUWarningLog(@"Ignoring not the same websocket obj"); return; }
    
    //backup server try
    if ( self.connectionState == Connecting && [self hasBackupServer] ) {
        [self connectWithBackupServer];
    }
    else {
        self.connectionState = Idle;
        [self invalidateConnexionTimer];
        
        //call delegate that there is an error
        if ([self.delegate respondsToSelector:@selector(dydu_connexionDidFailWithError:)]) {
            [self.delegate dydu_connexionDidFailWithError:error];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    DYDUDebugLog(@"webSocket:didCloseWithCode=%ld reason=%@, wasClean=%ld", (long)code, reason, (long)wasClean);
    
    if (webSocket != self.wssocket)  { DYDUWarningLog(@"Ignoring not the same websocket obj"); return; }
    
    self.connectionState = Idle;
    
    //we notify only if it is not trigger by the server switch
    if ([self.delegate respondsToSelector:@selector(dydu_connexionDidClosed)]) {
        [self.delegate dydu_connexionDidClosed];
    }
    
}




#pragma mark - UserDefaults
//if a value is already stored for the cliendIdUserDefault so the client is already came
- (BOOL) isAlreadyCame {
    NSString * clientId = [DoYouDreamUpPersistance clientId];

    if (IsEmpty(clientId)) return NO;
    else return YES;
}

+ (nonnull NSString*) UUID {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge NSString *)uuidStringRef;
}

+ (nonnull NSString*)clientId {
    static NSString *uuid = nil;
    if (uuid == nil) {
        uuid = [DoYouDreamUpPersistance clientId];
    }
    
    if (uuid == nil) {
        uuid = [self UUID];
        [DoYouDreamUpPersistance storeClientId:uuid];
    }
    
    return uuid;
}

+ (void) resetContextId {
    [DoYouDreamUpPersistance storeContextId:nil];
}

+ (nullable NSString*) contextId {
    return [DoYouDreamUpPersistance contextId];
}



/// Returns NO is the object is nil or empty.
/// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL IsEmpty(id thing) {
    return thing == nil || thing == NSNull.null ||
    ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

@end
