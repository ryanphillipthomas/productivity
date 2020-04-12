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
        routines = Routine.fetchInContext(context: managedObjectContext)
        tableView.reloadData()
    }
    
    func setNavigationBar() {
        if let nav = self.navigationController as? PRBaseNavigationController {
            nav.wuDelegate = self
            nav.configureNavBar(title: "Routines", rightImage: UIImage(systemName: "plus"))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: CreateTableViewController.classForCoder()), let nav =
            segue.destination as? PRBaseNavigationController, let createTableViewController = nav.viewControllers.first as? CreateTableViewController  {
            nav.managedObjectContext = managedObjectContext
            createTableViewController.managedObjectContext = managedObjectContext
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateTableViewCell.classForCoder()), for: indexPath) as! CreateTableViewCell
        cell.configureText(text: "")
        return cell
    }
}

extension RoutinesTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {
        performSegue(withIdentifier: String(describing: CreateTableViewController.self), sender: nil)
    }
    func didPressLeftBarButtonItem() {}
}
