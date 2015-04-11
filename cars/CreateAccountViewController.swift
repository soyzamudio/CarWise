//
//  CreateAccountViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/6/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var firstNameTextField = UITextField()
    var lastNameTextField = UITextField()
    var usernameTextField = UITextField()
    var passwordTextField = UITextField()
    var emailTextField = UITextField()
    var phoneNumberTextField = UITextField()
    var zipCodeTextField = UITextField()
    var array:NSArray = []
    var imageProfile = UIImage()
    var profilePicture = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var leftItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "returnToLogin")
        self.navigationItem.leftBarButtonItem = leftItem
        var rightItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: "CreateAccountAction")
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.title = "Fast & Easy"
        
        imageProfile = UIImage(named: "userImage.jpg")
        
        var tableView = TPKeyboardAvoidingTableView(frame: self.view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor(hex: "34495e")
        
        var headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 100))
        
        var cameraButton = UIButton(frame: CGRectMake(CGRectGetMidX(headerView.frame) - (75/2) - (30 + 40), CGRectGetMidY(headerView.frame) - (30/2), 30, 30))
        cameraButton.setImage(UIImage(named: "camera.png"), forState: .Normal)
        cameraButton.addTarget(self, action: "getImageCamera", forControlEvents: .TouchUpInside)
        
        var albumButton = UIButton(frame: CGRectMake(CGRectGetMidX(headerView.frame) + (75/2) + 40, CGRectGetMidY(headerView.frame) - (30/2), 30, 30))
        albumButton.setImage(UIImage(named: "album.png"), forState: .Normal)
        albumButton.addTarget(self, action: "getImageAlbum", forControlEvents: .TouchUpInside)
        
        profilePicture = UIButton(frame: CGRectMake(CGRectGetMidX(headerView.frame) - 75/2, CGRectGetMidY(headerView.frame) - 75/2, 75, 75))
        profilePicture.layer.cornerRadius = 75/2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        profilePicture.layer.borderWidth = 5
        profilePicture.setBackgroundImage(imageProfile, forState: .Normal)
        
        headerView.addSubview(cameraButton)
        headerView.addSubview(albumButton)
        headerView.addSubview(profilePicture)
        
        tableView.tableHeaderView = headerView
        
        self.view.addSubview(tableView)
        
        var footerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 125))
        var image = UIImageView(frame: CGRectMake(CGRectGetMidX(footerView.frame) - 75/2, CGRectGetMidY(footerView.frame) - 75/2, 75, 75))
        image.image = UIImage(named: "logo.png")
        footerView.addSubview(image)
        tableView.tableFooterView = footerView
    }
    
    func getImageAlbum() {
        var imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func getImageCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.allowsEditing = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            var alert = UIAlertView(title: "Error", message: "Your camera is not available to use", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func CreateAccountAction() {
        phoneNumberTextField.resignFirstResponder()
        
        var imageData = UIImageJPEGRepresentation(imageProfile, 1)
        var imageFile = PFFile(name: "image.jpg", data: imageData)
        
        var user = PFUser()
        user.setObject(firstNameTextField.text, forKey: "firstName")
        user.setObject(lastNameTextField.text, forKey: "lastName")
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        user.setObject(zipCodeTextField.text, forKey: "zipCode")
        user.setObject(phoneNumberTextField.text, forKey: "phone")
        user.setObject(array, forKey: "favorites")
        user.setObject(imageFile, forKey: "profileImage")
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if (succeeded == nil) {
                DTIToastCenter.defaultCenter.makeText("Account Created")
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func returnToLogin() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension CreateAccountViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        profilePicture.setBackgroundImage(image, forState: .Normal)
        imageProfile = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if (navigationController.isKindOfClass(UIImagePickerController)) {
//            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        }
    }
}


extension CreateAccountViewController:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == firstNameTextField) {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.becomeFirstResponder()
        } else if (textField == lastNameTextField) {
            lastNameTextField.resignFirstResponder()
            usernameTextField.becomeFirstResponder()
        } else if (textField == usernameTextField) {
            usernameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            passwordTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            emailTextField.resignFirstResponder()
            phoneNumberTextField.becomeFirstResponder()
        } else if (textField == phoneNumberTextField) {
            phoneNumberTextField.resignFirstResponder()
            zipCodeTextField.becomeFirstResponder()
        } else if (textField == zipCodeTextField) {
            zipCodeTextField.resignFirstResponder()
        }
        return false
    }
}

