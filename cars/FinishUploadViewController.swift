//
//  FinishUploadViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/7/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class FinishUploadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CTAssetsPickerControllerDelegate {
    
    var make = NSString()
    var model = NSString()
    var year = Float()
    var miles = Float()
    var automatic = Bool()
    var exterior = NSString()
    var interior = NSString()
    var price = Float()
    var location = NSString()
    var carDescription = NSString()
    
    var tableView = UITableView()
    
    var array = NSMutableArray()
    var fileArray = NSMutableArray()
    
    var geoPoint:PFGeoPoint = PFGeoPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var rightItem = UIBarButtonItem(title: "Post", style: .Plain, target: self, action: "getPhotoData")
        self.navigationItem.rightBarButtonItem = rightItem
        
        tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 64), style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
    }
    
    func showImagePicker() {
        var picker = CTAssetsPickerController()
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func getPhotoData() {
        for (var i = 0; i < array.count; i++) {
            var asset = array.objectAtIndex(i) as ALAsset
            var representation = asset.defaultRepresentation() as ALAssetRepresentation
            var orientation = .Up as UIImageOrientation
            var orientationValue = asset.valueForProperty("ALAssetPropertyOrientation") as NSNumber!
            if (orientationValue != nil) {
                orientation = UIImageOrientation.fromRaw(orientationValue.integerValue)!
            }
            var image = UIImage(CGImage: representation.fullResolutionImage().takeUnretainedValue(), scale: 1, orientation: orientation) as UIImage
            var imageData = UIImageJPEGRepresentation(image, 1)
            var imageFile = PFFile(name: "image.jpg", data: imageData)
            fileArray.addObject(imageFile)
        }
        println (fileArray)
        
        if (fileArray.count != 0) {
            self.uploadObject()
        } else {
            println("No Images")
        }
        
    }
    
    func uploadObject() {
        var locationManager = LocationManager.sharedInstance
        var locationLatitude = NSString()
        var locationLongitude = NSString()
        locationManager.geocodeAddressString(address: self.location) {
            (geocodeInfo,placemark,error) -> Void in
            if(error != nil){
            }else{
                locationLatitude = geocodeInfo?.objectForKey("latitude") as NSString
                locationLongitude = geocodeInfo?.objectForKey("longitude") as NSString
                self.geoPoint = PFGeoPoint(latitude: locationLatitude.doubleValue, longitude: locationLongitude.doubleValue)
                
                var car = PFObject(className: "Cars")
                car.setObject(self.make, forKey: "make")
                car.setObject(self.model, forKey: "model")
                car.setObject(self.year, forKey: "year")
                car.setObject(self.miles, forKey: "miles")
                car.setObject(self.automatic, forKey: "automatic")
                car.setObject(self.exterior, forKey: "exterior")
                car.setObject(self.interior, forKey: "interior")
                car.setObject(self.carDescription, forKey: "description")
                car.setObject(self.price, forKey: "price")
                car.setObject(self.geoPoint, forKey: "location")
                car.setObject(PFUser.currentUser(), forKey: "owner")
                car.setObject(false, forKey: "sold")
                
                if (self.fileArray.count == 1) {
                    car["image1"] = self.fileArray.objectAtIndex(0)
                } else if (self.fileArray.count == 2) {
                    car["image1"] = self.fileArray.objectAtIndex(0)
                    car["image2"] = self.fileArray.objectAtIndex(1)
                } else if (self.fileArray.count == 3) {
                    car["image1"] = self.fileArray.objectAtIndex(0)
                    car["image2"] = self.fileArray.objectAtIndex(1)
                    car["image3"] = self.fileArray.objectAtIndex(2)
                } else if (self.fileArray.count == 4) {
                    car["image1"] = self.fileArray.objectAtIndex(0)
                    car["image2"] = self.fileArray.objectAtIndex(1)
                    car["image3"] = self.fileArray.objectAtIndex(2)
                    car["image4"] = self.fileArray.objectAtIndex(3)
                } else if (self.fileArray.count == 5) {
                    car["image1"] = self.fileArray.objectAtIndex(0)
                    car["image2"] = self.fileArray.objectAtIndex(1)
                    car["image3"] = self.fileArray.objectAtIndex(2)
                    car["image4"] = self.fileArray.objectAtIndex(3)
                    car["image5"] = self.fileArray.objectAtIndex(4)
                }
                
                car.saveInBackgroundWithBlock {
                    (success:Bool, error:NSError!) -> Void in
                    if (success) {
                        DTIToastCenter.defaultCenter.makeText("Car Posted!")
                        self.navigationController?.popToViewController(self.navigationController?.viewControllers[2] as MenuViewController, animated: true)
                    }
                }
            }
        }
    }
}

extension FinishUploadViewController:CTAssetsPickerControllerDelegate {
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        array = NSMutableArray(array: assets)
        tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, shouldSelectAsset asset: ALAsset!) -> Bool {
        if (picker.selectedAssets.count >= 5) {
            var alertView = UIAlertView(title: "Attention", message: "Please select no more than 5 images", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
        return (picker.selectedAssets.count < 10)
    }
}

extension FinishUploadViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return array.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1) {
            return 200
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            
            if (indexPath.section == 0) {
                cell.textLabel?.text = "Select Images (Up to 5)"
                cell.textLabel?.textAlignment = .Center
            }
            
            if (indexPath.section == 1) {
                var imageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, 200))
                imageView.clipsToBounds = true
                imageView.contentMode = .Center
                imageView.contentMode = .ScaleAspectFill
                
                var asset = array.objectAtIndex(indexPath.row) as ALAsset
                var representation = asset.defaultRepresentation() as ALAssetRepresentation
                
                var orientation = .Up as UIImageOrientation
                var orientationValue = asset.valueForProperty("ALAssetPropertyOrientation") as NSNumber!
                if (orientationValue != nil) {
                    orientation = UIImageOrientation.fromRaw(orientationValue.integerValue)!
                }
                
                imageView.image = UIImage(CGImage: representation.fullResolutionImage().takeUnretainedValue(), scale: 1, orientation: orientation)
                cell.addSubview(imageView)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.showImagePicker()
        }
    }
}


