//
//  PRBaseTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData

open class PRBaseTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var wuLoading: PRLoadingAnimation?

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.configureAccessibilityIdentifiers()
        setTableView()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLoader()                    //If we are leaving a view, we should never have a loader still active
    }
    
    //MARK: Loader Animation
       func startLoader() {
           
           //Setup Loader
           let keyWindow = UIApplication.shared.connectedScenes
           .filter({$0.activationState == .foregroundActive})
           .map({$0 as? UIWindowScene})
           .compactMap({$0})
           .first?.windows
           .filter({$0.isKeyWindow}).first
           
           wuLoading = PRLoadingAnimation()
           keyWindow?.addSubview(wuLoading!)
           wuLoading?.centerMe()
           
           if let loader = wuLoading {
               view.isUserInteractionEnabled = false
               DispatchQueue.main.async {
                   loader.fadeIn()
               }
           }
       }
       
       func stopLoader() {
           if let loader = wuLoading {
               view.isUserInteractionEnabled = true
               DispatchQueue.main.async {
                   loader.fadeOut()
               }
           }
       }
    
    func setTableView() {
        tableView.contentInset.top = 20
        tableView.backgroundColor = UIColor(red: 0.157, green: 0.161, blue: 0.165, alpha: 1.00)
        tableView.separatorColor = .clear
    }
    
    // MARK: - Table view data source
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 0    //Handle in subclass
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0    //Handle in subclass
    }
}
