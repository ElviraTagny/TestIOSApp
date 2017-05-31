//
//  ChatCollectionViewController.swift
//  Test
//
//  Created by Natixis on 23/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import UIKit
import DoYouDreamUp
import CoreData

let welcomeMessage = "DYDU à votre disposition ! Que puis-je faire pour vous?"

//let managedObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)

class ChatCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DoYouDreamUpDelegate {
    
    let managedObjectContext = delegate?.persistentContainer.viewContext
    
    private let reuseIdentifier = "cell"
    
    var messages:[Message]?
    
   @IBOutlet weak var messagesCollectionView: UICollectionView!
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        DoYouDreamUpManager.sharedInstance().disconnect();
    }
    
    @IBOutlet weak var inputMessage: UITextField!
    
    @IBAction func onSendButtonPressed(_ sender: Any) {
        
        //add message to messages ans save data
        let message = createMessageWithText(text: inputMessage.text!, minutesAgo: 0, isSender: true, context: managedObjectContext!)
        saveData()
        
        //update messages and collectionView
        messages?.append(message)
        let insertionIndexPath = NSIndexPath(item: (messages!.count - 1), section: 0)
        messagesCollectionView?.insertItems(at: [insertionIndexPath as IndexPath])
        
        //Talk to Bot
        //DoYouDreamUpManager.sharedInstance().talk(inputMessage.text)
        if (DoYouDreamUpManager.sharedInstance().talk(inputMessage.text!, extraParameters: ["action":"clickChangeUser"]) ) {
            displayMessage(message: "Talking action sent: \(inputMessage.text!)")
        }
        //clear input field
        inputMessage.text = ""
        
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
        initData()
        
        let currentLanguage = "fr"
        //NSLog("currentLanguage=\(currentLanguage)")
        
        DoYouDreamUpManager.sharedInstance().configure(with: self, botId: "972f1264-6d85-4a58-b5ac-da31481dda63",
                                                                   space: nil,
                                                                   language: currentLanguage,
                                                                   testMode:true,
                                                                   solutionUsed: Assistant,
                                                                   pureLivechat: false,
                                                                   serverUrl:"wss://jp.createmyassistant.com/servlet/chat",
                                                                   backupServerUrl:nil)

        if (DoYouDreamUpManager.sharedInstance().connect()) {
            displayMessage(message: "Connecting…")
        }
        //Define a specific user if you want to, this can be done anytime
        DoYouDreamUpManager.setUserID("USERID_123")
        DoYouDreamUpManager.displayLog(true)
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
            message.text = ""
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
            
            addSubview(profileImageView)
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
            if msg.isSender!.boolValue {
                cell.backgroundColor = UIColor.blue
                cell.profileImageView.image = UIImage(named: "user_icon")
            }
            else {
                cell.backgroundColor = UIColor.lightGray
                cell.profileImageView.image = UIImage(named: "dydu")
            }

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
     func numberOfSections(in collectionView: UICollectionView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 1
     }
    */
    
    // MARK: DoYouDreamUp stack
    
    //Implement the callback delegate
    func dydu_receivedTalkResponse(withMsg message: String, withExtraParameters extraParameters: [AnyHashable : Any]?) {
        displayMessage(message: message, withPrefix: "Response")
        //Exemple: Je n'ai malheureusement pas compris. Pouvez-vous reformuler votre phrase ou faire une nouvelle demande ?<silent><br><br><a href="reword/Faire une nouvelle demande">Faire une nouvelle demande</a></silent>

        
        //add message to messages ans save data
        let message = createMessageWithText(text: message, minutesAgo: 0, isSender: false, context: managedObjectContext!)
        saveData()
        
        //update messages and collectionView
        messages?.append(message)
        let insertionIndexPath = NSIndexPath(item: (messages!.count - 1), section: 0)
        messagesCollectionView?.insertItems(at: [insertionIndexPath as IndexPath])
    }

    ///Callback to notify that the connection failed with the given error
    ///@param error the given error
    public func dydu_connexionDidFailWithError(_ error: Error) {
        displayMessage(message: "Connection failed with error \(error.localizedDescription)")
    }
    
    ///Callback to notify that the connection closed correctly
    func dydu_connexionDidClosed() {
        displayMessage(message: "Connection closed correctly")
    }
    
    ///Callback to notify that the connection opened
    ///@param contextId the contextId used in the current connexion, could be nil at this step for the first login
    /// use the dydu_contextIdChanged to get information about changes
    public func dydu_connexionDidOpen(withContextId contextId: String?) {
        displayMessage(message: "Connection opened correctly")
    }
    
    //Check the history of interactions
    func dydu_history(_ interactions: [Any]?, forContextId contextId: String?) {
        displayMessage(message: "received #=\(interactions?.count) history entries for contextId=\(contextId)", withPrefix: "History")
        if ((interactions?.count)! > 0) {
            let item = interactions![0] as AnyObject
            displayMessage(message: "Hola"/*"First item=\(item["text"]) from=\(item["from"]) type=\(item["type"]) user=\(item["user"])"*/, withPrefix: "Response=")
        }
    }
    
    func dydu_receivedNotification(_ message: String, withCode code: String) {
        displayMessage(message: "received notification #=\(message) withCode: \(code)", withPrefix: "Notification")
    }
    
    func dydu_contextIdChanged(_ contextId: String) {
        displayMessage(message: "ContextId changed")
    }
    
    // MARK: Utils
    
    func displayMessage(message:String, withPrefix prefix:String) {
        print("CB- \(prefix) - \(message)")
    }
    func displayMessage(message:String){
        print("CB- \(message)")
    }

}
