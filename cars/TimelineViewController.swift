//
//  TimelineViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/9/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, MKMapViewDelegate, FPPopoverControllerDelegate {
    
    var defaults = NSUserDefaults() // user defaults for the filters
    var mapView = MKMapView() // mapview containing the car object's pins
    var geoPoint = PFGeoPoint() // GeoPoint to location of user's preferred zip code
    var outerView = UIView() // Outer view containing tableView
    var tableView = UITableView() // tableView containing the car objects
    var listButton = UIButton() // UIButton to pop up outerView
    var carArray = NSMutableArray() // array containing all car objects
    var detailedArray = NSMutableArray() // array passed to DetailedView
    var tabIndex = Int() // index number of object liked
    var rightItem = UIBarButtonItem() // Filter UIButtonBar for Navigation Bar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var fixedItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedItem.width = -10
        var leftItem = UIBarButtonItem(image: UIImage(named: "leftItem.png"), style: .Plain, target: self, action: "menuSegue")
        self.navigationItem.leftBarButtonItems = NSArray(objects: fixedItem, leftItem)
        rightItem = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "filterPopover:")
        self.navigationItem.rightBarButtonItem = rightItem
        defaults = NSUserDefaults.standardUserDefaults()
        
        var locationManager = LocationManager.sharedInstance
        var locationLatitude = NSString()
        var locationLongitude = NSString()
        locationManager.geocodeAddressString(address: PFUser.currentUser().objectForKey("zipCode") as NSString) {
            (geocodeInfo,placemark,error) -> Void in
            if(error != nil){
            } else {
                locationLatitude = geocodeInfo?.objectForKey("latitude") as NSString
                locationLongitude = geocodeInfo?.objectForKey("longitude") as NSString
                self.geoPoint = PFGeoPoint(latitude: locationLatitude.doubleValue, longitude: locationLongitude.doubleValue)
                var location = CLLocationCoordinate2D(latitude: self.geoPoint.latitude, longitude: self.geoPoint.longitude)
                var span = MKCoordinateSpanMake(
                    self.milesToDegrees(self.defaults.objectForKey("distance") as NSNumber / 2),
                    self.milesToDegrees(self.defaults.objectForKey("distance") as NSNumber / 2))
                var region = MKCoordinateRegion(center: location, span: span)
                self.mapView.setRegion(region, animated: true)
            }
            self.loadCars()
        }
        
        self.view.addSubview(self.createMapView())
        self.view.addSubview(self.createTableView())
    }
    
    override func viewDidDisappear(animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        carArray.removeAllObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "CarWise"
        rightItem.title = "Filter"
        self.loadCars()
        tableView.reloadData()
    }
    
    func loadCars() {
        var carMake = self.defaults.objectForKey("make") as NSString
        var carYearMax = self.defaults.objectForKey("yearMax") as Float
        var carPriceMax = self.defaults.objectForKey("priceMax") as Float
        var distance = self.defaults.objectForKey("distance") as Double
        var orderBy = self.defaults.objectForKey("sort") as NSString
        
        var query = PFQuery(className: "Cars")
        query.whereKey("owner", notEqualTo: PFUser.currentUser())
        query.whereKey("location", nearGeoPoint: geoPoint, withinMiles: distance)
        if (carMake.isEqualToString("No Preference")) {
        } else {
            query.whereKey("make", equalTo: carMake)
        }
        query.whereKey("year", lessThanOrEqualTo: carYearMax)
        query.whereKey("price", lessThanOrEqualTo: carPriceMax)
        query.whereKey("sold", equalTo: false)
        query.includeKey("owner")
        query.cachePolicy = kPFCachePolicyCacheThenNetwork
        if (orderBy.isEqualToString("Distance: Nearest")) {
        } else if (orderBy.isEqualToString("Price: Low to High")) {
            query.orderByAscending("price")
        } else if (orderBy.isEqualToString("Price: High to Low")) {
            query.orderByDescending("price")
        } else if (orderBy.isEqualToString("Year: Low to High")) {
            query.orderByAscending("year")
        } else if (orderBy.isEqualToString("Year: High to Low")) {
            query.orderByDescending("year")
        } else if (orderBy.isEqualToString("Make: A to Z")) {
            query.orderByAscending("make")
        }
        query.findObjectsInBackgroundWithBlock {
            (array:[AnyObject]!, error:NSError!) -> Void in
            if (array != nil) {
                self.carArray = NSMutableArray(array: array)
            }
            self.addAnnotation()
            self.tableView.reloadData()
        }
    } // End of function
    
    func menuSegue() {
        self.performSegueWithIdentifier("menuSegue", sender: self)
    }
    
    func createMapView() -> UIView {
        var outerMapView = UIView(frame: self.view.frame)
        
        mapView = MKMapView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        mapView.delegate = self
        outerMapView.addSubview(mapView)
        
        return outerMapView
    }
    
    func addAnnotation() {
        for (var i = 0; i < self.carArray.count; i++) {
            var car = self.carArray.objectAtIndex(i) as PFObject
            var year = car.objectForKey("year").stringValue as NSString
            var make = car.objectForKey("make") as NSString
            var model = car.objectForKey("model") as NSString
            var price = car.objectForKey("price") as NSNumber
            var location = car.objectForKey("location") as PFGeoPoint
            
            var annotation = PinAnnotation()
            annotation.setCoordinate(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            annotation.title = "\(year) \(make) \(model)"
            var priceFormatter = NSNumberFormatter()
            priceFormatter.numberStyle = .DecimalStyle
            annotation.subtitle = "$" + priceFormatter.stringFromNumber(price) as NSString
            annotation.index = i
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func milesToDegrees(miles:Double) -> Double {
        return (miles/69)
    }
    
    func createTableView() -> UIView {
        outerView = UIView(frame: CGRectMake(0, self.view.frame.height - (64 + 25), self.view.frame.width, self.view.frame.height))
        outerView.layer.shadowColor = UIColor.blackColor().CGColor
        outerView.layer.shadowOpacity = 0.4
        outerView.layer.shadowOffset = CGSizeMake(0, -1)
        outerView.layer.shadowRadius = 2
        
        var headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 25))
        headerView.backgroundColor = UIColor(hex: "e74c3c")
        listButton = UIButton(frame: headerView.frame)
        listButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        listButton.setImage(UIImage(named: "arrow_show.png"), forState: .Normal)
        listButton.addTarget(self, action: "moveTableViewUp", forControlEvents: .TouchUpInside)
        headerView.addSubview(listButton)
        
        tableView = UITableView(frame: CGRectMake(0, 25, self.view.frame.width, self.view.frame.height - (64 + 25)))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        outerView.addSubview(headerView)
        outerView.addSubview(tableView)
        
        return outerView
    }
    
    func moveTableViewUp() {
        UIView.animateWithDuration(0.25, animations: {
            () -> Void in
            self.outerView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            self.listButton.setImage(UIImage(named: "arrow_hide.png"), forState: .Normal)
            self.listButton.addTarget(self, action: "moveTableViewDown", forControlEvents: .TouchUpInside)
        })
    }
    
    func moveTableViewDown() {
        UIView.animateWithDuration(0.25, animations: {
            () -> Void in
            self.outerView.frame = CGRectMake(0, self.view.frame.height - 25, self.view.frame.width, self.view.frame.height)
            self.listButton.setImage(UIImage(named: "arrow_show.png"), forState: .Normal)
            self.listButton.addTarget(self, action: "moveTableViewUp", forControlEvents: .TouchUpInside)
        })
    }
    
    func likePressed(sender:UIButton) {
        var tempObj = carArray.objectAtIndex(sender.tag) as PFObject
        var addFavorite = NSMutableArray(array: PFUser.currentUser().objectForKey("favorites") as NSArray)
        if (addFavorite.containsObject(tempObj.objectId as NSString)) {
            
        } else {
            addFavorite.insertObject(tempObj.objectId as NSString, atIndex: 0)
            var user = PFUser.currentUser() as PFUser
            user.setObject(addFavorite, forKey: "favorites")
            user.saveInBackground()
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                sender.backgroundColor = UIColor.redColor()
                sender.setImage(UIImage(named: "unlike_button.png"), forState: .Normal)
                sender.addTarget(self, action: "unlikePressed:", forControlEvents: .TouchUpInside)
            })
            
            DTIToastCenter.defaultCenter.makeImage(UIImage(named: "like.png"))
            tableView.reloadData()
        }
    }
    
    func unlikePressed(sender:UIButton) {
        var tempObj = carArray.objectAtIndex(sender.tag) as PFObject
        var addFavorite = NSMutableArray(array: PFUser.currentUser().objectForKey("favorites") as NSArray)
        var index = addFavorite.indexOfObject(tempObj.objectId as NSString) as Int
        addFavorite.removeObjectAtIndex(index)
        var user = PFUser.currentUser() as PFUser
        user.setObject(addFavorite, forKey: "favorites")
        user.saveInBackground()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            sender.backgroundColor = UIColor.whiteColor()
            sender.setImage(UIImage(named: "like_button.png"), forState: .Normal)
            sender.addTarget(self, action: "likePressed:", forControlEvents: .TouchUpInside)
        })
        
        DTIToastCenter.defaultCenter.makeImage(UIImage(named: "like.png"))
        tableView.reloadData()
    }
    
    func pinInfoTapped(sender:AnyObject) {
        detailedArray.removeAllObjects()
        var car = carArray.objectAtIndex(tabIndex) as PFObject
        detailedArray.addObject(car)
        self.performSegueWithIdentifier("detailSegue", sender: self)
    }
    
    // MARK: Filter Popover
    
    func filterPopover(sender:AnyObject) {
        rightItem.title = "Close"
        
        var vc = FilterViewController()
        var popover = FPPopoverController(viewController: vc)
        popover.contentSize = CGSizeMake(320, 420)
        popover.arrowDirection = FPPopoverNoArrow
        popover.border = false
        popover.delegate = self
        popover.tint = FPPopoverLightGrayTint
        popover.presentPopoverFromPoint(CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame) - 300))
    }
}

