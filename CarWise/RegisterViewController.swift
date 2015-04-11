//
//  RegisterViewController.swift
//  CarWise
//
//  Created by Jose Zamudio on 11/5/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController: FXFormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Account"
    }
    
    override func awakeFromNib() {
        
        formController.form = RegistrationForm()
    }
    
    func submitRegistrationForm(cell: FXFormFieldCellProtocol) {
        //we can lookup the form from the cell if we want, like this:
        let form = cell.field.form as RegistrationForm
        
        if (form.phoneNumber? == nil) {
            self.showAlert("phone number").show()
        }
        if (form.fullName? == nil) {
            self.showAlert("full name").show()
        }
        if (form.email? == nil) {
            self.showAlert("email").show()
        }
        if (form.password? == nil) {
            self.showAlert("password").show()
        }
        else {
            println("Submitted by: \(form.fullName)")
            NSNotificationCenter.defaultCenter().postNotificationName("userLoggedIn", object: nil)
        }
    }
    
    func showAlert(missing: NSString) -> UIAlertView {
        var alert = UIAlertView(title: "Something Is Missing", message: "It seems like you forgot to enter your \(missing)", delegate: self, cancelButtonTitle: "Try Again")
        return alert
    }

}