//
//  MyCarsViewController.swift
//  cars
//
//  Created by Jose Zamudio on 9/30/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class MyCarsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, SWTableViewCellDelegate {
    
    var myCarsArray:NSArray = NSArray()
    var tableView = TPKeyboardAvoidingTableView()
    var detailedArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        
        tableView = TPKeyboardAvoidingTableView(frame: self.view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Cars on Sale"
        self.queryForMyCars()
    }
    
    func queryForMyCars() -> Void {
        var query = PFQuery(className: "Cars")
        query.whereKey("owner", equalTo: PFUser.currentUser())
        query.whereKey("sold", equalTo: false)
        query.orderByDescending("year")
        query.cachePolicy = kPFCachePolicyCacheThenNetwork
        query.includeKey("owner")
        query.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!) -> Void in
            if (objects != nil) {
                self.myCarsArray = objects
            }
            self.tableView.reloadData()
        }
    }
    
    func rightButtonsSold() -> NSArray {
        var rightUtilityButtons = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(hex: "e74c3c"), title: "Sold")
        return rightUtilityButtons
    }
}

extension MyCarsViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = "No Cars" as NSString
        var font = UIFont.boldSystemFontOfSize(26) as UIFont
        var textColor = UIColor(hex: "34495e") as UIColor
        
        var attributes = [NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor]
        
        var attributedString = NSAttributedString(string: text, attributes: attributes)
        
        return attributedString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = "You have not posted any cars on sale on our database" as NSString
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

extension MyCarsViewController: UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCarsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as SWTableViewCell!
        
        
        if (cell == nil) {
            cell = SWTableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
            
            var car:PFObject = myCarsArray.objectAtIndex(indexPath.row) as PFObject
            
            var year = car.objectForKey("year").stringValue as NSString
            var make = car.objectForKey("make") as NSString
            var model = car.objectForKey("model") as NSString
            var price = car.objectForKey("price") as NSNumber
            var image = car.objectForKey("image1") as PFFile
            var sold = car.objectForKey("sold") as Bool
            
            cell.rightUtilityButtons = self.rightButtonsSold()
            cell.delegate = self
            
            cell.textLabel?.text = "\(year) \(make) \(model)"
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(18)
            
            var formatter = NSNumberFormatter()
            formatter.numberStyle = .DecimalStyle
            
            cell.detailTextLabel?.text = "$" + formatter.stringFromNumber(price) as NSString
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(13)
            
            if (sold) {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .DisclosureIndicator
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        detailedArray.removeAllObjects()
        var car = myCarsArray.objectAtIndex(indexPath.row) as PFObject
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
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        var cellIndexPath = self.tableView.indexPathForCell(cell) as NSIndexPath!
        var car:PFObject = myCarsArray.objectAtIndex(cellIndexPath.row) as PFObject
        
        if (car.objectForKey("sold") as Bool == false) {
            switch (index) {
            case 0:
                var query = PFQuery(className:"Cars")
                query.getObjectInBackgroundWithId(car.objectId as NSString) {
                    (object: PFObject!, error: NSError!) -> Void in
                    if (object != nil) {
                        object.setObject(true, forKey: "sold")
                        object.saveInBackground()
                    }
                    self.view.setNeedsDisplay()
                    self.tableView.reloadData()
                }
                break;
            default:
                break;
            }
        }
    }
}