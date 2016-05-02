//
//  MemeTextFieldDelegate.swift
//  MemeMe
//
//  Created by Kevin Kell on 5/1/16.
//  Copyright © 2016 Kevin Kell. All rights reserved.
//

import Foundation
import UIKit

class MemeTextFieldDelegate : NSObject, UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        
        //clear placeholder text
        if(textField.text == "TOP" || textField.text == "BOTTOM"){
            textField.text = ""
        }
        
        //displays the keyboard
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    

}

