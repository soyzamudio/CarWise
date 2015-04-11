//
//  LoginViewController.swift
//  cars
//
//  Created by Jose Zamudio on 9/28/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var usernameTextField = UITextField()
    var passwordTextField = UITextField()
    var defaults = NSUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var leftItem = UIBarButtonItem(title: "Register", style: .Plain, target: self, action: "createAccountSegue")
        self.navigationItem.leftBarButtonItem = leftItem
        var rightItem = UIBarButtonItem(title: "Log In", style: .Plain, target: self, action: "loginAction")
        self.navigationItem.rightBarButtonItem = rightItem
        self.title = "Welcome!"
        defaults = NSUserDefaults.standardUserDefaults()
        
        var tableView = UITableView(frame: self.view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor(hex: "34495e")
        
        self.view.addSubview(tableView)
        
        var footerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 125))
        var image = UIImageView(frame: CGRectMake(CGRectGetMidX(footerView.frame) - 75/2, CGRectGetMidY(footerView.frame) - 75/2, 75, 75))
        image.image = UIImage(named: "logo.png")
        footerView.addSubview(image)
        tableView.tableFooterView = footerView
    }
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() != nil) {
            self.performSegueWithIdentifier("loginSegue", sender: self)
        } else {
            
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        usernameTextField.text = nil
        passwordTextField.text = nil
    }
    
    func loginAction() -> Void {
        passwordTextField.resignFirstResponder()
        PFUser.logInWithUsernameInBackground(usernameTextField.text, password:passwordTextField.text) {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                DTIToastCenter.defaultCenter.makeText("User/Password combination incorrect")
            }
        }
    }
    
    func createAccountSegue() {
        self.performSegueWithIdentifier("createAccountSegue", sender: self)
    }
    
}

extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameTextField) {
            usernameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            passwordTextField.resignFirstResponder()
            self.loginAction()
        }
        return false
    }
}

extension LoginViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(15)
        cell.textLabel?.textAlignment = .Center
        cell.textLabel?.textColor = UIColor(hex: "34495e")
        
        cell.selectionStyle = .None
        
        if (indexPath.row == 0) {
            usernameTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
            usernameTextField.textColor = UIColor.grayColor()
            usernameTextField.autocapitalizationType = .None
            usernameTextField.autocorrectionType = .No
            usernameTextField.font = UIFont.boldSystemFontOfSize(15)
            usernameTextField.textAlignment = .Center
            usernameTextField.keyboardType = .Default
            usernameTextField.returnKeyType = .Next
            usernameTextField.placeholder = "Username"
            usernameTextField.clearButtonMode = .WhileEditing
            usernameTextField.delegate = self
            
            cell.addSubview(usernameTextField)
        } else if (indexPath.row == 1) {
            passwordTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width, 44))
            passwordTextField.textColor = UIColor.grayColor()
            passwordTextField.font = UIFont.boldSystemFontOfSize(15)
            passwordTextField.textAlignment = .Center
            passwordTextField.keyboardType = .Default
            passwordTextField.returnKeyType = .Done
            passwordTextField.placeholder = "Password"
            passwordTextField.delegate = self
            passwordTextField.secureTextEntry = true
            passwordTextField.clearButtonMode = .WhileEditing
            cell.addSubview(passwordTextField)
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Login"
        } else {
            cell.textLabel?.text = "Create Account"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}