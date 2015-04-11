//
//  FilterViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/10/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RMPickerViewControllerDelegate {
    
    var defaults = NSUserDefaults()
    
    var sortBy:NSMutableArray = NSMutableArray(array: ["Distance: Nearest", "Price: Low to High", "Price: High to Low", "Year: Low to High", "Year: High to Low", "Make: A to Z"])
    var carMakes:NSMutableArray = NSMutableArray()
    var carYears:NSMutableArray = NSMutableArray()
    
    var sortByPickerView  = RMPickerViewController()
    var sortByLabel = UILabel()
    
    var carMakePickerView = RMPickerViewController()
    var carMakeLabel = UILabel()
    
    var carYearSlider = UISlider()
    var carYearLabel = UILabel()
    
    var carPriceSlider = UISlider()
    var carPriceLabel = UILabel()
    var carPriceValue = NSNumber()
    
    var distanceSlider = UISlider()
    var distanceLabel = UILabel()
    var distanceValue = NSNumber()
    var distanceTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = NSUserDefaults.standardUserDefaults()
        
        var tableView = TPKeyboardAvoidingTableView(frame: self.view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.view.addSubview(tableView)
        
        var makes = NSBundle.mainBundle().pathForResource("CarMakeList", ofType: "plist")
        carMakes = NSMutableArray(contentsOfFile:makes!)
        carMakes.insertObject("No Preference", atIndex: 0)
        
        carPriceValue = defaults.objectForKey("priceMax") as NSNumber
        distanceValue = defaults.objectForKey("distance") as NSNumber
    }
    
    func openMakePickerView() {
        carMakePickerView = RMPickerViewController.pickerController()
        carMakePickerView.delegate = self
        carMakePickerView.titleLabel.text = "Select a car MAKE from the list"
        carMakePickerView.show()
    }
    
    func openSortByPickerView() {
        sortByPickerView = RMPickerViewController.pickerController()
        sortByPickerView.delegate = self
        sortByPickerView.titleLabel.text = "How do you want your search sorted?"
        sortByPickerView.show()
    }
    
    func yearMaxValueChanged(sender:UISlider) {
        carYearSlider.setValue(sender.value, animated: false)
        carYearLabel.text = String(format: "%.0f", roundf(sender.value))
    }
    
    func priceMaxValueChanged(sender:UISlider) {
        var priceFormatter = NSNumberFormatter()
        priceFormatter.numberStyle = .DecimalStyle
        carPriceSlider.setValue(sender.value, animated: false)
        carPriceValue = roundf(sender.value) * 5000
        carPriceLabel.text = "$" + priceFormatter.stringFromNumber(roundf(sender.value) * 5000) as NSString
    }
    
    func distanceValueChanged(sender:UISlider) {
        distanceSlider.setValue(sender.value, animated: false)
        distanceValue = roundf(sender.value) * 5
        distanceLabel.text = String(format: "%.0f", roundf(sender.value) * 5)
    }
}

