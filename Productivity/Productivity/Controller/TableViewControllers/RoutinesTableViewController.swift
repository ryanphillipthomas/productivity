//
//  RoutinesTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/11/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class RoutinesTableViewController: PRBaseFetchedResultsTableViewController {
    
    override func viewDidLoad() {
        super.fetchRequest = Routine.sortedFetchRequest
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: CreateTableViewController.classForCoder()), let nav =
            segue.destination as? PRBaseNavigationController, let createTableViewController = nav.viewControllers.first as? CreateTableViewController  {
            nav.managedObjectContext = managedObjectContext
            createTableViewController.managedObjectContext = managedObjectContext
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateHeaderFooterHeaderFooterView.classForCoder())) as! CreateHeaderFooterHeaderFooterView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}

extension RoutinesTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {
        performSegue(withIdentifier: String(describing: CreateTableViewController.self), sender: nil)
    }
    func didPressLeftBarButtonItem() {}
}
