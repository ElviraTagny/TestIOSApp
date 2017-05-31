//
//  ChatControllerHelper.swift
//  Test
//
//  Created by Natixis on 29/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import UIKit
import CoreData

let delegate = UIApplication.shared.delegate as? AppDelegate


extension ChatCollectionViewController {
    
  func initData(){

        clearData()
        if let managedObjectContext = delegate?.persistentContainer.viewContext {
            createMessageWithText(text: welcomeMessage, minutesAgo: 10, isSender: false, context: managedObjectContext)
            saveData()
        }
        loadData()
    }
    
    func clearData(){
        if let managedObjectContext = delegate?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
            do {
                messages = try (managedObjectContext.fetch(fetchRequest)) as? [Message]
                for msg in messages! {
                    managedObjectContext.delete(msg)
                }
                try (managedObjectContext.save())
            } catch let error {
                print(error)
            }
        }
    }
    
    func saveData(){
        if let managedObjectContext = delegate?.persistentContainer.viewContext {
            do {
                try managedObjectContext.save()
            } catch let error {
                print(error)
            }
        }
    }

    func loadData(){
        if let managedObjectContext = delegate?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateMessage", ascending: true)]
            //fetchRequest.predicate = NSPredicate(format: "textMessage = %@", [])
            do {
                messages = try (managedObjectContext.fetch(fetchRequest)) as? [Message]
            } catch let error {
                print(error)
            }
        }
    }
    
    func createMessageWithText(text: String, minutesAgo: Double, isSender: Bool = false, context: NSManagedObjectContext) -> Message {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.textMessage = text
        message.dateMessage = NSDate().addingTimeInterval(-minutesAgo*60)
        message.isSender = NSNumber(value: isSender)
        return message
    }
}
