//
//  HomeTabBarViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/11/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class HomeTabBarViewController: PRTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    //MARK: Setup View Controller
    func setupViewControllers() {
        
        //Setup routines tab view controller
        let routinesTabViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutinesTabViewController") as! RoutinesTabViewController
        routinesTabViewController.managedObjectContext = managedObjectContext
        routinesTabViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        
        //Setup routines nav view controller
        let routinesTabNavigationViewController = PRBaseNavigationController()
        routinesTabNavigationViewController.managedObjectContext = managedObjectContext
        routinesTabNavigationViewController.viewControllers = [routinesTabViewController]
        
        //Setup settings tab view controller
        let settingsTabViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsTabViewController") as! SettingsTabViewController
        settingsTabViewController.managedObjectContext = managedObjectContext
        settingsTabViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
        
        //Setup settings nav view controller
        let settingsTabNavigationViewController = PRBaseNavigationController()
        routinesTabNavigationViewController.managedObjectContext = managedObjectContext
        settingsTabNavigationViewController.viewControllers = [settingsTabViewController]
                
        //Setup tab bar controller
        let viewControllerList = [ routinesTabNavigationViewController, settingsTabNavigationViewController ]
        viewControllers = viewControllerList
    }
}
