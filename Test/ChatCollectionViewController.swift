//
//  ChatCollectionViewController.swift
//  Test
//
//  Created by Natixis on 23/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import UIKit
import CoreData

let welcomeMessage = "Bonjour ! Que puis-je faire pour vous?"

let managedObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)

class ChatCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let reuseIdentifier = "cell"
    
    var messages:[Message]?
    
   @IBOutlet weak var messagesCollectionView: UICollectionView!
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var inputMessage: UITextField!
    
    @IBAction func onSendButtonPressed(_ sender: Any) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.messagesCollectionView!.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.messagesCollectionView!.delegate = self
        self.messagesCollectionView!.dataSource = self
        self.messagesCollectionView!.alwaysBounceVertical = true
        setUpData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class MessageCell: UICollectionViewCell {
        
        var message: Message? {
            didSet{
                chatMessage.text = message?.textMessage as String?
            }
        }
        
        let profileImageView: UIImageView = {
            let image = UIImageView ()
            image.contentMode = .scaleAspectFill
            image.layer.cornerRadius = 20
            image.layer.masksToBounds = true
            return image
        }()
        
        let chatMessage: UILabel = {
            let message = UILabel()
            message.text = welcomeMessage
            message.adjustsFontSizeToFitWidth = true
            return message
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setUpViews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setUpViews(){
            backgroundColor = UIColor.lightGray
            
            addSubview(profileImageView)
            profileImageView.image = UIImage(named: "user_icon")
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[image(50)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": profileImageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(50)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": profileImageView]))
            
            addSubview(chatMessage)
            chatMessage.translatesAutoresizingMaskIntoConstraints = false
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[label]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": chatMessage]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": chatMessage]))
        }
    }


    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.setUpViews()
        
        if let msg = messages?[indexPath.item] {
            cell.message = msg
        }
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: welcomeMessage).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil)
        cell.chatMessage.frame = CGRect(x: 0, y: 0, width: 250, height: estimatedFrame.height + 20)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: view.frame.width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: welcomeMessage).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil)
        let cellSize = CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        return cellSize
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
     
     func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     
     func numberOfSections(in collectionView: UICollectionView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 1
     }
    */

}
