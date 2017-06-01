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

class ChatCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DoYouDreamUpDelegate, UITextViewDelegate {
    
    let managedObjectContext = delegate?.persistentContainer.viewContext
    private let reuseIdentifier = "cell"
    var messages:[Message]?
    var textFontSize = 12
    var dateFontSize = 10
   @IBOutlet weak var messagesCollectionView: UICollectionView!
    //@IBOutlet weak var inputMessage: UITextField!
    @IBOutlet weak var inputMessage: UITextView!
    
    
    
    @IBAction func onMicroPressed(_ sender: Any) {
        displayMessage(message: "Micro pressed")
    }
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        DoYouDreamUpManager.sharedInstance().disconnect();
    }
    
    @IBAction func clearAllMessages(_ sender: Any) {
        clearData()
    }
    
    @IBAction func onSendButtonPressed(_ sender: Any) {
        if inputMessage.text != "" {
            //add message to messages and save data
            let message = createMessageWithText(text: inputMessage.text!, minutesAgo: 0, isSender: true, context: managedObjectContext!)
            saveData()
        
            //update messages and collectionView
            if(messages == nil) {
                messages = []
            }
            messages?.append(message)
            let index = messages!.count > 0 ? (messages!.count - 1) : 0
            let insertionIndexPath = NSIndexPath(item: index, section: 0)
            messagesCollectionView?.insertItems(at: [insertionIndexPath as IndexPath])
        
            //Talk to Bot
            //DoYouDreamUpManager.sharedInstance().talk(inputMessage.text)
            if (DoYouDreamUpManager.sharedInstance().talk(inputMessage.text!, extraParameters: ["action":"clickChangeUser"]) ) {
                displayMessage(message: "Talking action sent: \(inputMessage.text!)")
            }
            //clear input field
            inputMessage.text = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputMessage.delegate = self
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0) //color: very light gray
        messagesCollectionView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0) //color: very light gray

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
                messageTextView.text = message?.textMessage as String?
                
                if let date = message?.dateMessage {
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "h:mm a"
                    timeLabel.text = dateformatter.string(from: date as Date)
                }
            }
        }
        
        let profileImageView: UIImageView = {
            let image = UIImageView ()
            image.contentMode = .scaleAspectFill
            image.layer.cornerRadius = 20
            image.layer.masksToBounds = true
            return image
        }()
        
        let messageTextView: UITextView = {
            let messageTextView = UITextView()
            messageTextView.text = ""
            messageTextView.font = UIFont.systemFont(ofSize: 12)
            messageTextView.layer.cornerRadius = 15
            messageTextView.layer.masksToBounds = true
            return messageTextView
        }()
        
        let timeLabel: UILabel = {
            let timeLabel = UILabel()
            timeLabel.text = ""
            timeLabel.font = UIFont.systemFont(ofSize: 10)
            timeLabel.textColor = UIColor.darkGray
            timeLabel.textAlignment = .right
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
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[image(45)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": profileImageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(45)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": profileImageView]))
            
            addSubview(messageTextView)
            messageTextView.translatesAutoresizingMaskIntoConstraints = false
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[messageTextView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["messageTextView": messageTextView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[messageTextView]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["messageTextView": messageTextView]))
            
            addSubview(timeLabel)
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[timeLabel(50)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["timeLabel": timeLabel]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[timeLabel(15)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["timeLabel": timeLabel, "messageTextView": messageTextView]))
        }
    }


    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.setUpViews()
        
        if let mess = messages?[indexPath.item] {
            cell.message = mess
            if mess.isSender!.boolValue {
                cell.messageTextView.backgroundColor = UIColor(red: 103/255, green: 173/255, blue: 237/255, alpha: 1.0) //color: blue sky
                cell.profileImageView.image = UIImage(named: "user_icon")
            }
            else {
                cell.messageTextView.backgroundColor = UIColor.white
                    //UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0) //color: very light gray
                cell.profileImageView.image = UIImage(named: "dydu")
            }
            /*let size = CGSize(width: view.frame.width, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: mess.textMessage!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(textFontSize))], context: nil)
            cell.messageTextView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: estimatedFrame.height + 20)
            //cell.sizeThatFits(CGSize(width: view.frame.width, height: estimatedFrame.height + 20))*/
            cell.sizeToFit()
        }
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
        
        let cellSize = CGSize(width: view.frame.width, height: 80)
        if let mess = messages?[indexPath.item] {
            let size = CGSize(width: view.frame.width, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: mess.textMessage!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(textFontSize))], context: nil)
            let cellSize = CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
            return cellSize
        }
        return cellSize
    }

    /*
     func numberOfSections(in collectionView: UICollectionView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 1
     }
    */
    
    func textViewDidChange(_ textView: UITextView) {
        let textViewFixedWidth: CGFloat = self.inputMessage.frame.size.width
        let newSize: CGSize = self.inputMessage.sizeThatFits(CGSize(width: textViewFixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame: CGRect = self.inputMessage.frame
        //var textViewPosition = self.inputMessage.frame.origin.y
        let heightDiff = self.inputMessage.frame.height - newSize.height
        if abs(heightDiff) > 20 {
            newFrame.size = CGSize(width: fmax(newSize.width, textViewFixedWidth), height: newSize.height)
            newFrame.offsetBy(dx: 0.0, dy: 0)
        }
        self.inputMessage.frame = newFrame
    }
    
    // MARK: DoYouDreamUp stack
    
    //Implement the callback delegate
    func dydu_receivedTalkResponse(withMsg message: String, withExtraParameters extraParameters: [AnyHashable : Any]?) {
        displayMessage(message: message, withPrefix: "Response")

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
