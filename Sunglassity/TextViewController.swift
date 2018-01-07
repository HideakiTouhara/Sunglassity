//
//  TextViewController.swift
//  Sunglassity
//
//  Created by HideakiTouhara on 2017/12/09.
//  Copyright © 2017年 HideakiTouhara. All rights reserved.
//

import UIKit

class TextViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var inputText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func embed(in parent: UIViewController) {
        self.view.frame = parent.view.bounds
        parent.view.addSubview(self.view)
        self.didMove(toParentViewController: parent)
    }
    
    func unembed() {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        UserDefaults.standard.set(inputText.text, forKey: "input")
        self.unembed()
        return true
    }

}
