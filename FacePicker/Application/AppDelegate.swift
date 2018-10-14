//
//  AppDelegate.swift
//  FacePicker
//
//  Created by matthew on 9/5/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // DropDown setup
        ViewHelper.setDropDownAppearance()
        
        // SplitViewController setup
        guard let splitViewController = self.window?.rootViewController as? UISplitViewController,
            let clientListNavController = splitViewController.viewControllers.first as? UINavigationController,
            let clientListController = clientListNavController.topViewController as? ClientListController,
            let clientDetailNavController = splitViewController.viewControllers.last as? UINavigationController,
            let clientDetailController = clientDetailNavController.topViewController as? ClientDetailController
            else {
                Application.onError("AppDelegate.application: Unexpected view controller configuration at application startup!")
                return false
        }
        clientListController.delegate = clientDetailController
        clientDetailController.delegate = clientListController
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.preferredPrimaryColumnWidthFraction = 0.25
        clientDetailController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        CoreDataManager.shared.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Application.logInfo("Application will enter foreground.")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Application.logInfo("Application did become active.")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.shared.saveContext()
    }
}

