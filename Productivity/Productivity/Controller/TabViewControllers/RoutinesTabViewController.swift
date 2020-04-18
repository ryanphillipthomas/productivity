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
        } else if segue.identifier == String(describing: EditRoutineTableViewController.classForCoder()), let routineTableViewController =
            segue.destination as? EditRoutineTableViewController {
            
            if let nav = self.navigationController as? PRBaseNavigationController {
                routineTableViewController.managedObjectContext = nav.managedObjectContext
            }
            
            let groupId = NSNumber(value: Date().millisecondsSince1970 as Int64)
            routineTableViewController.workingObject.id = groupId.int64Value
        }
    }
}

