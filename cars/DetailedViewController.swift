//
//  DetailedViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/1/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import iAd
import MessageUI

class DetailedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, APParallaxViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, ADBannerViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    var carArray = NSMutableArray()
    var addFavorite = NSMutableArray()
    var rightItem = UIBarButtonItem()
    var phone:NSString = NSString()
    var email:NSString = NSString()
    
    var fileArray = NSMutableArray()
    
    var scrollView = UIScrollView()
    var pageController = UIPageControl()
    
    var location = PFGeoPoint()
    
    var tableView = UITableView()
    
    var adBanner = ADBannerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var car = carArray.objectAtIndex(0) as PFObject
        var user:PFUser = car.objectForKey("owner") as PFUser
        phone = user.objectForKey("phone") as NSString
        email = user.email as NSString
        location = car.objectForKey("location") as PFGeoPoint
        
        addFavorite = NSMutableArray(array: PFUser.currentUser().objectForKey("favorites") as NSArray)
        if (PFUser.currentUser().username != user.username) {
            if (addFavorite.containsObject(car.objectId as NSString)) {
                rightItem = UIBarButtonItem(image: UIImage(named: "like_button.png"), style: .Plain, target: self, action: "removeFavoriteToList")
                rightItem.tintColor = UIColor.redColor()
            } else {
                rightItem = UIBarButtonItem(image: UIImage(named: "like_button.png"), style: .Plain, target: self, action: "addFavoriteToList")
            }
        }
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItem = rightItem
        
        var year = car.objectForKey("year").stringValue as NSString
        var make = car.objectForKey("make") as NSString
        var model = car.objectForKey("model") as NSString
        var price = car.objectForKey("price").stringValue as NSString
        
        self.title = "\(year) \(make) \(model)"
        
        var mainView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 200))
        
        scrollView = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, 200))
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.autoresizingMask = (.FlexibleHeight | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleWidth)
        scrollView.delegate = self
        scrollView.bounces = false
        
        var singleTap = UITapGestureRecognizer(target: self, action: "scrollViewSingleTap:")
        scrollView.addGestureRecognizer(singleTap)
        
        self.loadImages(car)
        
        pageController = UIPageControl(frame: CGRectMake(0, 175, self.view.frame.width, 20))
        pageController.userInteractionEnabled = false
        pageController.autoresizingMask = (.FlexibleBottomMargin | .FlexibleHeight | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleWidth)
        pageController.numberOfPages = fileArray.count
        
        mainView.addSubview(scrollView)
        mainView.addSubview(pageController)
        
        if (car.objectForKey("sold") as Bool == true) {
            var soldImage = UIImageView(frame: scrollView.frame)
            soldImage.image = UIImage(named: "sold_image.png")
            soldImage.clipsToBounds = true
            soldImage.autoresizingMask = (.FlexibleBottomMargin | .FlexibleHeight | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleWidth)
            soldImage.contentMode = .Left
            soldImage.contentMode = .ScaleAspectFill
            scrollView.addSubview(soldImage)
        }
        
        tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - (64 + 50)), style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.addParallaxWithView(mainView, andHeight: 200)
        tableView.parallaxView.delegate = self;
        
        self.view.addSubview(tableView)
        self.loadAds()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addFavorite = NSMutableArray(array: PFUser.currentUser().objectForKey("favorites") as NSArray)
    }
    
    func removeFavoriteToList() -> Void {
        var car = carArray.objectAtIndex(0) as PFObject
        var index = addFavorite.indexOfObject(car.objectId as NSString) as Int
        addFavorite.removeObjectAtIndex(index)
        var user = PFUser.currentUser() as PFUser
        user.setObject(addFavorite, forKey: "favorites")
        user.saveInBackground()
        DTIToastCenter.defaultCenter.makeImage(UIImage(named: "like.png"))
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.rightItem.tintColor = UIColor.whiteColor()
            self.rightItem = UIBarButtonItem(image: UIImage(named: "like_button.png"), style: .Plain, target: self, action: "addFavoriteToList")
            self.tableView.reloadData()
        })
    }
    
    func addFavoriteToList() -> Void {
        var car = carArray.objectAtIndex(0) as PFObject
        if (addFavorite.containsObject(car.objectId as NSString)) {
            
        } else {
            addFavorite.insertObject(car.objectId as NSString, atIndex: 0)
            var user = PFUser.currentUser() as PFUser
            user.setObject(addFavorite, forKey: "favorites")
            user.saveInBackground()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.rightItem.tintColor = UIColor.redColor()
                self.tableView.reloadData()
            })
            self.rightItem = UIBarButtonItem(image: UIImage(named: "like_button.png"), style: .Plain, target: self, action: "removeFavoriteToList")
            DTIToastCenter.defaultCenter.makeImage(UIImage(named: "like.png"))
        }
    }
    
    func milesToDegrees(miles:Double) -> Double {
        return (miles/69)
    }
    
    func scrollViewSingleTap(gesture:UITapGestureRecognizer) {
        var vc = PhotoBrowserViewController()
        vc.fileArray = fileArray
        vc.carArray = carArray
        vc.modalPresentationStyle = .CurrentContext
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func mapViewSingleTap(gesture:UITapGestureRecognizer) {
        var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MapView") as DetailedMapViewController
        vc.geoPoint = location
        vc.view.frame = CGRectMake(0, 0, 320, 320)
        self.presentPopUpViewController(vc)
    }
    
    func loadImages(car:PFObject) {
        if (car.objectForKey("image1") != nil) {
            fileArray.addObject(car.objectForKey("image1") as PFFile)
        }
        if (car.objectForKey("image2") != nil) {
            fileArray.addObject(car.objectForKey("image2") as PFFile)
        }
        if (car.objectForKey("image3") != nil) {
            fileArray.addObject(car.objectForKey("image3") as PFFile)
        }
        if (car.objectForKey("image4") != nil) {
            fileArray.addObject(car.objectForKey("image4") as PFFile)
        }
        if (car.objectForKey("image5") != nil) {
            fileArray.addObject(car.objectForKey("image5") as PFFile)
        }
        
        for (var i = 0; i < fileArray.count; i++) {
            scrollView.addSubview(self.createImageView(fileArray.objectAtIndex(i) as PFFile, withInt: i))
            scrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(i + 1), 200)
        }
    }
    
    func createImageView(file:PFFile, withInt:Int) -> PFImageView {
        var imageView = PFImageView(frame: CGRectMake(self.view.frame.width * CGFloat(withInt), 0, self.view.frame.width, 200))
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.clipsToBounds = true
        imageView.contentMode = .Center
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = (.FlexibleBottomMargin | .FlexibleHeight | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleWidth)
        imageView.image = UIImage(named: "car_placeholder.jpg")
        imageView.file = file
        imageView.loadInBackground()
        
        return imageView
    }
    
    func loadAds() {
        adBanner = ADBannerView(frame: CGRectMake(0, tableView.frame.height, 0, 0))
        adBanner.delegate = self
        adBanner.alpha = 0
        self.view.addSubview(adBanner)
    }
    
    func showSMS() {
        if (MFMessageComposeViewController.canSendText() == false) {
            var alert = UIAlertView(title: "Error", message: "Your device doesn't support SMS!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        
        var array = [phone]
        var messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.recipients = array
        
        self.presentViewController(messageController, animated: true, completion: nil)
    }
    
    func showEmail() {
        if (MFMailComposeViewController.canSendMail() == false) {
            var alert = UIAlertView(title: "Error", message: "You don't have an email account set up on your device", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        
        var first = PFUser.currentUser().objectForKey("firstName") as NSString
        var last = PFUser.currentUser().objectForKey("lastName") as NSString
        var array = [email]
        var subject:NSString = "CarWise Query: " + self.title! as NSString
        var bodyStarter:NSString = "Sent by " + first + " " + last
        var messageController = MFMailComposeViewController()
        messageController.mailComposeDelegate = self
        messageController.setToRecipients(array)
        messageController.setSubject(subject)
        messageController.setMessageBody(bodyStarter, isHTML: false)
        self.presentViewController(messageController, animated: true, completion: nil)
    }
}

extension DetailedViewController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            break
        case MessageComposeResultFailed.value:
            var alert = UIAlertView(title: "Error", message: "Failed to send SMS!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            break
        case MessageComposeResultSent.value:
            break
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch (result.value) {
        case MFMailComposeResultCancelled.value:
            break
        case MFMailComposeResultSaved.value:
            break
        case MFMailComposeResultSent.value:
            break
        case MFMailComposeResultFailed.value:
            var alert = UIAlertView(title: "Error", message: "Failed to send Email!", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            break
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DetailedViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension DetailedViewController: ADBannerViewDelegate {
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        UIView.animateWithDuration(0.5, animations: {
            () -> Void in
            self.adBanner.alpha = 1
        })
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        UIView.animateWithDuration(0.5, animations: {
            () -> Void in
            self.adBanner.alpha = 0
        })
    }
}

extension DetailedViewController:UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x,y: 0)
        
        var pageWidth:CGFloat = self.scrollView.frame.size.width
        var fractionalPage:Double = Double(self.scrollView.contentOffset.x / pageWidth)
        var page:NSInteger = lround(fractionalPage)
        pageController.currentPage = page
    }
}

extension DetailedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 7
        } else if (section == 1) {
            return 1
        } else if (section == 2) {
            return 2
        } else  if (section == 3) {
            return 3
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 2 && indexPath.row == 0) {
            return 120
        } else if (indexPath.section == 1) {
            return 120
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Basic Information"
        } else if (section == 1) {
            return "Description"
        } else if (section == 2) {
            return "location"
        } else {
            return "Contact Owner"
        }
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        var car:PFObject = carArray.objectAtIndex(0) as PFObject
        var user:PFUser = car.objectForKey("owner") as PFUser
        var name = user.objectForKey("firstName") as NSString
        var lastName = user.objectForKey("lastName") as NSString
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: cellIdentifier)
            
            cell.detailTextLabel?.textColor = UIColor(hex: "34495e")
            cell.detailTextLabel?.font = UIFont.boldSystemFontOfSize(18)
            
            if (indexPath.section < 2) {
                cell.selectionStyle = .None
            }
            
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    cell.textLabel?.text = self.title
                    cell.textLabel?.textColor = UIColor(hex: "34495e")
                    cell.textLabel?.font = UIFont.boldSystemFontOfSize(18)
                } else if (indexPath.row == 1) {
                    cell.textLabel?.text = "Price"
                    var priceFormatter = NSNumberFormatter()
                    priceFormatter.numberStyle = .DecimalStyle
                    cell.detailTextLabel?.text = "$" + priceFormatter.stringFromNumber(car.objectForKey("price") as NSNumber) as NSString
                } else if (indexPath.row == 2) {
                    cell.textLabel?.text = "Miles"
                    var priceFormatter = NSNumberFormatter()
                    priceFormatter.numberStyle = .DecimalStyle
                    cell.detailTextLabel?.text = priceFormatter.stringFromNumber(car.objectForKey("miles") as NSNumber) as NSString
                } else if (indexPath.row == 3) {
                    cell.textLabel?.text = "Transmission"
                    var automatic:Bool = car.objectForKey("automatic") as Bool
                    if (automatic) {
                        cell.detailTextLabel?.text = "Automatic"
                    } else {
                        cell.detailTextLabel?.text = "Manual"
                    }
                } else if (indexPath.row == 4) {
                    cell.textLabel?.text = "Exterior Color"
                    cell.detailTextLabel?.text = car.objectForKey("exterior") as NSString
                } else if (indexPath.row == 5) {
                    cell.textLabel?.text = "Interior Color"
                    cell.detailTextLabel?.text = car.objectForKey("interior") as NSString
                } else if (indexPath.row == 6) {
                    cell.textLabel?.text = "Owner"
                    cell.detailTextLabel?.text = "\(name) \(lastName)"
                }
            }
            
            
            if (indexPath.section == 1) {
                var descriptionTextView = UITextView(frame: CGRectMake(10, 5, self.view.frame.width - 20, 110))
                descriptionTextView.textColor = cell.textLabel?.textColor
                descriptionTextView.font = cell.textLabel?.font
                descriptionTextView.text = car.objectForKey("description") as NSString
                descriptionTextView.editable = false
                descriptionTextView.userInteractionEnabled = false
                
                cell.addSubview(descriptionTextView)
            }
            
            if (indexPath.section == 2) {
                if (indexPath.row == 0) {
                    var geoPoint = car.objectForKey("location") as PFGeoPoint
                    var mapView = MKMapView(frame: CGRectMake(0, 0, self.view.frame.width, 120))
                    mapView.scrollEnabled = false
                    
                    var location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                    var span = MKCoordinateSpanMake(
                        self.milesToDegrees(3),
                        self.milesToDegrees(3))
                    var region = MKCoordinateRegion(center: location, span: span)
                    mapView.setRegion(region, animated: true)
                    
                    cell.addSubview(mapView)
                    
                    var annotation = MKPointAnnotation()
                    annotation.setCoordinate(CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude))
                    annotation.title = self.title
                    var priceFormatter = NSNumberFormatter()
                    priceFormatter.numberStyle = .DecimalStyle
                    annotation.subtitle = "$" + priceFormatter.stringFromNumber(car.objectForKey("price") as NSNumber) as NSString
                    mapView.addAnnotation(annotation)
                    mapView.setNeedsDisplay()
                    
                    var tap = UITapGestureRecognizer(target: self, action: "mapViewSingleTap:")
                    tap.delegate = self
                    mapView.addGestureRecognizer(tap)
                } else {
                    cell.textLabel?.text = "Get Directions"
                }
            }
            
            
            if (indexPath.section == 3) {
                if (indexPath.row == 0) {
                    cell.textLabel?.text = "Call Owner"
                    cell.imageView?.image = UIImage(named: "contact_phone.png")
                } else if (indexPath.row == 1) {
                    cell.textLabel?.text = "SMS Owner"
                    cell.imageView?.image = UIImage(named: "contact_sms.png")
                } else {
                    cell.textLabel?.text = "Email Owner"
                    cell.imageView?.image = UIImage(named: "contact_email.png")
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 2 || indexPath.section == 3) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if (indexPath.section == 2) {
            if (indexPath.row == 1) {
                var coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                var placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                var item = MKMapItem(placemark: placemark)
                item.name = self.title
                item.openInMapsWithLaunchOptions(nil)
            }
        }
        
        if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                UIApplication.sharedApplication().openURL(NSURL(string: "tel:\(phone)"))
            } else if (indexPath.row == 1) {
                self.showSMS()
            } else {
                self.showEmail()
            }
        }
    }
    
}

extension DetailedViewController:APParallaxViewDelegate {
    
    func parallaxView(view: APParallaxView!, willChangeFrame frame: CGRect) {
    }
    
    func parallaxView(view: APParallaxView!, didChangeFrame frame: CGRect) {
    }

}