extension TimelineViewController: FPPopoverControllerDelegate {
    func popoverControllerDidDismissPopover(popoverController: FPPopoverController!) {
        rightItem.title = "Filter"
        defaults = NSUserDefaults.standardUserDefaults()
        mapView.removeAnnotations(mapView.annotations)
        carArray.removeAllObjects()
        var locationManager = LocationManager.sharedInstance
        var locationLatitude = NSString()
        var locationLongitude = NSString()
        locationManager.geocodeAddressString(address: PFUser.currentUser().objectForKey("zipCode") as NSString) {
            (geocodeInfo,placemark,error) -> Void in
            if(error != nil){
            } else {
                
                locationLatitude = geocodeInfo?.objectForKey("latitude") as NSString
                locationLongitude = geocodeInfo?.objectForKey("longitude") as NSString
                self.geoPoint = PFGeoPoint(latitude: locationLatitude.doubleValue, longitude: locationLongitude.doubleValue)
                var location = CLLocationCoordinate2D(latitude: self.geoPoint.latitude, longitude: self.geoPoint.longitude)
                var span = MKCoordinateSpanMake(
                    self.milesToDegrees(self.defaults.objectForKey("distance") as NSNumber / 2),
                    self.milesToDegrees(self.defaults.objectForKey("distance") as NSNumber / 2))
                var region = MKCoordinateRegion(center: location, span: span)
                self.mapView.setRegion(region, animated: true)
            }
            self.loadCars()
        }
    }
}

