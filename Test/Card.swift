//
//  Card.swift
//  Test
//
//  Created by Natixis on 07/07/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import Foundation

public class Card {
    
    public var buttons: Array<CardAction>?
    public var title: String?
    public var subtitle: String?
    public var text: String?
    public var tap: CardAction?
    
    func getButtons() -> Array<CardAction> {
        return self.buttons!
    }
    
    func setButtons(buttons: Array<CardAction>) {
        self.buttons = buttons
    }
    
    func getTitle() -> String {
        return self.title!
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func getSubtitle() -> String {
        return self.subtitle!
    }
    
    func setSubtitle(subtitle: String) {
        self.subtitle = subtitle
    }
    
    func getText() -> String {
        return self.text!
    }
    
    func setText(text: String) {
        self.text = text
    }
    
    func getTap() -> CardAction {
        return self.tap!
    }
    
    func setTap(tap: CardAction) {
        self.tap = tap
    }
}
