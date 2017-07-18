//
//  CardAction.swift
//  Test
//
//  Created by Natixis on 07/07/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import Foundation

public class CardAction {
    
    public var image: String?
    public var title: String?
    public var type: String?
    public var value: NSObject?
    
    func getImage() -> String {
        return self.image!
    }
    
    func setImage(image: String!) {
        self.image = image
    }
    
    func getTitle() -> String {
        return self.title!
    }
    
    func setTitle(title: String!) {
        self.title = title
    }
    
    func getType() -> String {
        return self.type!
    }
    
    func setType(type: String!) {
        self.type = type
    }
    
    func getValue() -> NSObject {
        return self.value!
    }
    
    func setValue(value: NSObject!) {
        self.value = value
    }
}
