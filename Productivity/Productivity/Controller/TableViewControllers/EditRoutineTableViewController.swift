//
//  EditRoutineTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/22/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData

//MARK: EditOptions
public enum EditOptions: CaseIterable {
    case nameOfRoutine
    case frequency
    case refinedFrequency
    case timeOfDay
    case reminder
    case location
    case tasks
    case addTask

    func placeHolderText() -> String {
        switch(self){
        case .nameOfRoutine: return "Name of the routine"
        case .frequency: return ""
        case .refinedFrequency: return ""
        case .timeOfDay: return ""
        case .reminder: return "Add time"
        case .location: return "Add location"
        case .tasks: return ""
        case .addTask: return ""
        }
    }
    
    func image() -> UIImage? {
        switch(self){
            case .nameOfRoutine: return nil
            case .frequency: return nil
            case .refinedFrequency: return nil
            case .timeOfDay: return nil
            case .reminder: return UIImage(systemName: "clock.fill")
            case .location: return UIImage(systemName: "globe")
            case .tasks: return nil
            case .addTask: return nil
        }
    }
    
    func cellHeight(itemHeight:Int?) -> CGFloat {
        switch(self){
        case .nameOfRoutine: return 75
        case .frequency: return 75
        case .refinedFrequency: return 129
        case .timeOfDay: return 125
        case .reminder: return 75
        case .location: return 75
        case .tasks:
            let height = itemHeight ?? 0
            return CGFloat(height * 77)
        case .addTask: return 75
        }
    }
    
    func numberOfRows() -> Int {
        switch(self){
        case .nameOfRoutine: return 2
        case .frequency: return 1
        case .refinedFrequency: return 1
        case .timeOfDay: return 1
        case .reminder: return 1
        case .location: return 1
        case .tasks: return 1
        case .addTask: return 1
        }
    }
}


//MARK: EditHeaderFooterOptions
public enum EditHeaderFooterOptions: CaseIterable {
    case nameOfRoutine
    case frequency
    case refinedFrequency
    case timeOfDay
    case reminder
    case location
    case tasks
    case addTask

    func text() -> String {
        switch(self){
        case .nameOfRoutine: return ""
        case .frequency: return "I want to repeat this habit"
        case .refinedFrequency: return "on these days"
        case .timeOfDay: return "I will do it"
        case .reminder: return "Remind me at these times"
        case .location: return "Remind me at these locations"
        case .tasks: return "Manage tasks"
        case .addTask: return ""
        }
    }
    
    func headerHeight() -> CGFloat {
        switch(self){
        case .nameOfRoutine: return CGFloat.leastNonzeroMagnitude
        case .frequency: return 30
        case .refinedFrequency: return 30
        case .timeOfDay: return 30
        case .reminder: return 30
        case .location: return 30
        case .tasks: return 30
        case .addTask: return CGFloat.leastNonzeroMagnitude
        }
    }
}

