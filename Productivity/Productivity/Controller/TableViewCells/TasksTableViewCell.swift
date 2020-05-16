//
//  TasksTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol TasksTableViewCellDelegate: NSObjectProtocol {
    func didSelectTask(task: Task)
}

class TasksTableViewCell: PRBaseTableViewCell<UIView> {
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext!
    weak var delegate: TasksTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = EditTasksView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func fetchAll(managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<NSFetchRequestResult>, sectionNameKeyPath: String?) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
    }
    
    func configureCell(managedObjectContext: NSManagedObjectContext, routineID: Int64) {
        self.fetchAll(managedObjectContext: managedObjectContext, fetchRequest: Task.sortedRoutineFetchRequest(routineID), sectionNameKeyPath: nil)
        if let view = cellView as? EditTasksView {
            tableView = view.tableView
            tableView.register(CreateTableViewCell.self, forCellReuseIdentifier: String(describing: CreateTableViewCell.self))
            tableView.delegate = self
            tableView.dataSource = self
        }
        self.managedObjectContext = managedObjectContext
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if let cell = cell as? CreateTableViewCell {
            let task = fetchedResultsController.object(at: indexPath) as! Task
            cell.configureText(text: task.name)
            cell.configureImage(image: UIImage(systemName: task.iconName),
                                colorValue: UIColor(hexString: task.colorValue))
            if let cellView = cell.cellView as? IconImageSingleLabelDisclosureView {
                cellView.disclourseImageView.isHidden = tableView.isEditing
            }
        }
    }
}

extension TasksTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = fetchedResultsController.object(at: indexPath) as! Task
        if let delegate = delegate {
            delegate.didSelectTask(task: task)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var objects = self.fetchedResultsController.fetchedObjects!

        let object = objects[sourceIndexPath.row]
        objects.remove(at: sourceIndexPath.row)
        objects.insert(object, at: destinationIndexPath.row)

        for (index, object) in objects.enumerated() {
            let task = object as! Task
            managedObjectContext.perform {
            task.order = Int64(index)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let task = fetchedResultsController.object(at: indexPath) as! Task
            managedObjectContext.perform {
                Task.delete(id: task.id, moc: self.managedObjectContext)
            }
        default: break
        }
    }
}

extension TasksTableViewCell: NSFetchedResultsControllerDelegate {
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
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, at: indexPath)
            }
            break;
        case .move:
            tableView.reloadData()
            break;
        default: break
        }
    }
}

extension TasksTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none : .delete
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        guard let sectionCount = fetchedResultsController.sections?.count else {
            return 0
        }
        return sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }
    
    //MARK: Override in subclasses
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateTableViewCell.classForCoder()), for: indexPath) as! CreateTableViewCell
        configureCell(cell, at: indexPath)
        return cell
    }
}
