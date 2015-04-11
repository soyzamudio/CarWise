//
//  AppDelegate.swift
//  cars
//
//  Created by Jose Zamudio on 9/25/14.
//  Copyright (c) 2014 cars. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        
        DTIToastCenter.defaultCenter.registerCenter()
        
        UINavigationBar.appearance().barTintColor = UIColor(hex: "34495e")
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        UINavigationBar.appearance().translucent = false
        
        Parse.setApplicationId("91IkkD3oh5LolLZT6TrJjkm1Z1isuIiLBYLjcYWV", clientKey: "a50KsISXZIrGTiZojfqxtTdDee9wzIMY3Uuvqlvt")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        var defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.valueForKey("version") == nil) {
            defaults.setObject(25, forKey: "distance")
            defaults.setObject(2014, forKey: "yearMax")
            defaults.setObject(100000, forKey: "priceMax")
            defaults.setObject("No Preference", forKey: "make")
            defaults.setObject("Distance: Nearest", forKey: "sort")
            defaults.setFloat((NSBundle.mainBundle().infoDictionary["CFBundleVersion"] as NSString).floatValue, forKey: "version")
            
            defaults.synchronize()
        }
        
        if (NSUserDefaults.standardUserDefaults().floatForKey("version") == (NSBundle.mainBundle().infoDictionary["CFBundleVersion"])?.floatValue) {
            
        } else {
            defaults.setObject(25, forKey: "distance")
            defaults.setObject(2014, forKey: "yearMax")
            defaults.setObject(100000, forKey: "priceMax")
            defaults.setObject("No Preference", forKey: "make")
            defaults.setObject("Distance: Nearest", forKey: "sort")
            defaults.setFloat((NSBundle.mainBundle().infoDictionary["CFBundleVersion"] as NSString).floatValue, forKey: "version")
            
            defaults.synchronize()
        }
        

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