extension FilterViewController: RMPickerViewControllerDelegate {
    func pickerViewController(vc: RMPickerViewController!, didSelectRows selectedRows: [AnyObject]!) {
        if (vc == carMakePickerView) {
            var array = selectedRows as NSArray
            var index = array.objectAtIndex(0) as Int
            carMakeLabel.text = carMakes.objectAtIndex(index) as NSString
        }
        if (vc == sortByPickerView) {
            var array = selectedRows as NSArray
            var index = array.objectAtIndex(0) as Int
            sortByLabel.text = sortBy.objectAtIndex(index) as NSString
        }
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
        }
        if (pickerView == sortByPickerView.picker) {
            return sortBy.count
        } else { return 0 }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView == carMakePickerView.picker) {
            return carMakes.objectAtIndex(row) as NSString
        }
        if (pickerView == sortByPickerView.picker) {
            return sortBy.objectAtIndex(row) as NSString
        } else { return "" }
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var size = CGFloat()
        if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
            size = 75
        } else {
            size = 44
        }
        return size
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)

            if (indexPath.row == 0) {
                var label = UILabel(frame: CGRectMake(15, 0, 270, 43.5))
                label.text = "Sort by"
                label.font = UIFont.systemFontOfSize(14)
                cell.addSubview(label)
                
                sortByLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 10, 44))
                sortByLabel.font = UIFont.boldSystemFontOfSize(16)
                sortByLabel.textColor = UIColor(hex: "34495e")
                sortByLabel.textAlignment = .Right
                sortByLabel.text = defaults.objectForKey("sort") as NSString
                cell.addSubview(sortByLabel)
            } else if (indexPath.row == 1) {
                cell.textLabel?.text = "Make"
                carMakeLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 10, 44))
                carMakeLabel.font = UIFont.boldSystemFontOfSize(16)
                carMakeLabel.textColor = UIColor(hex: "34495e")
                carMakeLabel.textAlignment = .Right
                carMakeLabel.text = defaults.objectForKey("make") as NSString
                cell.addSubview(carMakeLabel)
            } else if (indexPath.row == 2) {
                var label = UILabel(frame: CGRectMake(15, 0, 270, 31))
                label.text = "Max Year"
                label.font = UIFont.systemFontOfSize(14)
                cell.addSubview(label)
                
                carYearSlider = UISlider(frame: CGRectMake(10, 31, 200, 44))
                carYearSlider.minimumValue = 1900
                carYearSlider.maximumValue = 2014
                carYearSlider.value = defaults.objectForKey("yearMax") as NSNumber
                carYearSlider.addTarget(self, action: "yearMaxValueChanged:", forControlEvents: .ValueChanged)
                cell.addSubview(carYearSlider)
                
                carYearLabel = UILabel(frame: CGRectMake(0, 31, self.view.frame.width - 10, 44))
                carYearLabel.font = UIFont.boldSystemFontOfSize(16)
                carYearLabel.textColor = UIColor(hex: "34495e")
                carYearLabel.textAlignment = .Right
                carYearLabel.text = String(format: "%.0f", carYearSlider.value)
                cell.addSubview(carYearLabel)
            } else if (indexPath.row == 3) {
                var label = UILabel(frame: CGRectMake(15, 0, 270, 31))
                label.text = "Max Price"
                label.font = UIFont.systemFontOfSize(14)
                cell.addSubview(label)
                
                carPriceSlider = UISlider(frame: CGRectMake(10, 31, 200, 44))
                carPriceSlider.minimumValue = 1
                carPriceSlider.maximumValue = 20
                carPriceSlider.value = carPriceValue / 5000
                carPriceSlider.addTarget(self, action: "priceMaxValueChanged:", forControlEvents: .ValueChanged)
                cell.addSubview(carPriceSlider)
                
                var priceFormatter = NSNumberFormatter()
                priceFormatter.numberStyle = .DecimalStyle
                
                carPriceLabel = UILabel(frame: CGRectMake(0, 31, self.view.frame.width - 10, 44))
                carPriceLabel.font = UIFont.boldSystemFontOfSize(16)
                carPriceLabel.textColor = UIColor(hex: "34495e")
                carPriceLabel.textAlignment = .Right
                carPriceLabel.text = "$" + priceFormatter.stringFromNumber(carPriceValue) as NSString
                cell.addSubview(carPriceLabel)
            } else if (indexPath.row == 4) {
                var label = UILabel(frame: CGRectMake(15, 0, 270, 31))
                label.text = "Distance"
                label.font = UIFont.systemFontOfSize(14)
                cell.addSubview(label)
                
                distanceSlider = UISlider(frame: CGRectMake(10, 31, 200, 44))
                distanceSlider.minimumValue = 1
                distanceSlider.maximumValue = 50
                distanceSlider.value = defaults.objectForKey("distance") as NSNumber / 5
                distanceSlider.addTarget(self, action: "distanceValueChanged:", forControlEvents: .ValueChanged)
                cell.addSubview(distanceSlider)
                
                distanceLabel = UILabel(frame: CGRectMake(0, 31, self.view.frame.width - 10, 44))
                distanceLabel.font = UIFont.boldSystemFontOfSize(16)
                distanceLabel.textColor = UIColor(hex: "34495e")
                distanceLabel.textAlignment = .Right
                distanceLabel.text = String(format: "%.0f", distanceSlider.value * 5)
                cell.addSubview(distanceLabel)
            } else if (indexPath.row == 5) {
                cell.textLabel?.text = "From"
                
                distanceTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width - 10, 44))
                distanceTextField.keyboardType = .NumbersAndPunctuation
                distanceTextField.font = UIFont.boldSystemFontOfSize(16)
                distanceTextField.textColor = UIColor(hex: "34495e")
                distanceTextField.textAlignment = .Right
                distanceTextField.text = PFUser.currentUser().objectForKey("zipCode") as NSString
                distanceTextField.placeholder = PFUser.currentUser().objectForKey("zipCode") as NSString
                distanceTextField.autocorrectionType = .No
                distanceTextField.clearButtonMode = .WhileEditing
                cell.addSubview(distanceTextField)
            } else if (indexPath.row == 6) {
                var label = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                label.text = "Apply Filter"
                label.textColor = UIColor.whiteColor()
                label.textAlignment = .Center
                cell.backgroundColor = UIColor(hex: "e74c3c")
                cell.addSubview(label)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.row == 0) {
            self.openSortByPickerView()
        } else if (indexPath.row == 1) {
            self.openMakePickerView()
        } else if (indexPath.row == 6) {
            defaults = NSUserDefaults.standardUserDefaults()
            if (defaults.objectForKey("sort") as NSString != sortByLabel.text) {
                println(defaults.objectForKey("sort"))
                defaults.removeObjectForKey("sort")
                defaults.setObject(sortByLabel.text, forKey: "sort")
                println(defaults.objectForKey("sort"))
            }
            if (defaults.objectForKey("make") as NSString != carMakeLabel.text) {
                println(defaults.objectForKey("make"))
                defaults.removeObjectForKey("make")
                defaults.setObject(carMakeLabel.text, forKey: "make")
                println(defaults.objectForKey("make"))
            }
            if (defaults.objectForKey("yearMax") as NSNumber != carYearSlider.value) {
                println(defaults.objectForKey("yearMax"))
                defaults.removeObjectForKey("yearMax")
                defaults.setObject(carYearSlider.value, forKey: "yearMax")
                println(defaults.objectForKey("yearMax"))
            }
            if (CGFloat(defaults.objectForKey("priceMax") as NSNumber) != CGFloat(carPriceValue)) {
                println(defaults.objectForKey("priceMax"))
                defaults.removeObjectForKey("priceMax")
                defaults.setObject(CGFloat(carPriceValue), forKey: "priceMax")
                println(defaults.objectForKey("priceMax"))
            }
            if (CGFloat(defaults.objectForKey("distance") as NSNumber) != CGFloat(distanceValue)) {
                println(defaults.objectForKey("distance"))
                defaults.removeObjectForKey("distance")
                defaults.setObject(CGFloat(distanceValue), forKey: "distance")
                println(defaults.objectForKey("distance"))
            }
            if (PFUser.currentUser().objectForKey("zipCode") as NSString != distanceTextField.text) {
                var user:PFUser = PFUser.currentUser()
                user.setObject(distanceTextField.text, forKey: "zipCode")
                user.saveInBackground()
            }
            defaults.synchronize()
            
        }
    }
}