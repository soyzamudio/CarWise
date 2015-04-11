//
//  LeftMenuViewController.swift
//  CarWise
//
//  Created by Jose Zamudio on 10/26/14.
//  Copyright (c) 2014 zamudio. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var firstMenu:NSArray = ["Home", "My Sales", "Post for Sale", "Messages", "Contact Us", "Log Out"]
    var tableView = UITableView()
    var user:Bool = false
    var loginView = AFPopupView()
    var profilePopupView = AFPopupView()
    var navController = UINavigationController()
    var profileView = UINavigationController()
    var notLoggedInView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var colors:NSArray = [UIColor(hexString: "6c7463"), UIColor(hexString: "48493f")]
        self.view.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: self.view.frame, andColors: colors)
        
        var userInfo = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 100))
        userInfo.backgroundColor = UIColor(hexString: "000000", alpha: 0.15)
        var userImage = UIImageView(frame: CGRectMake(20, ((80/2) + 20) - (40/2), 40, 40))
        userImage.contentMode = .ScaleAspectFit
        userImage.layer.cornerRadius = 20
        userImage.clipsToBounds = true
        userImage.layer.borderColor = UIColor.flatWhiteColor().CGColor
        userImage.layer.borderWidth = 2
        userImage.image = UIImage(named: "foto.jpg")
        var userName = UIButton(frame: CGRectMake(80, 60 - 22, self.view.frame.width - 40, 20))
        userName.setTitle("Jose Zamudio", forState: .Normal)
        userName.titleLabel?.font = UIFont.systemFontOfSize(14)
        userName.setTitleColor(UIColor.flatWhiteColor(), forState: .Normal)
        userName.contentHorizontalAlignment = .Left
        userName.addTarget(self, action: "showUserProfileView", forControlEvents: .TouchUpInside)
        var userEmail = UIButton(frame: CGRectMake(80, 60 - 2, self.view.frame.width - 40, 20))
        userEmail.setTitle("zamudio@outlook.com", forState: .Normal)
        userEmail.titleLabel?.font = UIFont.systemFontOfSize(13)
        userEmail.setTitleColor(UIColor.flatWhiteColorDark(), forState: .Normal)
        userEmail.contentHorizontalAlignment = .Left
        userEmail.addTarget(self, action: "showUserProfileView", forControlEvents: .TouchUpInside)
        
        userInfo.addSubview(userImage)
        userInfo.addSubview(userName)
        userInfo.addSubview(userEmail)
        userInfo.addSubview(self.addSeparator(CGRectMake(0, userInfo.frame.height - 1, self.view.frame.width, 1)))
        self.view.addSubview(userInfo)
        
        tableView = UITableView(frame: CGRectMake(0, 100, self.view.frame.width, self.view.frame.height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        
        var idxPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.selectRowAtIndexPath(idxPath, animated: true, scrollPosition: .Bottom)
        
        self.view.addSubview(tableView)
        
        if (!user) {
            notLoggedInView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
            notLoggedInView.backgroundColor = UIColor(hexString: "000000", alpha: 0.7)
            
            var informationView = UIView(frame: CGRectMake(0, 0, 260, self.view.frame.height))
            var notLoggedLabel = UILabel(frame: CGRectMake(0, CGRectGetMidY(notLoggedInView.frame) - 150, 250, 35))
            notLoggedLabel.text = "You are not logged in"
            notLoggedLabel.textColor = UIColor.flatWhiteColor()
            notLoggedLabel.textAlignment = .Center
            var logInButton = UIButton(frame: CGRectMake(0, CGRectGetMidY(notLoggedInView.frame) - 120, 250, 35))
            logInButton.setTitle("Log In or Register", forState: .Normal)
            logInButton.setTitleColor(UIColor(hexString: "90c640"), forState: .Normal)
            logInButton.addTarget(self, action: "showLoginView", forControlEvents: .TouchUpInside)
            
            informationView.addSubview(logInButton)
            informationView.addSubview(notLoggedLabel)
            notLoggedInView.addSubview(informationView)
            self.view.addSubview(notLoggedInView)
        }
    }
    
    func addSeparator(frame:CGRect) -> UIView {
        var separator = UIView(frame: frame)
        separator.backgroundColor = UIColor(hexString: "90c640")
        return separator
    }
    
    func showUserProfileView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("dismissed"), name: "viewDismissed", object: nil)
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        profileView = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as UINavigationController
        profilePopupView = AFPopupView.popupWithView(profileView.view)
        profilePopupView.show()
    }
    
    func showLoginView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loggedIn"), name: "userLoggedIn", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("cancelled"), name: "userCancelled", object: nil)
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        navController = storyboard.instantiateViewControllerWithIdentifier("loginViewController") as UINavigationController
        loginView = AFPopupView.popupWithView(navController.view)
        loginView.show()
    }
    
    func dismissed() {
        profilePopupView.hide()
    }
    
    func loggedIn() {
        notLoggedInView.removeFromSuperview()
        self.view.setNeedsDisplay()
        tableView.reloadData()
        loginView.hide()
    }
    
    func cancelled() {
        loginView.hide()
    }
}

extension LeftMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cells = Int()
        if (section == 0) {
            cells = firstMenu.count
        }
        return cells
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "\(indexPath.section),\(indexPath.row)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as CustomCell!
        
        if (cell == nil) {
            cell = CustomCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
            cell.backgroundColor = UIColor.clearColor()
            var customColorView = UIView()
            customColorView.backgroundColor = UIColor(hexString: "000000", alpha: 0.4)
            cell.selectedBackgroundView = customColorView
            
            if (indexPath.section == 0) {
                cell.indentationLevel = cell.indentationLevel + 1;
                cell.textLabel?.text = firstMenu.objectAtIndex(indexPath.row) as NSString
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var homeController = ViewController()
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: { () -> Void in
                    var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    var navigationController = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationController") as UINavigationController
                    if (self.menuContainerViewController.centerViewController as UINavigationController != navigationController) {
                        self.menuContainerViewController.centerViewController = navigationController
                    } 
                })
            } else if (indexPath.row == 1) {
                self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: { () -> Void in
                    var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    var navigationController = storyboard.instantiateViewControllerWithIdentifier("MySalesNavigationController") as UINavigationController
                    self.menuContainerViewController.centerViewController = navigationController
                })
            } else if (indexPath.row == 5) {
                self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: { () -> Void in
                    var idxPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.selectRowAtIndexPath(idxPath, animated: true, scrollPosition: .Bottom)
                    self.view.addSubview(self.notLoggedInView)
                })
            } else {
                self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: { () -> Void in })
            }
        }
    }
}