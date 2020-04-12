//
//  RoutinesTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/11/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class RoutinesTableViewController: PRBaseTableViewController {
    var routines = [Routine]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
    }
    
    func setNavigationBar() {
        if let nav = self.navigationController as? PRBaseNavigationController {
            nav.wuDelegate = self
            nav.configureNavBar(title: "Routines", rightImage: UIImage(systemName: "plus"))
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routines.count
    }
}

extension RoutinesTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {
        performSegue(withIdentifier: String(describing: CreateTableViewController.self), sender: nil)
    }
    func didPressLeftBarButtonItem() {}
}
