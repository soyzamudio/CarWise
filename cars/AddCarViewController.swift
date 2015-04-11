//
//  AddCarViewController.swift
//  cars
//
//  Created by Jose Zamudio on 9/28/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class AddCarViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, RMPickerViewControllerDelegate, ACEAutocompleteDelegate, ACEAutocompleteDataSource {
    
    var carYears:NSMutableArray = NSMutableArray()
    var carMakes:NSMutableArray = NSMutableArray()
    var carModels:NSMutableArray = NSMutableArray()
    
    var carMakePickerView = RMPickerViewController()
    var carMakeLabel = UILabel()
    
    var carModelTextField = UITextField()
    
    var carYearPickerView = RMPickerViewController()
    var carYearLabel = UILabel()
    
    var carMilesTextField = UITextField()
    var carExteriorColorTextField = UITextField()
    var carInteriorColorTextField = UITextField()
    var carPriceTextField = TSCurrencyTextField()
    var carLocationTextField = UITextField()
    
    var carDescriptionTextView = UITextView()
    
    var carAutomaticSwitch = UISwitch()
    
    var automaticBool = Bool()
    
    var location:PFGeoPoint = PFGeoPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var rightItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "finishUpload")
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItem = rightItem
        
        var tableView = TPKeyboardAvoidingTableView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 64), style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        for (var i = 1940; i <= 2014; i++) {
            var str = "\(i)"
            carYears.insertObject(str, atIndex: 0)
        }
        
        var makes = NSBundle.mainBundle().pathForResource("CarMakeList", ofType: "plist")
        carMakes = NSMutableArray(contentsOfFile:makes!)
        
        var query = PFQuery(className: "Cars")
        query.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!) -> Void in
            var carArray:NSArray = objects
            if (objects != nil) {
                for (var i = 0; i < objects.count; i++) {
                    var carObject:PFObject = carArray.objectAtIndex(i) as PFObject
                    if (self.carModels.containsObject(carObject.objectForKey("model"))) {
                    } else {
                        self.carModels.addObject(carObject.objectForKey("model"))
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Sell a Car"
    }
    
    func finishUpload() {
        self.performSegueWithIdentifier("finishUploadSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "finishUploadSegue") {
            let viewController:FinishUploadViewController = segue.destinationViewController as FinishUploadViewController
            viewController.make = carMakeLabel.text!
            viewController.model = carModelTextField.text
            viewController.year = (carYearLabel.text! as NSString).floatValue
            viewController.miles = (carMilesTextField.text as NSString).floatValue
            viewController.automatic = automaticBool
            viewController.exterior = carExteriorColorTextField.text
            viewController.interior = carInteriorColorTextField.text
            viewController.price = carPriceTextField.amount as Float
            viewController.location = carLocationTextField.text
            if (carDescriptionTextView.text == nil) {
                viewController.carDescription = "No description provided by owner"
            } else {
                viewController.carDescription = carDescriptionTextView.text
            }
        }
    }
    
    func switchChanged() {
        automaticBool = carAutomaticSwitch.on
    }
    
    func openMakePickerView() {
        carMakePickerView = RMPickerViewController.pickerController()
        carMakePickerView.delegate = self
        carMakePickerView.titleLabel.text = "Select a car MAKE from the list"
        carMakePickerView.show()
    }
    
    func openYearPickerView() {
        carYearPickerView = RMPickerViewController.pickerController()
        carYearPickerView.delegate = self
        carYearPickerView.titleLabel.text = "Select a car YEAR from the list"
        carYearPickerView.show()
    }
    
    func uploadCarObject() -> Void {
        carModelTextField.resignFirstResponder()
        carMilesTextField.resignFirstResponder()
        carExteriorColorTextField.resignFirstResponder()
        carInteriorColorTextField.resignFirstResponder()
        carDescriptionTextView.resignFirstResponder()
        carLocationTextField.resignFirstResponder()
        carPriceTextField.resignFirstResponder()
    
        var locationManager = LocationManager.sharedInstance
        var locationLatitude = NSString()
        var locationLongitude = NSString()
        locationManager.geocodeAddressString(address: carLocationTextField.text as NSString) {
            (geocodeInfo,placemark,error) -> Void in
            if(error != nil){
            }else{
                locationLatitude = geocodeInfo?.objectForKey("latitude") as NSString
                locationLongitude = geocodeInfo?.objectForKey("longitude") as NSString
                self.location = PFGeoPoint(latitude: locationLatitude.doubleValue, longitude: locationLongitude.doubleValue)
                
                var make = self.carMakeLabel.text as NSString?
                var year = self.carYearLabel.text as NSString?
                
                var car = PFObject(className: "Cars")
                car.setObject(make, forKey: "make")
                car.setObject(self.carModelTextField.text, forKey: "model")
                car.setObject(year?.floatValue, forKey: "year")
                car.setObject((self.carMilesTextField.text as NSString).floatValue, forKey: "miles")
                car.setObject(self.automaticBool, forKey: "automatic")
                car.setObject(self.carExteriorColorTextField.text, forKey: "exterior")
                car.setObject(self.carInteriorColorTextField.text, forKey: "interior")
                if (self.carDescriptionTextView.text != nil) {
                    car.setObject(self.carDescriptionTextView.text as NSString, forKey: "description")
                }
                car.setObject(self.carPriceTextField.amount as Float, forKey: "price")
                car.setObject(self.location, forKey: "location")
                car.setObject(PFUser.currentUser(), forKey: "owner")
                car.saveInBackgroundWithBlock {
                    (success:Bool, error:NSError!) -> Void in
                    if (success) {
                        var alert = SCLAlertView()
                        alert.showSuccess(self, title: "Congratulations!", subTitle: "You have posted your car on our system succesfully!")
                    } else {
                        var alert = SCLAlertView()
                        alert.showError(self, title: "Error!", subTitle: "Something went wrong, please try again!", closeButtonTitle: "Try Again")
                    }
                }
            }
        }
    }
}

extension AddCarViewController: RMPickerViewControllerDelegate {
    func pickerViewController(vc: RMPickerViewController!, didSelectRows selectedRows: [AnyObject]!) {
        if (vc == carMakePickerView) {
            var array = selectedRows as NSArray
            var index = array.objectAtIndex(0) as Int
            carMakeLabel.text = carMakes.objectAtIndex(index) as NSString
        } else if (vc == carYearPickerView) {
            var array = selectedRows as NSArray
            var index = array.objectAtIndex(0) as Int
            carYearLabel.text = carYears.objectAtIndex(index) as NSString
        } else { }
    }
    
    func pickerViewControllerDidCancel(vc: RMPickerViewController!) {
        println("Selection was canceled")
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> NSInteger {
        return 1
    }
    
    func pickerView(pickerView:UIPickerView, numberOfRowsInComponent component:NSInteger) -> NSInteger {
        if (pickerView == carMakePickerView.picker) {
            return carMakes.count
        } else if (pickerView == carYearPickerView.picker) {
            return carYears.count
        } else { return 0 }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView == carMakePickerView.picker) {
            return carMakes.objectAtIndex(row) as NSString
        } else if (pickerView == carYearPickerView.picker) {
            return carYears.objectAtIndex(row) as NSString
        } else { return "" }
    }
}


extension AddCarViewController:ACEAutocompleteDelegate, ACEAutocompleteDataSource {

    func textField(textField: UITextField!, didSelectObject object: AnyObject!, inInputView inputView: ACEAutocompleteInputView!) {
        textField.text = object as NSString
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == carModelTextField) {
            carModelTextField.resignFirstResponder()
            carMilesTextField.becomeFirstResponder()
        } else if (textField == carMilesTextField) {
            carMilesTextField.resignFirstResponder()
            carExteriorColorTextField.becomeFirstResponder()
        } else if (textField == carExteriorColorTextField) {
            carExteriorColorTextField.resignFirstResponder()
            carInteriorColorTextField.becomeFirstResponder()
        } else if (textField == carInteriorColorTextField) {
            carInteriorColorTextField.resignFirstResponder()
            carPriceTextField.becomeFirstResponder()
        } else if (textField == carPriceTextField) {
            carPriceTextField.resignFirstResponder()
            carLocationTextField.becomeFirstResponder()
        } else if (textField == carLocationTextField) {
            carLocationTextField.resignFirstResponder()
            carDescriptionTextView.becomeFirstResponder()
        } else if (textField == carDescriptionTextView) {
            carDescriptionTextView.resignFirstResponder()
        }
        
        return false
    }

    func minimumCharactersToTrigger(inputView: ACEAutocompleteInputView!) -> UInt {
        return 1
    }

    func inputView(inputView: ACEAutocompleteInputView!, itemsFor query: String!, result resultBlock: (([AnyObject]!) -> Void)!) {
        if (resultBlock != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                var array = NSMutableArray()
                array = self.carModels.mutableCopy() as NSMutableArray
                var data = NSMutableArray()
                for s in array {
                    if (s.hasPrefix(query)) {
                        data.addObject(s)
                    }
                }

                dispatch_async(dispatch_get_main_queue()) { resultBlock(data) }
            }
        }
    }
}

