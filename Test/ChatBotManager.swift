//
//  ChatBotManager.swift
//  Test
//
//  Created by Natixis on 07/07/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

/*import Foundation
import CoreData

public class ChatBotManager: NSObject, ChatBotManagerDelegate {
    
    var pDisplayMessageDelegate: DisplayMessageDelegate?
    let managedObjectContext = delegate?.persistentContainer.viewContext
    var messages:[Message]?
    
    func initService(pDisplayMessageDelegate: DisplayMessageDelegate) {
        initData()
        self.pDisplayMessageDelegate = pDisplayMessageDelegate;
    }
    
    func sendMessage(sData: String){
        createMessage(text: sData);
    }
    
    func closeService() {
    }
    
    func getBotCarouselOptions(sRawResponse: String) -> Set<NSObject> {
        return Set<NSObject>()
    }
    
    func getBotFormattedResponse(sRawResponse: String) -> NSString {
        return NSString()
    }
    
    func getBotResponseOptions(sRawResponse: String) -> Set<NSObject> {
        return Set<NSObject>()
    }
    
    private func createMessage(text:String){
        let message = createMessageWithText(text: text, minutesAgo: 0, isSender: true, context: managedObjectContext!)
        saveData()
        //update messages and collectionView
        if(messages == nil) {
            messages = []
        }
        messages?.append(message)
    }
}*/
