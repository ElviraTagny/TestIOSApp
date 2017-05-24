//
//  ViewController.swift
//  Test
//
//  Created by Natixis on 10/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuTableView: UITableView!
    
    @IBOutlet weak var verticalStackView: UIStackView!
    
    
    var menuList: [String] = ["Speech to text", "Text to Speech", "TouchID feature", "Send a SMS/Email", "Take a picture", "Open a webview", "Watch", "Glasses", "ChatBot"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = self.menuTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = self.menuList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //show Speech to text view
            let blueViewController: BlueViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "blueViewController") as! BlueViewController
            
            self.present(blueViewController, animated: true, completion: nil)
            
            break
        case 1:
            //show Text to speech view
            let redViewController: RedViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "redViewController") as! RedViewController
            
            self.present(redViewController, animated: true, completion: nil)
            
            break
            
        case 5:
            //show WebView
            let greenViewController: GreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "greenViewController") as! GreenViewController
            
            self.present(greenViewController, animated: true, completion: nil)
            
            break

        case 8:
            let chatcollectionviewcontroller: ChatCollectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatcollectionviewcontroller") as! ChatCollectionViewController
            
            self.present(chatcollectionviewcontroller, animated: true, completion: nil)
            
            break

        default:
            showToast(message: "Not yet implemented")
        }
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 180, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 11.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