extension AddCarViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 9
        } else if (section == 1) {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1) {
            return 120
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Basic Information"
        } else {
            return "description"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    cell.textLabel?.text = "Make"
                    carMakeLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 15, 44))
                    carMakeLabel.font = UIFont.boldSystemFontOfSize(16)
                    carMakeLabel.textColor = UIColor(hex: "34495e")
                    carMakeLabel.textAlignment = .Right
                    carMakeLabel.text = "Car Make"
                    cell.addSubview(carMakeLabel)
                } else if (indexPath.row == 1) {
                    cell.textLabel?.text = "Model"
                    carModelTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width - 15, 44))
                    carModelTextField.autocorrectionType = .No
                    carModelTextField.returnKeyType = .Next
                    carModelTextField.font = UIFont.boldSystemFontOfSize(16)
                    carModelTextField.textAlignment = .Right
                    carModelTextField.placeholder = "Car Model"
                    carModelTextField.textColor = UIColor(hex: "34495e")
                    carModelTextField.setAutocompleteWithDataSource(self, delegate: self, customize: {
                        (inputView:ACEAutocompleteInputView!) -> Void in
                        inputView.font = UIFont.systemFontOfSize(16)
                        inputView.textColor = UIColor.whiteColor()
                        inputView.backgroundColor = UIColor.blackColor()
                        
                    })
                    cell.addSubview(carModelTextField)
                } else if (indexPath.row == 2) {
                    cell.textLabel?.text = "Year"
                    carYearLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 15, 44))
                    carYearLabel.font = UIFont.boldSystemFontOfSize(16)
                    carYearLabel.textColor = UIColor(hex: "34495e")
                    carYearLabel.textAlignment = .Right
                    carYearLabel.text = "Car Year"
                    cell.addSubview(carYearLabel)
                } else if (indexPath.row == 3) {
                    cell.textLabel?.text = "Miles"
                    carMilesTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width - 15, 44))
                    carMilesTextField.autocorrectionType = .No
                    carMilesTextField.returnKeyType = .Next
                    carMilesTextField.font = UIFont.boldSystemFontOfSize(16)
                    carMilesTextField.textAlignment = .Right
                    carMilesTextField.keyboardType = .NumbersAndPunctuation
                    carMilesTextField.textColor = UIColor(hex: "34495e")
                    carMilesTextField.placeholder = "Miles on Car"
                    
                    cell.addSubview(carMilesTextField)
                } else if (indexPath.row == 4) {
                    cell.textLabel?.text = "Automatic"
                    carAutomaticSwitch = UISwitch()
                    var switchSize:CGSize = carAutomaticSwitch.sizeThatFits(CGSizeZero)
                    carAutomaticSwitch.frame = CGRectMake(
                        cell.contentView.bounds.width - switchSize.width - 10,
                        (cell.contentView.bounds.size.height - switchSize.height) / 2,
                        switchSize.width,
                        switchSize.height
                    )
                    carAutomaticSwitch.autoresizingMask = .FlexibleLeftMargin
                    carAutomaticSwitch.addTarget(self, action: "switchChanged", forControlEvents: .ValueChanged)
                    cell.addSubview(carAutomaticSwitch)
                } else if (indexPath.row == 5) {
                    cell.textLabel?.text = "Exterior Color"
                    carExteriorColorTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width - 15, 44))
                    carExteriorColorTextField.textAlignment = .Right
                    carExteriorColorTextField.font = UIFont.boldSystemFontOfSize(16)
                    carExteriorColorTextField.placeholder = "Enter Exterior Color"
                    carExteriorColorTextField.returnKeyType = .Next
                    carExteriorColorTextField.delegate = self
                    carExteriorColorTextField.textColor = UIColor(hex: "34495e")
                    cell.addSubview(carExteriorColorTextField)
                } else if (indexPath.row == 6) {
                    cell.textLabel?.text = "Interior Color"
                    carInteriorColorTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width - 15, 44))
                    carInteriorColorTextField.textAlignment = .Right
                    carInteriorColorTextField.font = UIFont.boldSystemFontOfSize(16)
                    carInteriorColorTextField.placeholder = "Enter Interior Color"
                    carInteriorColorTextField.returnKeyType = .Next
                    carInteriorColorTextField.delegate = self
                    carInteriorColorTextField.textColor = UIColor(hex: "34495e")
                    cell.addSubview(carInteriorColorTextField)
                } else if (indexPath.row == 7) {
                    cell.textLabel?.text = "Price"
                    carPriceTextField = TSCurrencyTextField(frame: CGRectMake(0, 0, self.view.frame.width - 15, 44))
                    carPriceTextField.keyboardType = .NumbersAndPunctuation
                    carPriceTextField.font = UIFont.boldSystemFontOfSize(16)
                    carPriceTextField.textAlignment = .Right
                    carPriceTextField.delegate = self
                    carPriceTextField.returnKeyType = .Next
                    carPriceTextField.textColor = UIColor(hex: "34495e")
                    cell.addSubview(carPriceTextField)
                } else if (indexPath.row == 8) {
                    carLocationTextField = UITextField(frame: CGRectMake(10, 0, self.view.frame.width - 20, 44))
                    carLocationTextField.placeholder = "Address, City, State, Zip Code"
                    carLocationTextField.delegate = self
                    carLocationTextField.textColor = UIColor(hex: "34495e")
                    carLocationTextField.returnKeyType = .Done
                    carLocationTextField.textAlignment = .Center
                    cell.addSubview(carLocationTextField)
                }
            } else if (indexPath.section == 1) {
                carDescriptionTextView = UITextView(frame: CGRectMake(10, 5, self.view.frame.width - 20, 110))
                carDescriptionTextView.returnKeyType = .Done
                carDescriptionTextView.delegate = self
                cell.addSubview(carDescriptionTextView)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                self.openMakePickerView()
            } else if (indexPath.row == 2) {
                self.openYearPickerView()
            }
        }
    }
    
}