//
//  AppDelegate.swift
//  FindTweets
//
//  Created by Andrew Muncey on 23/07/2015.
//  Copyright (c) 2015 University of Chester. All rights reserved.
//

import UIKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let consumerKey = "ADD_KEY_HERE"
        let consumerSecret = "ADD_KEY_HERE"
        
        Twitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
        return true

    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }


}

