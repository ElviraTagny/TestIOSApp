//
//  SenderBubble.swift
//  Test
//
//  Created by Natixis on 18/07/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import Foundation
import ChatBot

class SenderBubble: UICollectionViewCell {
    
    var message: Message? {
        didSet{
            messageTextView.text = message?.textMessage as String?
            if let date = message?.dateMessage {
                let dateformatter = DateFormatter()
                dateformatter.locale = Locale.init(identifier: "fr_FR")
                dateformatter.dateFormat = "hh:mm"
                timeLabel.text = dateformatter.string(from: date as Date)
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView ()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let messageTextView: UITextView = {
        let messageTextView = UITextView()
        messageTextView.text = ""
        messageTextView.font = UIFont.systemFont(ofSize: CGFloat(textFontSize))
        messageTextView.layer.cornerRadius = 15
        messageTextView.isEditable = false
        messageTextView.isScrollEnabled = false
        return messageTextView
    }()
    
    let timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.text = ""
        timeLabel.font = UIFont.systemFont(ofSize: CGFloat(dateFontSize))
        timeLabel.textColor = UIColor.darkGray
        return timeLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageTextView)
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}
