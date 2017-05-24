//
//  RedViewController.swift
//  Test
//
//  Created by Natixis on 16/05/2017.
//  Copyright © 2017 Natixis. All rights reserved.
//

import UIKit
import Speech

class RedViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    
    @IBAction func closeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func readText(_ sender: Any) {
        if (inputTextField.text?.characters.count)! > 0 {
            let synthesizer = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: inputTextField.text!)
            utterance.rate = 0.4
            
            synthesizer.speak(utterance)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
