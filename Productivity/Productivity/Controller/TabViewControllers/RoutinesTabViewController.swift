//
//  RoutinesTabViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/17/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class RoutinesTabViewController: PRBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: RoutinesTableViewController.classForCoder()), let routineTableViewController =
            segue.destination as? RoutinesTableViewController {
            routineTableViewController.managedObjectContext = managedObjectContext
        }
    }
}

