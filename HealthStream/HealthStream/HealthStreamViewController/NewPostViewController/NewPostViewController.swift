//
//  NewPostViewController.swift
//  HealthStream
//
//  Created by Jan Rombout on 13/06/2019.
//  Copyright © 2019 Rommed BV. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD


class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var camaraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItem.Style.done, target: self, action: #selector(onSendTapped(_:)))
        
        camaraButton?.addTarget(self, action: #selector(onAddImageTapped(_:)), for: UIControl.Event.touchUpInside)
        libraryButton?.addTarget(self, action: #selector(onAddImageTapped(_:)), for: UIControl.Event.touchUpInside)
        
        textView?.becomeFirstResponder()

    }

    @objc func onAddImageTapped(_ sender:UIButton)
    {
        let picker:UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) && sender == camaraButton
        {
            picker.sourceType = UIImagePickerController.SourceType.camera
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) && sender == libraryButton
        {
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        else
        {
            return
        }
        
        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        
        imageView?.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    }
    
    @objc func onSendTapped(_ sender:UIBarButtonItem)
    {
        if  let text:String = textView?.text,
            let currentUser:PFUser = PFUser.current()
        {
            if !text.isEmpty
            {
                let post:PFObject = PFObject(className: "Post")
                post.setObject(text, forKey: "text")
                post.setObject(currentUser, forKey: "user")
                
                if  let image:UIImage           = imageView?.image,
                    let data:Data               = image.pngData(),
                    let imageFile:PFFileObject  = PFFileObject(data: data)
                {
                    post.setObject(imageFile, forKey: "image")
                }
                
                let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = MBProgressHUDMode.indeterminate
                hud.label.text = "Versturen...."
                
                post.saveInBackground() {
                    (success, error) in
                    hud.hide(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
        }
        
        let alert:UIAlertController = UIAlertController(title: "Onvolledig", message: "Vul een tekst in", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Begrepen", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
