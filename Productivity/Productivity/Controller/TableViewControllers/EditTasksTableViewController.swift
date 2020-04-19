//
//  EditTasksTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/19/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class EditTasksTableViewController: PRBaseFetchedResultsTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAll(fetchRequest: Task.sortedFetchRequest, sectionNameKeyPath: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateTableViewCell.classForCoder()), for: indexPath) as! CreateTableViewCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    // MARK: - Table view data source
     override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateHeaderFooterHeaderFooterView.classForCoder())) as! CreateHeaderFooterHeaderFooterView
            configureHeaderFooterView(cell, at: section)
         return cell
     }
    
    override func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if let cell = cell as? CreateTableViewCell {
            let routine = fetchedResultsController.object(at: indexPath) as! Routine
            cell.configureText(text: routine.name)
            cell.configureImage(image: UIImage(systemName: routine.iconName),
                                colorValue: UIColor(hexString: routine.colorValue))
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let routine = fetchedResultsController.object(at: indexPath) as! Routine
            Routine.delete(id: routine.id, moc: managedObjectContext)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
}
