//
//  GreenViewController.swift
//  Test
//
//  Created by Natixis on 19/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import UIKit
import WebKit

class GreenViewController: UIViewController {

    let HTTPS_PREFIX = "https://"
    
    @IBOutlet weak var inputUrl: UITextField!
    
    @IBOutlet weak var webview: UIWebView!
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func loadWebPage(_ sender: Any) {
        if !(inputUrl.text?.isEmpty)! {
            let myUrl = URL(string: self.reformat(url: inputUrl.text!))
            let myUrlRequest = URLRequest(url: myUrl!)
            webview.loadRequest(myUrlRequest)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webviewDidStartLoad(webview : UIWebView){
        loadingView.isHidden = false
        loadingView.startAnimating()
    }

    func webviewDidFinishLoad(webview : UIWebView){
        loadingView.stopAnimating()
        loadingView.isHidden = true
    }
    
    func reformat(url: String) -> String {
        var newUrl = url
        if (url.lowercased().range(of: HTTPS_PREFIX) == nil) {
            newUrl = HTTPS_PREFIX + url
        }
        return newUrl
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
