//
//  PinAnnotation.swift
//  cars
//
//  Created by Jose Zamudio on 10/10/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    
    private var coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    var title:String = ""
    var subtitle:String = ""
    var index:Int = 0
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
}