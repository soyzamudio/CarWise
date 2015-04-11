//
//  MenuViewController.swift
//  cars
//
//  Created by Jose Zamudio on 9/27/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class MenuViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    var itemsTitle:NSArray = ["Favorite Cars", "My Cars on Sale", "Sell a Car", "Contact Us"]
    var itemsSubtitle:NSArray = ["List of the cars you have favorited", "View and modify your current sales", "Add a car you our database to sell", "We want to hear it all"]
    var itemsImages:NSArray = [UIImage(named: "profile.png"), UIImage(named: "favoritecars.png"), UIImage(named: "mycars.png"), UIImage(named: "sellcar.png"), UIImage(named: "contact")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.navigationItem.hidesBackButton = true
        var fixedItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedItem.width = -10
        var rightItem = UIBarButtonItem(image: UIImage(named: "menu_rightItem.png"), style: .Plain, target: self, action: "returnToView")
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItems = NSArray(objects: rightItem, fixedItem)
        
        var tableView = UITableView(frame: self.view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        var headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 150))
        
        var headerViewImage = UIImageView(frame: headerView.frame)
        headerViewImage.image = UIImage(named: "menu_bg.jpg")
        headerViewImage.clipsToBounds = true
        headerViewImage.contentMode = .Top
        headerViewImage.contentMode = .ScaleAspectFill
        headerViewImage.autoresizingMask = (.FlexibleHeight | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleWidth)
        
        var profilePicture = PFImageView(frame: CGRectMake(15, CGRectGetMidY(headerView.frame) - 100/2, 100, 100))
        profilePicture.backgroundColor = UIColor.whiteColor()
        profilePicture.layer.cornerRadius = 100/2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        profilePicture.layer.borderWidth = 5
        profilePicture.file = PFUser.currentUser().objectForKey("profileImage") as PFFile
        profilePicture.loadInBackground()
        
        var nameLabel = UILabel(frame: CGRectMake(145, 45, self.view.frame.width - 145, 25))
        var firstName:NSString = PFUser.currentUser().objectForKey("firstName") as NSString
        var lastName:NSString = PFUser.currentUser().objectForKey("lastName") as NSString
        nameLabel.text = "\(firstName) \(lastName)"
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont.boldSystemFontOfSize(20)
        
        var profileButton = UIButton(frame: CGRectMake(145, 75, self.view.frame.width - 175, 25))
        profileButton.setTitle("My Profile", forState: .Normal)
        profileButton.layer.borderColor = UIColor.whiteColor().CGColor
        profileButton.layer.cornerRadius = 5
        profileButton.layer.borderWidth = 1
        profileButton.clipsToBounds = true
        profileButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        profileButton.addTarget(self, action: "goToProfile", forControlEvents: .TouchUpInside)

        headerView.addSubview(headerViewImage)
        headerView.addSubview(profilePicture)
        headerView.addSubview(nameLabel)
        headerView.addSubview(profileButton)
        tableView.addParallaxWithView(headerView, andHeight: 150)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Settings"
    }
    
    func returnToView() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func goToProfile() {
        self.performSegueWithIdentifier("myProfileSegue", sender: self)
    }
    
    func showEmail() {
        if (MFMailComposeViewController.canSendMail() == false) {
            var alert = UIAlertView(title: "Error", message: "You don't have an email account set up on your device", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        var array = ["help@carwise.me"]
        var subject:NSString = "CarWise Customer Service: " + PFUser.currentUser().username as NSString
        var messageController = MFMailComposeViewController()
        messageController.mailComposeDelegate = self
        messageController.setToRecipients(array)
        messageController.setSubject(subject)
        self.presentViewController(messageController, animated: true, completion: nil)
    }
}

extension MenuViewController: MFMailComposeViewControllerDelegate {
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

extension MenuViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsTitle.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        
        cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        cell.imageView?.image = itemsImages.objectAtIndex(indexPath.row) as? UIImage
        
        cell.textLabel?.text = itemsTitle.objectAtIndex(indexPath.row) as NSString
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(18)
        cell.textLabel?.textColor = UIColor.grayColor()
        
        cell.detailTextLabel?.text = itemsSubtitle.objectAtIndex(indexPath.row) as NSString
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(13)
        cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.row == 0) {
            self.performSegueWithIdentifier("myFavoritesSegue", sender: self)
        }
        if (indexPath.row == 1) {
            self.performSegueWithIdentifier("myCarsSegue", sender: self)
        }
        if (indexPath.row == 2) {
            self.performSegueWithIdentifier("sellCarSegue", sender: self)
        }
        if (indexPath.row == 3) {
            self.showEmail()
        }
    }
}