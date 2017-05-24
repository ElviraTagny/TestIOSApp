//
//  ChatCollectionViewController.swift
//  Test
//
//  Created by Natixis on 23/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class ChatCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*class MessageCell: UICollectionViewCell {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setUpViews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setUpViews(){
            backgroundColor = UIColor.blue
        }
    }*/
    class MessageCell: UICollectionViewCell {
        
        let profileImageView: UIImageView = {
            let image = UIImageView ()
                image.contentMode = .scaleAspectFill
            return image
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
            
            profileImageView.image = UIImage(named: "user_icon")
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0(68)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": profileImageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(68)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": profileImageView]))
        }
    }


    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.setUpViews()
        
        return cell
    }
    
    /*func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }*/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: view.frame.width, height: 100)
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
    */

}
