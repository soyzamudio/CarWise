//
//  DetailedMapViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/8/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DetailedMapViewController: UIViewController {
    
    var geoPoint = PFGeoPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var mapView = MKMapView(frame: CGRectMake(0, 0, 320, 320))
        
        var location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        var span = MKCoordinateSpanMake(
            self.milesToDegrees(2),
            self.milesToDegrees(2))
        var region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        self.view.addSubview(mapView)
        
        var annotation = MKPointAnnotation()
        annotation.setCoordinate(CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude))
        mapView.addAnnotation(annotation)
        mapView.setNeedsDisplay()
    }
    
    func milesToDegrees(miles:Double) -> Double {
        return (miles/69)
    }
}