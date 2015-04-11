//
//  CustomSegueReversed.swift
//  cars
//
//  Created by Jose Zamudio on 9/30/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class CustomSegueReversed: UIStoryboardSegue {
    
    override func perform() {
        var source:UIViewController = self.sourceViewController as UIViewController
        var destination:UIViewController = self.destinationViewController as UIViewController
        
        var transition:CATransition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        source.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
        
        source.navigationController?.pushViewController(destination, animated: false)
    }
}
