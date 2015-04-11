//
//  ViewController.swift
//  CarWise
//
//  Created by Jose Zamudio on 10/26/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import UIKit
import QuartzCore
import MapKit
import CoreLocation

class ViewController: UIViewController, RMPickerViewControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var distance = UIButton()
    var sortBy:NSMutableArray = NSMutableArray(array: ["Distance: 5 Miles", "Distance: 15 Miles", "Distance: 25 Miles", "Distance: 50 Miles", "Distance: 75 Miles", "Distance: 100 Miles", "Distance: 150 Miles"])
    var distancePickerView  = RMPickerViewController()
    var mapView = MKMapView()
    var span:CLLocationDegrees = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CarWise"
        var leftItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self, action:  "showLeftMenuPressed")
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.configureMapView()
        self.configureFilterView()
        self.getCurrentLocation()
    }
    
    func configureMapView() {
        mapView = MKMapView(frame: self.view.frame)
        mapView.setUserTrackingMode(.Follow, animated: true)
        var trackingBtn = MKUserTrackingBarButtonItem(mapView: mapView)
        self.view.addSubview(mapView)
    }
    
    func degreesToMiles(miles:CLLocationDegrees) -> CLLocationDegrees {
        var degrees:CLLocationDegrees = miles / 69
        return degrees
    }
    
    func getCurrentLocation() {
        AKLocationManager.startLocatingWithUpdateBlock(
            { (location:CLLocation!) -> Void in
                var region:MKCoordinateRegion = MKCoordinateRegion(center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: self.degreesToMiles(self.span), longitudeDelta: self.degreesToMiles(self.span)))
                var adjustedRegion = self.mapView.regionThatFits(region)
                self.mapView.setRegion(adjustedRegion, animated: false)
            }, failedBlock: { (error:NSError!) -> Void in
                println("Could not get current location")
        })
    }
    
    func configureFilterView() {
        var filterView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 40))
        filterView.backgroundColor = UIColor(red: 241/255, green: 242/255, blue: 243/255, alpha: 0.9)
        
        filterView.layer.shadowColor = UIColor.blackColor().CGColor
        filterView.layer.shadowOffset = CGSizeMake(0, 1)
        filterView.layer.shadowRadius = 0
        filterView.layer.shadowOpacity = 0.25
        
        var image = UIImageView(frame: CGRectMake(0, 0, 35, 40))
        image.image = UIImage(named: "distance.png")
        image.contentMode = .Center
        filterView.addSubview(image)
        
        var distanceView = UIView(frame: CGRectMake(35, CGRectGetMidY(filterView.frame) - 14, self.view.frame.width - 100, 28))
        distanceView.backgroundColor = UIColor(hexString: "ffffff", alpha: 0)
        distanceView.layer.shadowColor = UIColor.flatBlackColor().CGColor
        distanceView.layer.shadowOpacity = 0.3
        distanceView.layer.shadowOffset = CGSizeMake(1, 0)
        distanceView.layer.shadowRadius = 0
        
        distance = UIButton(frame: CGRectMake(0, 0, distanceView.frame.width, distanceView.frame.height))
        distance.setTitle("Distance: 5 Miles", forState: .Normal)
        distance.setTitleColor(UIColor(hexString: "48493f"), forState: .Normal)
        distance.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 29/2)
        distance.contentHorizontalAlignment = .Left
        distance.addTarget(self, action: "openSortByPickerView", forControlEvents: .TouchUpInside)
        
        distanceView.addSubview(distance)
        filterView.addSubview(distanceView)
        self.view.addSubview(filterView)
    }
    
    func showLeftMenuPressed() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func openSortByPickerView() {
        distancePickerView = RMPickerViewController.pickerController()
        distancePickerView.delegate = self
        distancePickerView.titleLabel.text = "How do you want your search sorted?"
        distancePickerView.show()
    }
}

extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
}

extension ViewController: RMPickerViewControllerDelegate {
    func pickerViewController(vc: RMPickerViewController!, didSelectRows selectedRows: [AnyObject]!) {
        if (vc == distancePickerView) {
            var array = selectedRows as NSArray
            var index = array.objectAtIndex(0) as Int
            distance.setTitle(sortBy.objectAtIndex(index) as NSString, forState: .Normal)
            if (distance.titleLabel?.text == "Distance: 5 Miles") {
                span = 5
                self.getCurrentLocation()
            } else if (distance.titleLabel?.text == "Distance: 15 Miles") {
                span = 15
                self.getCurrentLocation()
            } else if (distance.titleLabel?.text == "Distance: 25 Miles") {
                span = 25
                self.getCurrentLocation()
            } else if (distance.titleLabel?.text == "Distance: 50 Miles") {
                span = 50
                self.getCurrentLocation()
            } else if (distance.titleLabel?.text == "Distance: 75 Miles") {
                span = 75
                self.getCurrentLocation()
            } else if (distance.titleLabel?.text == "Distance: 100 Miles") {
                span = 100
                self.getCurrentLocation()
            } else if (distance.titleLabel?.text == "Distance: 150 Miles") {
                span = 150
                self.getCurrentLocation()
            }
        }
    }
    
    func pickerViewControllerDidCancel(vc: RMPickerViewController!) {
        println("Selection was canceled")
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> NSInteger {
        return 1
    }
    
    func pickerView(pickerView:UIPickerView, numberOfRowsInComponent component:NSInteger) -> NSInteger {
        if (pickerView == distancePickerView.picker) {
            return sortBy.count
        } else { return 0 }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView == distancePickerView.picker) {
            return sortBy.objectAtIndex(row) as NSString
        } else { return "" }
    }
}

