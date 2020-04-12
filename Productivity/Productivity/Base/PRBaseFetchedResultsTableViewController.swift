//
//  PRBaseFetchedResultsTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/12/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData

class PRBaseFetchedResultsTableViewController: PRBaseTableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var modelObject: PRManagedObject!
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAll()
    }
    
    func fetchAll() {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        guard let sectionCount = fetchedResultsController.sections?.count else {
            return 0
        }
        return sectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }
    
    //these should be overridedn in implementation...
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateTableViewCell.classForCoder()), for: indexPath) as! CreateTableViewCell
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        let routine = fetchedResultsController.object(at: indexPath) as! Routine
        cell.textLabel?.text = routine.name
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let routine = fetchedResultsController.object(at: indexPath) as! Routine
            Routine.delete(id: routine.id, moc: managedObjectContext)
        default: break
        }
    }
    
    // MARK: -  FetchedResultsController Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [newIndexPath!], with: .automatic)
        default: break
        }
    }

}