extension CreateAccountViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell.selectionStyle = .None
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(15)
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = UIColor(hex: "34495e")
            
            
            if (indexPath.row == 0) {
                firstNameTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                firstNameTextField.textColor = UIColor.grayColor()
                firstNameTextField.font = UIFont.boldSystemFontOfSize(15)
                firstNameTextField.textAlignment = .Center
                firstNameTextField.keyboardType = .Default
                firstNameTextField.returnKeyType = .Next
                firstNameTextField.placeholder = "First Name"
                firstNameTextField.delegate = self
                firstNameTextField.clearButtonMode = .WhileEditing
                cell.addSubview(firstNameTextField)
            } else if (indexPath.row == 1) {
                lastNameTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                lastNameTextField.textColor = UIColor.grayColor()
                lastNameTextField.font = UIFont.boldSystemFontOfSize(15)
                lastNameTextField.textAlignment = .Center
                lastNameTextField.keyboardType = .Default
                lastNameTextField.returnKeyType = .Next
                lastNameTextField.placeholder = "Last Name"
                lastNameTextField.clearButtonMode = .WhileEditing
                lastNameTextField.delegate = self
                cell.addSubview(lastNameTextField)
            } else if (indexPath.row == 2) {
                usernameTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                usernameTextField.textColor = UIColor.grayColor()
                usernameTextField.font = UIFont.boldSystemFontOfSize(15)
                usernameTextField.textAlignment = .Center
                usernameTextField.keyboardType = .Default
                usernameTextField.returnKeyType = .Next
                usernameTextField.autocapitalizationType = .None
                usernameTextField.autocorrectionType = .No
                usernameTextField.placeholder = "Username"
                usernameTextField.clearButtonMode = .WhileEditing
                usernameTextField.delegate = self
                cell.addSubview(usernameTextField)
            } else if (indexPath.row == 3) {
                passwordTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                passwordTextField.textColor = UIColor.grayColor()
                passwordTextField.font = UIFont.boldSystemFontOfSize(15)
                passwordTextField.textAlignment = .Center
                passwordTextField.keyboardType = .Default
                passwordTextField.returnKeyType = .Next
                passwordTextField.placeholder = "Password"
                passwordTextField.delegate = self
                passwordTextField.secureTextEntry = true
                passwordTextField.clearButtonMode = .WhileEditing
                cell.addSubview(passwordTextField)
            } else if (indexPath.row == 4) {
                emailTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                emailTextField.textColor = UIColor.grayColor()
                emailTextField.font = UIFont.boldSystemFontOfSize(15)
                emailTextField.textAlignment = .Center
                emailTextField.keyboardType = .EmailAddress
                emailTextField.returnKeyType = .Next
                emailTextField.autocapitalizationType = .None
                emailTextField.autocorrectionType = .No
                emailTextField.placeholder = "Email"
                emailTextField.delegate = self
                emailTextField.clearButtonMode = .WhileEditing
                cell.addSubview(emailTextField)
            } else if (indexPath.row == 5) {
                phoneNumberTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                phoneNumberTextField.textColor = UIColor.grayColor()
                phoneNumberTextField.font = UIFont.boldSystemFontOfSize(15)
                phoneNumberTextField.textAlignment = .Center
                phoneNumberTextField.keyboardType = .NumbersAndPunctuation
                phoneNumberTextField.returnKeyType = .Next
                phoneNumberTextField.autocapitalizationType = .None
                phoneNumberTextField.autocorrectionType = .No
                phoneNumberTextField.placeholder = "Phone Number"
                phoneNumberTextField.delegate = self
                phoneNumberTextField.clearButtonMode = .WhileEditing
                cell.addSubview(phoneNumberTextField)
            } else if (indexPath.row == 6) {
                zipCodeTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                zipCodeTextField.textColor = UIColor.grayColor()
                zipCodeTextField.font = UIFont.boldSystemFontOfSize(15)
                zipCodeTextField.textAlignment = .Center
                zipCodeTextField.keyboardType = .NumbersAndPunctuation
                zipCodeTextField.returnKeyType = .Done
                zipCodeTextField.autocapitalizationType = .None
                zipCodeTextField.autocorrectionType = .No
                zipCodeTextField.placeholder = "Zip Code"
                zipCodeTextField.delegate = self
                zipCodeTextField.clearButtonMode = .WhileEditing
                cell.addSubview(zipCodeTextField)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}