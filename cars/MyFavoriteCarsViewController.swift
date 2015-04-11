//
//  MyFavoriteCarsViewController.swift
//  cars
//
//  Created by Jose Zamudio on 10/4/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit

class MyFavoriteCarsViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var favoriteCarArray = NSMutableArray()
    var detailedArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "My Favorite Cars"
        favoriteCarArray = PFUser.currentUser().objectForKey("favorites") as NSMutableArray
    }
}

extension MyFavoriteCarsViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = "No Favorites" as NSString
        var font = UIFont.boldSystemFontOfSize(26) as UIFont
        var textColor = UIColor(hex: "34495e") as UIColor
        
        var attributes = [NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor]
        
        var attributedString = NSAttributedString(string: text, attributes: attributes)
        
        return attributedString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = "You have not liked any cars yet" as NSString
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

extension MyFavoriteCarsViewController: UITableViewDelegate, UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteCarArray.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        
        cell.accessoryType = .DisclosureIndicator
        
        var query = PFQuery(className: "Cars")
        query.whereKey("objectId", equalTo: favoriteCarArray.objectAtIndex(indexPath.row) as NSString)
        query.getFirstObjectInBackgroundWithBlock{
            (car:PFObject!, error:NSError!) -> Void in
            if (car != nil) {
                var year = car.objectForKey("year").stringValue as NSString
                var make = car.objectForKey("make") as NSString
                var model = car.objectForKey("model") as NSString
                var price = car.objectForKey("price") as NSNumber
                var image = car.objectForKey("image1") as PFFile
                
                cell.textLabel?.text = "\(year) \(make) \(model)"
                cell.textLabel?.textColor = UIColor.grayColor()
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(18)
                
                var formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                
                cell.detailTextLabel?.text = "$" + formatter.stringFromNumber(price) as NSString
                cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
                cell.detailTextLabel?.font = UIFont.systemFontOfSize(13)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var query = PFQuery(className: "Cars")
        query.whereKey("objectId", equalTo: favoriteCarArray.objectAtIndex(indexPath.row) as NSString)
        query.includeKey("owner")
        query.getFirstObjectInBackgroundWithBlock {
            (object:PFObject!, error:NSError!) -> Void in
            if (object != nil) {
                self.detailedArray.removeAllObjects()
                var car = object as PFObject
                self.detailedArray.addObject(car)
            }
            self.performSegueWithIdentifier("detailSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "detailSegue") {
            let viewController:DetailedViewController = segue!.destinationViewController as DetailedViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            viewController.carArray = detailedArray
        }
    }
    
}