//
//  CustomCell.swift
//  CarWise
//
//  Created by Jose Zamudio on 10/28/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var desiredSize:CGFloat = 40
//        self.imageView?.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y + 2, desiredSize, desiredSize)
        self.imageView?.contentMode = .ScaleAspectFit
        self.imageView?.layer.cornerRadius = 20
        self.imageView?.clipsToBounds = true
        
        self.textLabel?.textColor = UIColor.flatWhiteColor()
        self.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        self.detailTextLabel?.textColor = UIColor.flatWhiteColorDark()
        self.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 13)
        self.detailTextLabel?.frame.size.width = 500
    }
}