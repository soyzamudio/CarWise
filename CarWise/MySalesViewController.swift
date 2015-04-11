//
//  MySalesViewController.swift
//  CarWise
//
//  Created by Jose Zamudio on 10/29/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import UIKit

class MySalesViewController: UITableViewController {
    
    var sectionTitles:NSArray = ["On Sale", "Sold"]
    var user:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Cars on Sale"
        var leftItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self, action:  "showLeftMenuPressed")
        self.navigationItem.leftBarButtonItem = leftItem
        if (user) {
            var rightItem = UIBarButtonItem(image: UIImage(named: "chat.png"), style: .Plain, target: self, action: "showRightMenuPressed")
            self.navigationItem.rightBarButtonItem = rightItem
        }
        
        tableView = UITableView(frame: self.view.frame, style: .Grouped)
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }
    
    func showLeftMenuPressed() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    func showRightMenuPressed() {
        if (user) {
            self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles.objectAtIndex(section) as NSString
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(cellIdentifier) as UITableViewCell!
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            cell.textLabel?.text = "Foo"
        }
        
        return cell
    }
    
}