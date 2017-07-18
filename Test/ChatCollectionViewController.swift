//
//  ChatCollectionViewController.swift
//  Test
//
//  Created by Natixis on 23/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import UIKit
//import CoreData
//import Kanna
//import SwiftSoup
import ChatBot
import Speech
import AVFoundation

let textFontSize = 12
let dateFontSize = 9

class ChatCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, SFSpeechRecognizerDelegate, UICollectionViewDelegateFlowLayout, DisplayMessageDelegate {
    
    let chatBotManager = DYDUChatBotManager()
    private let reuseIdentifier = "cell"
    var messages : [Message]?
    
    @IBOutlet weak var messagesCollectionView: UICollectionView!
    @IBOutlet weak var inputMessage: UITextView!
    @IBOutlet weak var microButton: UIButton!
    
    private let speechRecognizer : SFSpeechRecognizer! = SFSpeechRecognizer(locale: Locale.init(identifier: "fr_FR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @IBAction func onMicroPressed(_ sender: Any) {
        displayMessage(message: "Micro pressed")
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.recognitionRequest = nil
            self.recognitionTask = nil
            
            //microButton.isEnabled = false
            displayMessage(message: "Stop recording")
        } else {
            startRecording()
            displayMessage(message: "Recording...")
        }
    }
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        chatBotManager.closeService()
    }
    
    @IBAction func clearAllMessages(_ sender: Any) {
        chatBotManager.clearData()
        messages = chatBotManager.getMessagesList()
        messagesCollectionView?.reloadData()
    }
    
    func onSpeakerPressed(_ sender: UIButton!){
        //get the selected message and read its text
        let message = messages?[sender.tag]
        read(text: (message?.textMessage!)!)
    }
    
    @IBAction func onSendButtonPressed(_ sender: Any) {
        if inputMessage.text != "" {
            //Talk to Bot and save message to database
            chatBotManager.sendMessage(sData: inputMessage.text!)
            messages = chatBotManager.getMessagesList()
            for mess in messages! {
                print("DEBUG - send - ", mess.textMessage! + "//")
            }
            let index = (messages?.count)! > 0 ? ((messages?.count)! - 1) : 0
            let insertionIndexPath = NSIndexPath(item: index, section: 0)
            messagesCollectionView?.insertItems(at: [insertionIndexPath as IndexPath])
            scrollToBottom()
            
            //clear input field
            inputMessage.text = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputMessage.delegate = self
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0) //color: very light gray
        self.messagesCollectionView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0) //color: very light gray
        
        /*********** Chatbot init block ******************/
        chatBotManager.initService(pDisplayMessageDelegate: self)
        messages = chatBotManager.getMessagesList()
        for mess in messages! {
            print("DEBUG - init - ", mess.textMessage! + "//")
        }
        //var paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
        //print(paths.objectAtIndex[0])
        let mdelegate = UIApplication.shared.delegate as? AppDelegate
        print("DB", mdelegate?.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url)
        /***********************************************/
        
        // Register cell classes
        self.messagesCollectionView!.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.messagesCollectionView!.delegate = self
        self.messagesCollectionView!.dataSource = self
        self.messagesCollectionView!.alwaysBounceVertical = true
        scrollToBottom()
        
        /************ Speech recognition init block *******************/
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            switch authStatus {
                case .authorized:
                    isButtonEnabled = true
                case .denied:
                    isButtonEnabled = false
                    print("User denied access to speech recognition")
                case .restricted:
                    isButtonEnabled = false
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    isButtonEnabled = false
                    print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation() {
                self.microButton.isEnabled = isButtonEnabled
            }
        }
        /**************************************************************/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Speech implementation
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microButton.isEnabled = true
        } else {
            microButton.isEnabled = false
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            if let result = result {
                //let str = result.bestTranscription.formattedString
                self.inputMessage.text = result.bestTranscription.formattedString
            } else { //if let error = error {
                self.inputMessage.text = error?.localizedDescription
                self.displayMessage(message: error.debugDescription)
                inputNode.removeTap(onBus: 0)
            }
           /* var isFinal = false
            if result != nil {
                self.inputMessage.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil {
                self.displayMessage(message: (error?.localizedDescription)!)
            }
            
            if isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }*/
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
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
                cell.profileImageView.image = UIImage(named: "user_icon")
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[image(45)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": cell.profileImageView]))
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(45)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": cell.profileImageView]))
                
                cell.messageTextView.backgroundColor = UIColor(red: 103/255, green: 173/255, blue: 237/255, alpha: 1.0) //color: blue sky
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[text(200)]-50-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["text": cell.messageTextView]))
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[text]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["text": cell.messageTextView]))
                
                cell.timeLabel.textAlignment = .left
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[time(45)][message]", options: NSLayoutFormatOptions(), metrics: nil, views: ["time": cell.timeLabel, "message": cell.messageTextView]))
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[time(10)]-3-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["time": cell.timeLabel]))
            }
            else {
                cell.profileImageView.image = UIImage(named: "dydu")
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[image(45)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": cell.profileImageView]))
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(45)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": cell.profileImageView]))
                
                cell.messageTextView.backgroundColor = UIColor.white
                    //UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0) //color: very light gray
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[text(200)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["text": cell.messageTextView]))
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[text]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["text": cell.messageTextView]))
                
                cell.timeLabel.textAlignment = .right
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[message][time(45)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["time": cell.timeLabel, "message": cell.messageTextView]))
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[time(10)]-3-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["time": cell.timeLabel]))
                
                cell.addSubview(cell.speakerButton)
                cell.speakerButton.translatesAutoresizingMaskIntoConstraints = false
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[text]-[image(10)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": cell.speakerButton, "text": cell.messageTextView]))
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image(10)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["image": cell.speakerButton]))
                cell.speakerButton.tag = indexPath.item
            }
            
            let size = CGSize(width: view.frame.width - 30, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            var fontSize = 14
            var height_boost = 20
            if(mess.textMessage!.characters.count > 30) {
                fontSize = 15
                height_boost = 30
                if(mess.textMessage!.characters.count > 120) {
                    fontSize = 17
                    //height_boost = 25
                }
            }
            let estimatedFrame = NSString(string: mess.textMessage!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
            cell.messageTextView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 30, height: estimatedFrame.height + CGFloat(height_boost))
            cell.messageTextView.contentInset = UIEdgeInsetsMake(20, 5, 20, 5)
            //cell.messageTextView.contentSize = cell.messageTextView.bounds.size
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
        
        var cellSize = CGSize(width: view.frame.width - 30, height: 100)
        if let mess = messages?[indexPath.item] {
            let size = CGSize(width: view.frame.width - 30, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            var fontSize = 14
            var height_boost = 20
            if(mess.textMessage!.characters.count > 30) {
                fontSize = 15
                height_boost = 30
                if(mess.textMessage!.characters.count > 120) {
                    fontSize = 17
                    //height_boost = 25
                }
            }
            let estimatedFrame = NSString(string: mess.textMessage!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
            cellSize = CGSize(width: view.frame.width - 30, height: estimatedFrame.height + CGFloat(height_boost))
            
            return cellSize
        }
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    class MessageCell: UICollectionViewCell {
        
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
        
        let speakerButton: UIButton = {
            let button = UIButton ()
            button.contentMode = .scaleAspectFill
            button.isUserInteractionEnabled = true
            button.isEnabled = true
            button.addTarget(self, action: #selector(onSpeakerPressed), for: .touchUpInside)
            button.setImage(UIImage(named: "speaker2"), for: .normal)
            return button
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
    
    // MARK: Utils
    
    func displayMessage(message:String, withPrefix prefix:String) {
        print("CB- \(prefix) - \(message)")
    }
    func displayMessage(message:String){
        print("CB- \(message)")
    }
    
    func scrollToBottom(){
        let lastItemIndex = NSIndexPath(item: ((messages?.count)! - 1), section: 0)
        messagesCollectionView.scrollToItem(at: lastItemIndex as IndexPath, at: UICollectionViewScrollPosition.top, animated: false)
    }
    
    func read(text: String){
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.4
        
        synthesizer.speak(utterance)
    }
    
    func onDisplayMessage(message: Message) {
        //update messages and collectionView
        //messages?.append(message)
        messages = chatBotManager.getMessagesList()
        for mess in messages! {
            print("DEBUG - response - ", mess.textMessage! + "//")
        }
        let insertionIndexPath = NSIndexPath(item: ((messages?.count)! - 1), section: 0)
        messagesCollectionView?.insertItems(at: [insertionIndexPath as IndexPath])
        scrollToBottom()
    }
    
    func onDisplayLogMessage(log: String) {
        displayMessage(message: log)
    }

}
