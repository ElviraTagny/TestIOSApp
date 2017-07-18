//
//  DYDUChatBotManager.swift
//  Test
//
//  Created by Natixis on 07/07/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import Foundation
import DoYouDreamUp
import ChatBot

class DYDUChatBotManager: ChatBotManager, DoYouDreamUpDelegate {
    
    // MARK: DoYouDreamUp stack
    
    //Implement the callback delegate
    func dydu_receivedTalkResponse(withMsg message: String, withExtraParameters extraParameters: [AnyHashable : Any]?) {
        let newMessage = super.saveMessage(message: message.html2String, isSender: false)
        pDisplayMessageDelegate?.onDisplayLogMessage(log: message)
        pDisplayMessageDelegate?.onDisplayMessage(message: newMessage)
    }
    
    ///Callback to notify that the connection failed with the given error
    ///@param error the given error
    public func dydu_connexionDidFailWithError(_ error: Error) {
        pDisplayMessageDelegate?.onDisplayLogMessage(log: "Connection failed with error \(error.localizedDescription)")
    }
    
    ///Callback to notify that the connection closed correctly
    func dydu_connexionDidClosed() {
        pDisplayMessageDelegate?.onDisplayLogMessage(log: "Connection closed correctly")
    }
    
    ///Callback to notify that the connection opened
    ///@param contextId the contextId used in the current connexion, could be nil at this step for the first login
    /// use the dydu_contextIdChanged to get information about changes
    public func dydu_connexionDidOpen(withContextId contextId: String?) {
        pDisplayMessageDelegate?.onDisplayLogMessage(log: "Connection opened correctly")
    }
    
    //Check the history of interactions
    func dydu_history(_ interactions: [Any]?, forContextId contextId: String?) {
        pDisplayMessageDelegate?.onDisplayLogMessage(log: "received #=\(interactions?.count) history entries for contextId=\(contextId)"/*, withPrefix: "History"*/)
        if ((interactions?.count)! > 0) {
            let item = interactions![0] as AnyObject
            pDisplayMessageDelegate?.onDisplayLogMessage(log: "Hola"/*"First item=\(item["text"]) from=\(item["from"]) type=\(item["type"]) user=\(item["user"])"*//*, withPrefix: "Response="*/)
        }
    }
    
    func dydu_receivedNotification(_ message: String, withCode code: String) {
        pDisplayMessageDelegate?.onDisplayLogMessage(log: "received notification #=\(message) withCode: \(code)"/*, withPrefix: "Notification"*/)
    }
    
    func dydu_contextIdChanged(_ contextId: String) {
        pDisplayMessageDelegate?.onDisplayLogMessage(log: "ContextId changed")
    }
    
    
    override func sendMessage(sData: String) {
        super.sendMessage(sData: sData)
        //Talk to Bot
        //DoYouDreamUpManager.sharedInstance().talk(inputMessage.text)
        if (DoYouDreamUpManager.sharedInstance().talk(sData, extraParameters: ["action":"clickChangeUser"]) ) {
            pDisplayMessageDelegate?.onDisplayLogMessage(log: "Talking action sent: \(sData)")
        }
    }
    
    override func initService(pDisplayMessageDelegate: DisplayMessageDelegate) {
        super.initService(pDisplayMessageDelegate: pDisplayMessageDelegate)
        self.pDisplayMessageDelegate = pDisplayMessageDelegate;
        let currentLanguage = "fr"
        //NSLog("currentLanguage=\(currentLanguage)")
        DoYouDreamUpManager.sharedInstance().configure(with: self, botId: "972f1264-6d85-4a58-b5ac-da31481dda63",
                                                       space: nil,
                                                       language: currentLanguage,
                                                       testMode:false,
                                                       solutionUsed: Assistant,
                                                       pureLivechat: false,
                                                       serverUrl:"wss://jp.createmyassistant.com/servlet/chat",
                                                       backupServerUrl:nil)

        if (DoYouDreamUpManager.sharedInstance().connect()) {
            pDisplayMessageDelegate.onDisplayLogMessage(log: "Connecting…")
        }
        //Define a specific user if you want to, this can be done anytime
        DoYouDreamUpManager.setUserID("USERID_123")
        DoYouDreamUpManager.displayLog(true)
    }
    
    override func closeService() {
        super.closeService()
        DoYouDreamUpManager.sharedInstance().disconnect();
    }
    
    internal override func getBotFormattedResponse(sRawResponse: String) -> NSString {
        return ""
    }
    
    internal override func getBotResponseOptions(sRawResponse: String) -> Set<NSObject> {
        return Set<NSObject>()
    }

    internal override func getBotCarouselOptions(sRawResponse: String) -> Set<NSObject> {
        return Set<NSObject>()
    }

}

extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
