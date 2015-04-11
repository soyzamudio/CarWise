//
//  LoginViewController.swift
//  CarWise
//
//  Created by Jose Zamudio on 11/3/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: FXFormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        
        var leftItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "dismiss")
        self.navigationItem.leftBarButtonItem = leftItem
        var rightItem = UIBarButtonItem(title: "Register", style: .Plain, target: self, action: "register")
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    override func awakeFromNib() {
        
        formController.form = LoginForm()
    }
    
    
    func submitLoginForm(cell: FXFormFieldCellProtocol) {
        //we can lookup the form from the cell if we want, like this:
        let form = cell.field.form as LoginForm
        
        println("Submitted by: \(form.phoneNumber)")
        NSNotificationCenter.defaultCenter().postNotificationName("userLoggedIn", object: nil)
    }
    
    func dismiss() {
        NSNotificationCenter.defaultCenter().postNotificationName("userCancelled", object: nil)
    }
    
    func register() {
        self.performSegueWithIdentifier("registerSegue", sender: self)
    }
}