extension TimelineViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        var customAnnotation = view.annotation as PinAnnotation
        tabIndex = customAnnotation.index
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var identifier = "MyLocation"
        
        if (annotation is PinAnnotation) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.image = UIImage(named: "carPin.png")
            } else {
                annotationView.annotation = annotation
                annotationView.image = UIImage(named: "carPin.png")
            }
            annotationView.enabled = true
            annotationView.canShowCallout = true
            
            var rightButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
            rightButton.addTarget(self, action: "pinInfoTapped:", forControlEvents: .TouchUpInside)
            annotationView.rightCalloutAccessoryView = rightButton
            
            return annotationView
        } else {
            return nil
        }
    }
}

extension TimelineViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = "No Search Results" as NSString
        var font = UIFont.boldSystemFontOfSize(26) as UIFont
        var textColor = UIColor(hex: "34495e") as UIColor
        
        var attributes = [NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor]
        
        var attributedString = NSAttributedString(string: text, attributes: attributes)
        
        return attributedString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = "We do not have any cars with your specifications as of now" as NSString
        var font = UIFont.systemFontOfSize(18) as UIFont
        var textColor = UIColor.lightGrayColor() as UIColor
        
        var attributes = NSMutableDictionary()
        var paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        attributes.setObject(font, forKey: NSFontAttributeName)
        attributes.setObject(textColor, forKey: NSForegroundColorAttributeName)
        attributes.setObject(paragraph, forKey: NSParagraphStyleAttributeName)
        
        var attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        return attributedString
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "placeholder_carwise.png")
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
}


extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 320
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        
        cell.selectionStyle = .None;
        cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        var car = carArray.objectAtIndex(indexPath.row) as PFObject
        var user:PFUser = car.objectForKey("owner") as PFUser
        
        var year = car.objectForKey("year").stringValue as NSString
        var make = car.objectForKey("make") as NSString
        var model = car.objectForKey("model") as NSString
        var price = car.objectForKey("price") as NSNumber
        var location = car.objectForKey("location") as PFGeoPoint
        
        var carView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 300))
        carView.backgroundColor = UIColor.whiteColor()
        carView.layer.shadowColor = UIColor.blackColor().CGColor
        carView.layer.shadowOpacity = 0.8
        carView.layer.shadowOffset = CGSizeMake(0, 0)
        carView.layer.shadowRadius = 0.5
        
        var image = PFImageView(frame: CGRectMake(0, 0, carView.frame.width, 246))
        image.backgroundColor = UIColor.whiteColor()
        image.clipsToBounds = true
        image.contentMode = .Center
        image.contentMode = .ScaleAspectFill
        image.image = UIImage(named: "car_placeholder.jpg")
        if (car.objectForKey("image1") != nil) {
            image.file = car.objectForKey("image1") as PFFile
            image.loadInBackground()
        }
        
        carView.addSubview(image)
        
        if (car.objectForKey("sold") as Bool == true) {
            var soldImage = UIImageView(frame: image.frame)
            soldImage.image = UIImage(named: "sold_image.png")
            soldImage.clipsToBounds = true
            soldImage.contentMode = .ScaleAspectFill
            carView.addSubview(soldImage)
        }
        
        var carInformation = UILabel(frame: CGRectMake(15, image.frame.height, image.frame.width - 30, 35))
        carInformation.text = "\(year) \(make) \(model)"
        carInformation.font = UIFont.boldSystemFontOfSize(16)
        carInformation.textColor = UIColor(hex: "34495e")
        
        var priceFormatter = NSNumberFormatter()
        priceFormatter.numberStyle = .DecimalStyle
        
        var locationCar = CLLocation(latitude: location.latitude, longitude: location.longitude)
        var crnLoc = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        var distance = crnLoc.distanceFromLocation(locationCar)/1609.344
        var formatter:NSString = NSString(format: "%.02f", distance)
        
        var otherInformation = UILabel(frame: CGRectMake(15, image.frame.height + carInformation.frame.height - 5, image.frame.width - 30, 14))
        otherInformation.text = "$" + priceFormatter.stringFromNumber(price) as NSString + " • " + "\(formatter) miles away"
        otherInformation.font = UIFont.systemFontOfSize(14)
        otherInformation.textColor = UIColor.grayColor()
        
        var likeButton = UIButton(frame: CGRectMake(image.frame.width - 15 - 82/2, 260, 82/2, 55/2))
        likeButton.layer.borderColor = UIColor(hex: "e5e5e5").CGColor
        likeButton.layer.borderWidth = 1
        likeButton.layer.cornerRadius = 5
        likeButton.clipsToBounds = true
        likeButton.tag = indexPath.row
        
        var addFavorite = NSMutableArray(array: PFUser.currentUser().objectForKey("favorites") as NSArray)
        if (addFavorite.containsObject(car.objectId as NSString)) {
            likeButton.backgroundColor = UIColor.redColor()
            likeButton.setImage(UIImage(named: "unlike_button.png"), forState: .Normal)
            likeButton.addTarget(self, action: "unlikePressed:", forControlEvents: .TouchUpInside)
        } else {
            likeButton.backgroundColor = UIColor.whiteColor()
            likeButton.setImage(UIImage(named: "like_button.png"), forState: .Normal)
            likeButton.addTarget(self, action: "likePressed:", forControlEvents: .TouchUpInside)
        }
        
        var ownerImage = PFImageView(frame: CGRectMake(image.frame.width - (82/2 + 15 + 50), 260, 82/2, 55/2))
        ownerImage.layer.borderColor = UIColor(hex: "e5e5e5").CGColor
        ownerImage.layer.borderWidth = 1
        ownerImage.layer.cornerRadius = 5
        ownerImage.autoresizingMask = (.FlexibleHeight | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleWidth)
        ownerImage.contentMode = .ScaleAspectFill
        ownerImage.clipsToBounds = true
        ownerImage.file = user.objectForKey("profileImage") as PFFile
        ownerImage.loadInBackground()
        
        carView.addSubview(carInformation)
        carView.addSubview(otherInformation)
        carView.addSubview(ownerImage)
        carView.addSubview(likeButton)
        
        cell.addSubview(carView)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        detailedArray.removeAllObjects()
        var car = carArray.objectAtIndex(indexPath.row) as PFObject
        detailedArray.addObject(car)
        self.performSegueWithIdentifier("detailSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "detailSegue") {
            let viewController:DetailedViewController = segue!.destinationViewController as DetailedViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            viewController.carArray = detailedArray
        }
    }
}