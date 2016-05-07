//
//  ViewController.swift
//  MemeMe
//
//  Created by Kevin Kell on 5/1/16.
//  Copyright © 2016 Kevin Kell. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    //-------------------------------------------------------------------------------------------------------
    //MARK: Outlets
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var mainView: UIView!
    
    //-------------------------------------------------------------------------------------------------------
    //MARK: Overrides - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatMemeTextField(topTextField, placeholder: "TOP")
        formatMemeTextField(bottomTextField, placeholder:  "BOTTOM")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        shareButton.enabled = false
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //-------------------------------------------------------------------------------------------------------
    //MARK: Actions
    
    @IBAction func pickAnImageFromAlbum (sender: AnyObject) {
        getImageFromSource(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        getImageFromSource(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func shareMeme (sender: AnyObject) {
        //create meme
        let memeImg = generateMemedImage()
        //share
        shareMemeWithOthers(memeImg)
    }
    
    @IBAction func cancelMeme (sender: AnyObject) {
        imagePicker.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.enabled = false
    }

    //-------------------------------------------------------------------------------------------------------
    //MARK: keyboard functions
    
    func keyboardWillShow(notification: NSNotification){
        if(bottomTextField.isFirstResponder()){
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
        else if(topTextField.isFirstResponder()){
            view.frame.origin.y = 0
        }
    }
    func keyboardWillHide(notification: NSNotification){
        if(bottomTextField.isFirstResponder()){
            self.view.frame.origin.y = 0
        }
    }
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue
        return keyboardSize.CGRectValue().height
    }
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //-------------------------------------------------------------------------------------------------------
    
    func formatMemeTextField(textField: UITextField, placeholder: String){
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = placeholder
        textField.textAlignment = NSTextAlignment.Center
        textField.delegate = memeTextFieldDelegate
        textField.adjustsFontSizeToFitWidth = true
        
    }
    func getImageFromSource(sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    //-------------------------------------------------------------------------------------------------------
    func shareMemeWithOthers(memeImg: UIImage) {
        let controller = UIActivityViewController(activityItems: [memeImg], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            (activityType, completed, items, error) in
            if completed {
                self.save(memeImg)
            }
        }
        presentViewController(controller, animated: true, completion: nil)
    }

    func save(memeImg: UIImage) {
        //Create the meme
        let meme = Meme( topText: topTextField.text!, bottomText: bottomTextField.text!,
                         originalImage: imagePicker.image, memeImage: memeImg)
    }
    
    func generateMemedImage() -> UIImage {
    
        toolBar.hidden = true
        navBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolBar.hidden = false
        navBar.hidden = false
        return memedImage
    }
    

    //-------------------------------------------------------------------------------------------------------
    //MARK: Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePicker.image = image
            dismissViewControllerAnimated(true, completion: { () -> Void in
                self.shareButton.enabled = true
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

