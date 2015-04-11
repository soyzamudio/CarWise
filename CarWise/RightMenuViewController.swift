//
//  RightMenuViewController.swift
//  CarWise
//
//  Created by Jose Zamudio on 10/27/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import UIKit

class RightMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var colors:NSArray = [UIColor(hexString: "6c7463"), UIColor(hexString: "48493f")]
        self.view.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: self.view.frame, andColors: colors)
    }
    
}