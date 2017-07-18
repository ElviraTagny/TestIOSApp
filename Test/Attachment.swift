//
//  Attachment.swift
//  Test
//
//  Created by Natixis on 07/07/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import Foundation

public class Attachment {
    
    public var content: Card?
    public var contentType: String?
    public var contentUrl: String?
    public var name: String?
    public var thumbnailUrl: String?
    
    func getContent() -> Card {
        return self.content!
    }
    
    func setContent(content: Card) {
        self.content = content
    }
    
    func getContentType() -> String {
        return self.contentType!
    }
    
    func setContentType(contentType: String) {
        self.contentType = contentType
    }
    
    func getContentUrl() -> String {
        return self.contentUrl!
    }
    
    func setContentUrl(contentUrl: String) {
        self.contentUrl = contentUrl
    }
    
    func getName() -> String {
        return self.name!
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getThumbnailUrl() -> String {
        return self.thumbnailUrl!
    }
    
    func setThumbnailUrl(thumbnailUrl: String) {
        self.thumbnailUrl = thumbnailUrl;
    }
}
