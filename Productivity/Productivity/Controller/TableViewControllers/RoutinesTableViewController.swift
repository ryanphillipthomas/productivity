//
//  RoutinesTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/11/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class RoutinesTableViewController: PRBaseFetchedResultsTableViewController {
    
    public enum TimeOfDayOptions: CaseIterable {
        case morning
        case afternoon
        case evening
        case allDay

        func text() -> String {
            switch(self){
                case .morning: return "Morning"
                case .afternoon: return "Afternoon"
                case .evening: return "Evening"
                case .allDay: return "Anytime"
            }
        }
    }
    
    //MARK: RoutinesHeaderFooterHeaderFooterView
    class RoutinesHeaderFooterHeaderFooterView: PRTableViewHeaderFooterView<UIView> {
        override func awakeFromNib() {
            super.awakeFromNib()
            cellView = LineSingleLabelHeaderFooterView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        func configureText(text: String) {
            if let view = cellView as? LineSingleLabelHeaderFooterView {
                view.label.text = text
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        fetchAll(fetchRequest: Routine.sortedFetchRequest, sectionNameKeyPath: "timeOfDay")
        NotificationCenter.default.addObserver(self, selector: #selector(displayNotifications(notification:)), name: NSNotification.Name.init(rawValue: "runRoutine"), object: nil)
    }
    
    @objc func displayNotifications(notification: NSNotification) {
        
        
        let button = UIButton()
        
        if let userInfo = notification.userInfo {
            button.tag = userInfo["id"] as! Int
        }
        
        didSelectRunRoutine(sender: button)
    }
    
    func registerTableViewCells() {
        tableView.register(CreateTableViewCell.self, forCellReuseIdentifier: String(describing: CreateTableViewCell.self))
        tableView.register(HeaderFooterTableViewCell.self, forCellReuseIdentifier: String(describing: HeaderFooterTableViewCell.self))
        tableView.register(RoutineTableViewCell.self, forCellReuseIdentifier: String(describing: RoutineTableViewCell.self))
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
    
    func setTarget(cell: RoutineTableViewCell) {
        if let view = cell.cellView as? IconImageSingleLabelButtonView {
            view.button.addTarget(self, action: #selector(self.didSelectRunRoutine(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func didSelectRunRoutine(sender: UIButton) {
        performSegue(withIdentifier: String(describing: RoutineViewController.self), sender: sender.tag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: CreateTableViewController.classForCoder()), let nav =
            segue.destination as? PRBaseNavigationController, let createTableViewController = nav.viewControllers.first as? CreateTableViewController  {
            nav.managedObjectContext = managedObjectContext
            createTableViewController.managedObjectContext = managedObjectContext
        } else if segue.identifier == String(describing: EditRoutineTableViewController.classForCoder()), let nav =
        segue.destination as? PRBaseNavigationController, let editRoutineTableViewController = nav.viewControllers.first as? EditRoutineTableViewController {
            editRoutineTableViewController.managedObjectContext = managedObjectContext
            editRoutineTableViewController.routineID = sender as? Int64
        } else if segue.identifier == String(describing: RoutineViewController.classForCoder()), let nav =
        segue.destination as? PRBaseNavigationController, let routineViewController = nav.viewControllers.first as? RoutineViewController {
            routineViewController.managedObjectContext = managedObjectContext
            routineViewController.routineID = sender as? Int64
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    //MARK: PRFetchedResultController Overrides
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let routine = fetchedResultsController.object(at: indexPath) as! Routine
        performSegue(withIdentifier: String(describing: EditRoutineTableViewController.classForCoder()), sender: routine.id)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RoutineTableViewCell.classForCoder()), for: indexPath) as! RoutineTableViewCell
        configureCell(cell, at: indexPath)
        setTarget(cell: cell)
        return cell
    }
    
    // MARK: - Table view data source
     override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeaderFooterTableViewCell.classForCoder())) as! HeaderFooterTableViewCell
            configureHeaderFooterView(cell, at: section)
        return cell
     }
    
    override func configureHeaderFooterView(_ view: UIView, at section: Int) {
        if let cell = view as? HeaderFooterTableViewCell {
            let option = tableView(tableView: tableView, titleForHeaderInSection: section)
            cell.configureText(text: option ?? "")
        }
    }
    
   override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         if let sections = fetchedResultsController.sections {
             let currentSection = sections[section]
             return currentSection.name
         }
         
         return nil
     }
    
    override func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if let cell = cell as? RoutineTableViewCell {
            let routine = fetchedResultsController.object(at: indexPath) as! Routine
            cell.configureText(text: routine.name)
            cell.configureImage(image: UIImage(systemName: routine.iconName),
                                colorValue: UIColor(hexString: routine.colorValue))
            cell.configureRoutineID(routineID: routine.id)
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

extension RoutinesTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {
        performSegue(withIdentifier: String(describing: CreateTableViewController.self), sender: nil)
    }
    func didPressLeftBarButtonItem() {}
}
