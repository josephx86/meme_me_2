//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Joseph on 4/30/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static let storyboardId = "MemeEditorViewController"
    
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var galleryButton: UIBarButtonItem!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var clearButton: UIBarButtonItem!
    @IBOutlet var topBox: UITextField!
    @IBOutlet var bottomBox: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var topBar: UIToolbar!
    @IBOutlet var bottomBar: UIToolbar!
    var meme: Meme!
    var memeImage: UIImage!
    
    var keyboardHeight: CGFloat = 0
    var panView = false
    let boxBackColor = UIColor.init(white: CGFloat(1.0), alpha: CGFloat(0.15))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerKeyboardWillShow()
        applyTextStyle()
        topBox.delegate = self
        bottomBox.delegate = self
        
        // Disable camera button if there is no camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }

    @IBAction func share() {
        // Make sure there is an image
        let srcImage = imageView.image
        if srcImage == nil {
            showHint(hint: "Select an image")
            return
        }
        
        // Make sure there is some text
        let topText = topBox.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        let bottomText = bottomBox.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        let hasTopText = (topText.count > 0)
        let hasBottomText = (bottomText.count > 0)
        let hasText = (hasTopText || hasBottomText)
        if !hasText {
            showHint(hint: "Add some text for meaning")
            return
        }
        
        // Prepare UI for screen grab
        // Hide the toolbars
        // Because textfields have placeholder text showing when empty,
        // hide them when they are empty so that placeholder text is not shown in meme
        topBar.isHidden = true
        bottomBar.isHidden = true
        
        if hasTopText {
            topBox.backgroundColor = UIColor.clear
        } else {
            topBox.isHidden = true
        }
        if hasBottomText {
            bottomBox.backgroundColor = UIColor.clear
        } else {
            bottomBox.isHidden = true
        }
         
        memeImage = generateMeme()
        
        restoreUI()
        
        let shareController = UIActivityViewController(activityItems: [memeImage!], applicationActivities: nil)
        shareController.completionWithItemsHandler = shareCompletedHandler
        present(shareController, animated: true, completion: nil )
    }
    
    @IBAction func snapPicture() {
         // use camera for picture
        getPicture(type: .camera)
     }
    
    @IBAction func pickFromGallery() {
        // Pick existing image from device
        getPicture(type: .photoLibrary)
    }
    
    @IBAction func clear() {
        // Clear the ui of user data
        topBox.text = "TOP"
        bottomBox.text = "BOTTOM"
        imageView.image = nil
        hideKeyboard()
        pop()
    }
    
    func  shareCompletedHandler(_: UIActivity.ActivityType?, completed: Bool, _:  [Any]?, _: Error?) -> Void {
        if completed  {
            save()
        }
        pop()
    }
    
    func pop() {
        navigationController?.popViewController(animated: true)
    }
     
    func restoreUI() {
        topBox.isHidden = false
        topBox.backgroundColor = boxBackColor
        
        bottomBox.isHidden = false
        bottomBox.backgroundColor = boxBackColor
        
        topBar.isHidden = false
        bottomBar.isHidden = false
    }
    
    func generateMeme() -> UIImage{
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let meme = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return meme
    }
    
    func showHint(hint: String) {
        let alert = UIAlertController(title: "Umm...", message: hint, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getPicture(type: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = type
        present(controller, animated: true, completion: nil)
    }
    
    func applyTextStyle() {
        // Both top and bottom textfields use the same style
        let textStyle: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.strokeWidth : -4.0,
        ]
        
        topBox.backgroundColor = boxBackColor
        topBox.defaultTextAttributes = textStyle
        
        bottomBox.backgroundColor = boxBackColor
        bottomBox.defaultTextAttributes = textStyle
        
        // Apply alignment after style
        topBox.textAlignment = .center
        bottomBox.textAlignment = .center
    }
    
    func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissModal()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage =  info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
            imageView.image = selectedImage
        }
        
        dismissModal()
    }
        
    func registerKeyboardWillShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // Only move view frame when a text field has requested
        if panView {
            let key = UIResponder.keyboardFrameEndUserInfoKey
            if let userInfo = notification.userInfo?[key] as! NSValue? {
                keyboardHeight = userInfo.cgRectValue.height
                view.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide keyboard when enter is pressed
        hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        topBox.resignFirstResponder()
        bottomBox.resignFirstResponder()
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Restore view frame
        if panView {
            panView = false
            view.frame.origin.y += keyboardHeight
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // The bottom box must be shown when keyboard is opened
        if textField == bottomBox {
            panView = true
        }
        return true
    }
    
    func save() {
        meme = Meme(topText: topBox.text!, bottomText: bottomBox.text!, originalImage: imageView.image!, memedImage: memeImage)
        memeImage = nil
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
}

