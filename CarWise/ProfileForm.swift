//
//  ProfileForm.swift
//  CarWise
//
//  Created by Jose Zamudio on 11/11/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import UIKit

class ProfileForm: NSObject, FXForm {
    
    var phoneNumber: String?
    var fullName: String?
    var email: String?
    var password: String?
    
    //because we want to rearrange how this form
    //is displayed, we've implemented the fields array
    //which lets us dictate exactly which fields appear
    //and in what order they appear
    
    func fields() -> NSArray {
        
        return [
            
            //we want to add a group header for the field set of fields
            //we do that by adding the header key to the first field in the group
            
            [FXFormFieldKey: "phoneNumber", FXFormFieldHeader: ""],
            
            //we don't need to modify these fields at all, so we'll
            //just refer to them by name to use the default settings
            
            "fullName",
            "email",
            "password",
            
            //this field doesn't correspond to any property of the form
            //it's just an action button. the action will be called on first
            //object in the responder chain that implements the submitForm
            //method, which in this case would be the AppDelegate
            
            [FXFormFieldTitle: "Save", FXFormFieldHeader: "", FXFormFieldAction: "submitProfileForm:"],
        ]
    }
}