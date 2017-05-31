//
//  Message+CoreDataProperties.swift
//  Test
//
//  Created by Natixis on 31/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }

    @NSManaged public var dateMessage: NSDate?
    @NSManaged public var textMessage: String?
    @NSManaged public var isSender: NSNumber?

}