//MARK: EditRoutineTableViewController
class EditRoutineTableViewController: PRBaseTableViewController {
    var routineID: Int64?
    var workingObject = PRBaseWorkingObject()
    var isEditingTasks = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWorkingObject()
        registerTableViewCells()
    }
    
    //MARK: RegisterTableViewCells
    func registerTableViewCells () {
        tableView.register(NameTableViewCell.self, forCellReuseIdentifier: String(describing: NameTableViewCell.self))
        tableView.register(IconColorTableViewCell.self, forCellReuseIdentifier: String(describing: IconColorTableViewCell.self))
        tableView.register(RepeatDailyTableViewCell.self, forCellReuseIdentifier: String(describing: RepeatDailyTableViewCell.self))
        tableView.register(RepeatFrequencyTableViewCell.self, forCellReuseIdentifier: String(describing: RepeatFrequencyTableViewCell.self))
        tableView.register(TimeOfDayTableViewCell.self, forCellReuseIdentifier: String(describing: TimeOfDayTableViewCell.self))
        tableView.register(DisclosureTableViewCell.self, forCellReuseIdentifier: String(describing: DisclosureTableViewCell.self))
        tableView.register(TasksTableViewCell.self, forCellReuseIdentifier: String(describing: TasksTableViewCell.self))
        tableView.register(AddTaskTableViewCell.self, forCellReuseIdentifier: String(describing: AddTaskTableViewCell.self))
        tableView.register(HeaderFooterTableViewCell.self, forCellReuseIdentifier: String(describing: HeaderFooterTableViewCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
    }
    
    func setupWorkingObject() {
        if let routineID = routineID {
            let routine = Routine.find(moc: managedObjectContext, id: routineID)
            workingObject.configureFrom(routine: routine)
        }
    }
    
    func setNavigationBar() {
        if let nav = self.navigationController as? PRBaseNavigationController {
            nav.wuDelegate = self
            if let colorValue = workingObject.colorValue {
                nav.configureNavBar(title: "Routine", rightButtonText: "Done", buttonColorOverride:UIColor(hexString: colorValue))
            } else {
                nav.configureNavBar(title: "New Routine", rightButtonText: "Done")
            }
        }
    }
    
    override func setTableView() {
        super.setTableView()
        tableView.allowsSelection = false
    }
    
    //MARK: Targets
    //NOTE: can probally move into the cell
    func setTarget(cell: AddTaskTableViewCell) {
        if let view = cell.cellView as? AddTaskView {
            view.addTaskButton.addTarget(self, action: #selector(self.didSelectAddTask(sender:)), for: .touchUpInside)
            view.editTaskButton.addTarget(self, action: #selector(self.didSelectEditTasks(sender:)), for: .touchUpInside)
        }
    }
    
    func setTarget(cell: IconColorTableViewCell) {
        if let view = cell.cellView as? IconColorButtonView {
            view.iconButton.addTarget(self, action: #selector(self.didSelectIconButton(sender:)), for: .touchUpInside)
            view.colorButton.addTarget(self, action: #selector(self.didSelectColorButton(sender:)), for: .touchUpInside)
        }
    }
    
    func setTarget(cell: NameTableViewCell) {
        if let view = cell.cellView as? SingleTextFieldNameView {
            view.textField.addTarget(self, action: #selector(self.didUpdateNameField(sender:)), for: .editingChanged)
        }
    }
    
    func setTarget(cell: RepeatFrequencyTableViewCell) {
        if let view = cell.cellView as? DailyWeeklyMonthlyView {
            for button in view.buttons {
                button.addTarget(self, action: #selector(self.didSelectFrequencyButton(sender:)), for: .touchUpInside)
            }
        }
    }
    
    func setTarget(cell: TimeOfDayTableViewCell) {
        if let view = cell.cellView as? TimeOfDayView {
            for button in view.buttons {
                button.addTarget(self, action: #selector(self.didSelectTimeOfDayButton(sender:)), for: .touchUpInside)
            }
        }
    }
    
    func setTarget(cell: RepeatDailyTableViewCell) {
        if let view = cell.cellView as? DailyView {
            for button in view.buttons {
                button.addTarget(self, action: #selector(self.didSelectDayButton(sender:)), for: .touchUpInside)
            }
        }
    }
    
    @objc func didSelectDayButton(sender: UIButton) {
        //Every Day Button
        if sender.tag == 7 {
            workingObject.frequencyEveryDay = true
            workingObject.frequencyDays?.removeAll()
        } else {
            workingObject.frequencyEveryDay = false
            if let frequencyDays = workingObject.frequencyDays, frequencyDays.contains(sender.tag) {
                for (index, day) in frequencyDays.enumerated() {
                    if day == sender.tag {
                        workingObject.frequencyDays?.remove(at: index)
                    }
                }
            } else {
                workingObject.frequencyDays?.append(sender.tag)
            }
        }
        
        tableView.reloadSections([2], with: .fade)
    }
    
    @objc func didSelectTimeOfDayButton(sender: UIButton) {
        workingObject.timeOfDay = sender.titleLabel?.text
        tableView.reloadSections([3], with: .fade)
    }
    
    @objc func didSelectFrequencyButton(sender: UIButton) {
        workingObject.frequency = sender.titleLabel?.text
        tableView.reloadSections([1], with: .fade)
    }
    
    @objc func didUpdateNameField(sender: UITextField) {
        workingObject.name = sender.text
    }
    
    @objc func didSelectIconButton(sender: UIButton) {
        performSegue(withIdentifier: String(describing: IconsCollectionViewController.classForCoder()), sender: nil)
    }
    
    @objc func didSelectColorButton(sender: UIButton) {
        performSegue(withIdentifier: String(describing: ColorsCollectionViewController.classForCoder()), sender: nil)
    }
    
    @objc func didSelectAddTask(sender: UIButton) {
        performSegue(withIdentifier: String(describing: EditTaskTableViewController.classForCoder()), sender: nil)
    }
    
    @objc func didSelectEditTasks(sender: UIButton) {
        isEditingTasks = !isEditingTasks
        tableView.reloadSections([6, 7], with: .none)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: IconsCollectionViewController.classForCoder()), let iconsCollectionViewController =
            segue.destination as? IconsCollectionViewController {
            iconsCollectionViewController.delegate = self
        } else if segue.identifier == String(describing: ColorsCollectionViewController.classForCoder()), let colorsCollectionViewController = segue.destination as? ColorsCollectionViewController {
            colorsCollectionViewController.delegate = self
        } else if segue.identifier == String(describing: EditTaskTableViewController.classForCoder()), let nav =
            segue.destination as? PRBaseNavigationController, let editTaskTableViewController = nav.viewControllers.first as? EditTaskTableViewController  {
            nav.managedObjectContext = managedObjectContext
            editTaskTableViewController.managedObjectContext = managedObjectContext
            
            if let senderID = sender as? Int64 {
                editTaskTableViewController.taskID = senderID
                editTaskTableViewController.workingObject.routineId = workingObject.id
            } else {
                let groupId = NSNumber(value: Date().millisecondsSince1970 as Int64)
                editTaskTableViewController.workingObject.id = groupId.int64Value
                editTaskTableViewController.workingObject.name = ""
                editTaskTableViewController.workingObject.iconName = "flame.fill"
                editTaskTableViewController.workingObject.colorValue = workingObject.colorValue
                editTaskTableViewController.workingObject.routineId = workingObject.id
                
                let routinesCount = Task.countInContextForRoutineID(routineID ?? 0, context: managedObjectContext)
                editTaskTableViewController.workingObject.order = Int64(routinesCount)
            }
        }
    }
}

//MARK: Extension's
extension EditRoutineTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell = cell as? EditNameTableViewCell {
            //Consider re-enabling this
            //linkely need to limit this...
//            delayWithSeconds(Constants.navigationTransitionTime) {
//                cell.setTextFieldFirstResponder()
//            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepeatFrequencyTableViewCell.classForCoder()), for: indexPath) as! RepeatFrequencyTableViewCell
            cell.configureButtonColor(workingObject: workingObject)
            setTarget(cell: cell)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepeatDailyTableViewCell.classForCoder()), for: indexPath) as! RepeatDailyTableViewCell
            cell.configureButtonColor(workingObject: workingObject)
            setTarget(cell: cell)
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TimeOfDayTableViewCell.classForCoder()), for: indexPath) as! TimeOfDayTableViewCell
            cell.configureButtonColor(workingObject: workingObject)
            setTarget(cell: cell)
            return cell
        } else if indexPath.section == 4 || indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DisclosureTableViewCell.classForCoder()), for: indexPath) as! DisclosureTableViewCell
            let option = EditOptions.allCases[indexPath.section]
            cell.configureText(text: option.placeHolderText())
            cell.configureImage(image: option.image(), workingObject: workingObject)
            return cell
        } else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TasksTableViewCell.classForCoder()), for: indexPath) as! TasksTableViewCell
            cell.configureCell(managedObjectContext: managedObjectContext, routineID: workingObject.id ?? 0)
            cell.tableView.isEditing = isEditingTasks
            cell.delegate = self
            return cell
        } else if indexPath.section == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddTaskTableViewCell.classForCoder()), for: indexPath) as! AddTaskTableViewCell
            cell.configureButtonColor(workingObject: workingObject, isSelected: isEditingTasks)
            setTarget(cell: cell)
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NameTableViewCell.classForCoder()), for: indexPath) as! NameTableViewCell
            setTarget(cell: cell)
            cell.configureName(workingObject: workingObject)
            cell.configureTintColor(workingObject: workingObject)
            let option = EditOptions.allCases[indexPath.section]
            cell.configurePlaceholder(text: option.placeHolderText())
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IconColorTableViewCell.classForCoder()), for: indexPath) as! IconColorTableViewCell
        setTarget(cell: cell)
        cell.configureIconButton(workingObject: workingObject)
        cell.configureColorButton(workingObject: workingObject)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeaderFooterTableViewCell.classForCoder())) as! HeaderFooterTableViewCell
        let option = EditHeaderFooterOptions.allCases[section]
        cell.configureText(text: option.text())
        
        if section == 0 || section == 7 {
            return UIView()
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return EditHeaderFooterOptions.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let option = EditOptions.allCases[section]
        return option.numberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let option = EditOptions.allCases[indexPath.section]
        let routinesCount = Task.countInContextForRoutineID(routineID ?? 0, context: managedObjectContext)
        return option.cellHeight(itemHeight: routinesCount)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let option = EditHeaderFooterOptions.allCases[section]
        return option.headerHeight()
    }
}

extension EditRoutineTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {
        managedObjectContext.performChanges {
            Routine.update(moc: self.managedObjectContext, workingObject: self.workingObject)
        }
        dismiss(animated: true, completion: nil)
    }
    func didPressLeftBarButtonItem() {}
}

extension EditRoutineTableViewController: IconsCollectionViewControllerDelegate {
    func didSelectIcon(iconName: String) {
        workingObject.iconName = iconName
        tableView.reloadSections([0], with: .fade)
    }
}

extension EditRoutineTableViewController: ColorsCollectionViewControllerDelegate {
    func didSelectColor(colorValue: String) {
        workingObject.colorValue = colorValue
        tableView.reloadSections([0], with: .fade)
    }
}

extension EditRoutineTableViewController: TasksTableViewCellDelegate {
    func didSelectTask(task: Task) {
        performSegue(withIdentifier: String(describing: EditTaskTableViewController.classForCoder()), sender: task.id)
    }
}
