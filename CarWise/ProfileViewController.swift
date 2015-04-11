//
//  ProfileViewController.swift
//  CarWise
//
//  Created by Jose Zamudio on 11/10/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import UIKit

class ProfileViewController: FXFormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        
        var leftItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "dismiss")
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    override func awakeFromNib() {
        formController.form = ProfileForm()
    }
    
    func submitProfileForm(cell: FXFormFieldCellProtocol) {
        //we can lookup the form from the cell if we want, like this:
        let form = cell.field.form as ProfileForm
        self.dismiss()
    }
    
    func dismiss() {
        NSNotificationCenter.defaultCenter().postNotificationName("viewDismissed", object: nil)
    }
}