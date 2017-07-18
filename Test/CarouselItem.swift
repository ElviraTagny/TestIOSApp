//
//  CarouselItem.swift
//  Test
//
//  Created by Natixis on 07/07/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import Foundation

public class CarouselItem {
    private var mTitle: String?
    private var mButton: String?
    private var mImage: CGImage?
    
    func getTitle() -> String {
        return self.mTitle!
    }
    
    func setTitle(title: String!) {
        self.mTitle = title!
    }
    
    func getButton() -> String {
        return self.mButton!
    }
    
    func setButton(button: String!) {
        self.mButton = button!
    }
    
    func getImage() -> CGImage {
        return self.mImage!
    }
    
    func setImage(bImage: CGImage!) {
        self.mImage = bImage!
    }
}
