//
//  MyProfileViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/7/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class MyProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var usernameTextField = UITextField()
    var passwordTextField = UITextField()
    var emailTextField = UITextField()
    var phoneNumberTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var rightItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "modifyCurrentUser")
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationController?.navigationBar.topItem?.title = ""
        
        var tableView = TPKeyboardAvoidingTableView(frame: self.view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "My Profile"
    }
    
    func modifyCurrentUser() {
        var user:PFUser = PFUser.currentUser()
        user.username = usernameTextField.text as NSString
        user.password = passwordTextField.text as NSString
        user.email = emailTextField.text as NSString
        user.setObject(phoneNumberTextField.text, forKey: "phone")
        user.saveInBackground()
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension MyProfileViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameTextField) {
            usernameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            passwordTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            emailTextField.resignFirstResponder()
            phoneNumberTextField.becomeFirstResponder()
        } else {
            phoneNumberTextField.resignFirstResponder()
        }
        return false
    }
    
}

extension MyProfileViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            
            if (indexPath.row == 0) {
                usernameTextField = UITextField(frame: CGRectMake(15, 0, self.view.frame.width - 30, 44))
                usernameTextField.font = UIFont.boldSystemFontOfSize(16)
                usernameTextField.placeholder = "Enter Username"
                usernameTextField.text = PFUser.currentUser().username as NSString
                usernameTextField.returnKeyType = .Next
                usernameTextField.delegate = self
                usernameTextField.textColor = UIColor(hex: "34495e")
                cell.addSubview(usernameTextField)
            } else if (indexPath.row == 1) {
                passwordTextField = UITextField(frame: CGRectMake(15, 0, self.view.frame.width - 30, 44))
                passwordTextField.font = UIFont.boldSystemFontOfSize(16)
                passwordTextField.placeholder = "Enter Password"
                passwordTextField.returnKeyType = .Next
                passwordTextField.secureTextEntry = true
                passwordTextField.delegate = self
                passwordTextField.textColor = UIColor(hex: "34495e")
                cell.addSubview(passwordTextField)
            } else if (indexPath.row == 2) {
                emailTextField = UITextField(frame: CGRectMake(15, 0, self.view.frame.width - 30, 44))
                emailTextField.font = UIFont.boldSystemFontOfSize(16)
                emailTextField.placeholder = "Enter Password"
                emailTextField.text = PFUser.currentUser().email as NSString
                emailTextField.returnKeyType = .Next
                emailTextField.delegate = self
                emailTextField.textColor = UIColor(hex: "34495e")
                cell.addSubview(emailTextField)
            } else if (indexPath.row == 3) {
                phoneNumberTextField = UITextField(frame: CGRectMake(15, 0, self.view.frame.width - 30, 44))
                phoneNumberTextField.font = UIFont.boldSystemFontOfSize(16)
                phoneNumberTextField.placeholder = "Enter Password"
                phoneNumberTextField.text = PFUser.currentUser().objectForKey("phone") as NSString
                phoneNumberTextField.returnKeyType = .Next
                phoneNumberTextField.delegate = self
                phoneNumberTextField.textColor = UIColor(hex: "34495e")
                cell.addSubview(phoneNumberTextField)
            } else if (indexPath.row == 4) {
                cell.textLabel?.text = "Log Out"
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(16)
                cell.textLabel?.textAlignment = .Center
                cell.textLabel?.textColor = UIColor(hex: "34495e")
            }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 4) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            PFUser.logOut()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
}