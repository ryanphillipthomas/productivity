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
    
    func cellHeight(cellItemCount: Int?) -> CGFloat {
        switch(self){
        case .nameOfRoutine: return 75
        case .frequency: return 75
        case .refinedFrequency: return 129
        case .timeOfDay: return 125
        case .reminder: return 75
        case .location: return 75
        case .tasks: return CGFloat(cellItemCount ?? 0 * 20)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWorkingObject()
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
    
    //NOTE: can probally move into the cell
    func setTarget(cell: EditIconColorTableViewCell) {
        if let view = cell.cellView as? IconColorButtonView {
            view.iconButton.addTarget(self, action: #selector(self.didSelectIconButton(sender:)), for: .touchUpInside)
            view.colorButton.addTarget(self, action: #selector(self.didSelectColorButton(sender:)), for: .touchUpInside)
        }
    }
    
    func setTarget(cell: EditNameTableViewCell) {
        if let view = cell.cellView as? SingleTextFieldNameView {
            view.textField.addTarget(self, action: #selector(self.didUpdateNameField(sender:)), for: .editingChanged)
        }
    }
    
    func setTarget(cell: EditIconRepeatFrequencyTableViewCell) {
        if let view = cell.cellView as? DailyWeeklyMonthlyView {
            for button in view.buttons {
                button.addTarget(self, action: #selector(self.didSelectFrequencyButton(sender:)), for: .touchUpInside)
            }
        }
    }
    
    func setTarget(cell: EditIconTimeOfDayTableViewCell) {
        if let view = cell.cellView as? TimeOfDayView {
            for button in view.buttons {
                button.addTarget(self, action: #selector(self.didSelectTimeOfDayButton(sender:)), for: .touchUpInside)
            }
        }
    }
    
    func setTarget(cell: EditIconRepeatDailyTableViewCell) {
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
        
        tableView.reloadData()
    }
    
    @objc func didSelectTimeOfDayButton(sender: UIButton) {
        workingObject.timeOfDay = sender.titleLabel?.text
        tableView.reloadData()
    }
    
    @objc func didSelectFrequencyButton(sender: UIButton) {
        workingObject.frequency = sender.titleLabel?.text
        tableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: IconsCollectionViewController.classForCoder()), let iconsCollectionViewController =
            segue.destination as? IconsCollectionViewController {
            iconsCollectionViewController.delegate = self
        } else if segue.identifier == String(describing: ColorsCollectionViewController.classForCoder()), let colorsCollectionViewController = segue.destination as? ColorsCollectionViewController {
            colorsCollectionViewController.delegate = self
        }
    }
}


//MARK: EditNameTableViewCell
class EditNameTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = SingleTextFieldNameView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureName(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? SingleTextFieldNameView, let name = workingObject.name {
            view.textField.text = name
        }
    }
    
    func configurePlaceholder(text: String) {
        if let view = cellView as? SingleTextFieldNameView {
            view.textField.placeholder = text
        }
    }
    
    func configureTintColor(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? SingleTextFieldNameView, let colorValue = workingObject.colorValue {
            view.textField.tintColor = UIColor(hexString: colorValue)
        }
    }
    
    func setTextFieldFirstResponder() {
        if let view = cellView as? SingleTextFieldNameView {
            view.textField.becomeFirstResponder()
        }
    }
}

//MARK: EditIconColorTableViewCell
class EditIconColorTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconColorButtonView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureIconButton(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? IconColorButtonView, let iconName = workingObject.iconName {
            view.iconButton.setImage(UIImage(systemName: iconName), for: .normal)
            if let colorValue = workingObject.colorValue {
                view.iconButton.tintColor = UIColor(hexString: colorValue)
            }
        }
    }
    
    func configureColorButton(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? IconColorButtonView {
            view.colorButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            if let colorValue = workingObject.colorValue {
                view.colorButton.tintColor = UIColor(hexString: colorValue)
            }
        }
    }
}

//MARK: EditIconColorTableViewCell
class EditIconRepeatFrequencyTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = DailyWeeklyMonthlyView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureButtonColor(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? DailyWeeklyMonthlyView {
            if let colorValue = workingObject.colorValue {
                view.clear()
                for button in view.buttons {
                    if (button.titleLabel?.text == workingObject.frequency) {
                        button.backgroundColor = UIColor(hexString: colorValue)
                    }
                }
            }
        }
    }
}

//MARK: EditIconRepeatDailyTableViewCell
class EditIconRepeatDailyTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = DailyView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureButtonColor(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? DailyView {
            if let colorValue = workingObject.colorValue {
                view.clear()
                for button in view.buttons {
                    if let frequencyDays = workingObject.frequencyDays {
                        for day in frequencyDays {
                            if day == button.tag {
                                button.backgroundColor = UIColor(hexString: colorValue)
                                
                                let allDayButton = view.buttons[7]
                                allDayButton.backgroundColor = UIColor(hexString: "1F2123")
                                break
                            }
                        }
                        
                        //Check for All Day Button
                        if button.tag == 7 {
                            if let frequencyEveryDay = workingObject.frequencyEveryDay, frequencyEveryDay == true {
                                button.backgroundColor = UIColor(hexString: colorValue)
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK: EditIconRepeatDailyTableViewCell
class EditIconTimeOfDayTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = TimeOfDayView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureButtonColor(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? TimeOfDayView {
            if let colorValue = workingObject.colorValue {
                view.clear()
                for button in view.buttons {
                    if (button.titleLabel?.text == workingObject.timeOfDay) {
                        button.backgroundColor = UIColor(hexString: colorValue)
                    }
                }
            }
        }
    }
}

//MARK: EditIconDisclosureTableViewCell
class EditIconDisclosureTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconImageSingleLabelDisclosureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureText(text: String) {
        if let view = cellView as? IconImageSingleLabelDisclosureView {
            view.label.text = text
        }
    }
    
    func configureImage(image: UIImage?, workingObject: PRBaseWorkingObject) {
        if let view = cellView as? IconImageSingleLabelDisclosureView, let image = image {
            view.imageView.image = image
            if let colorValue = workingObject.colorValue {
                view.imageView.tintColor = UIColor(hexString: colorValue)
            }
        }
    }
}

//MARK: EditAddTaskTableViewCell
class EditAddTaskTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = AddTaskView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureButtonColor(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? AddTaskView {
            if let colorValue = workingObject.colorValue {
                view.clear()
                for button in view.buttons {
                    button.backgroundColor = UIColor(hexString: colorValue)
                }
            }
        }
    }
}

//MARK: EditTasksTableViewCell
class EditTasksTableViewCell: PRBaseTableViewCell<UIView> {
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = EditTasksView()
    }
    
    func configureCell(managedObjectContext: NSManagedObjectContext, workingObject: PRBaseWorkingObject) {
        self.fetchAll(managedObjectContext: managedObjectContext, fetchRequest: Routine.sortedFetchRequest, sectionNameKeyPath: nil)
        if let view = cellView as? EditTasksView {
            tableView = view.tableView
            tableView.register(CreateTableViewCell.self, forCellReuseIdentifier: "CreateTableViewCell")
            tableView.delegate = self
            tableView.dataSource = self
        }
        self.managedObjectContext = managedObjectContext
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
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if let cell = cell as? CreateTableViewCell {
            let routine = fetchedResultsController.object(at: indexPath) as! Routine
            cell.configureText(text: routine.name)
            cell.configureImage(image: UIImage(systemName: routine.iconName),
                                colorValue: UIColor(hexString: routine.colorValue))
        }
    }
}

extension EditTasksTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let routine = fetchedResultsController.object(at: indexPath) as! Routine
            Routine.delete(id: routine.id, moc: managedObjectContext)
        default: break
        }
    }
}

extension EditTasksTableViewCell: NSFetchedResultsControllerDelegate {
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
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        default: break
        }
    }
}

extension EditTasksTableViewCell: UITableViewDataSource {
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

//MARK: EditHeaderFooterHeaderFooterView
class EditHeaderFooterHeaderFooterView: PRBaseTableViewCell<UIView> {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconRepeatFrequencyTableViewCell.classForCoder()), for: indexPath) as! EditIconRepeatFrequencyTableViewCell
            cell.configureButtonColor(workingObject: workingObject)
            setTarget(cell: cell)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconRepeatDailyTableViewCell.classForCoder()), for: indexPath) as! EditIconRepeatDailyTableViewCell
            cell.configureButtonColor(workingObject: workingObject)
            setTarget(cell: cell)
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconTimeOfDayTableViewCell.classForCoder()), for: indexPath) as! EditIconTimeOfDayTableViewCell
            cell.configureButtonColor(workingObject: workingObject)
            setTarget(cell: cell)
            return cell
        } else if indexPath.section == 4 || indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconDisclosureTableViewCell.classForCoder()), for: indexPath) as! EditIconDisclosureTableViewCell
            let option = EditOptions.allCases[indexPath.section]
            cell.configureText(text: option.placeHolderText())
            cell.configureImage(image: option.image(), workingObject: workingObject)
            return cell
        } else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditTasksTableViewCell.classForCoder()), for: indexPath) as! EditTasksTableViewCell
            cell.configureCell(managedObjectContext: managedObjectContext, workingObject: workingObject)
            return cell
        } else if indexPath.section == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditAddTaskTableViewCell.classForCoder()), for: indexPath) as! EditAddTaskTableViewCell
            cell.configureButtonColor(workingObject: workingObject)
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditNameTableViewCell.classForCoder()), for: indexPath) as! EditNameTableViewCell
            setTarget(cell: cell)
            cell.configureName(workingObject: workingObject)
            cell.configureTintColor(workingObject: workingObject)
            let option = EditOptions.allCases[indexPath.section]
            cell.configurePlaceholder(text: option.placeHolderText())
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconColorTableViewCell.classForCoder()), for: indexPath) as! EditIconColorTableViewCell
        setTarget(cell: cell)
        cell.configureIconButton(workingObject: workingObject)
        cell.configureColorButton(workingObject: workingObject)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditHeaderFooterHeaderFooterView.classForCoder())) as! EditHeaderFooterHeaderFooterView
        let option = EditHeaderFooterOptions.allCases[section]
        cell.configureText(text: option.text())
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
        return option.cellHeight(cellItemCount: 0)
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
        tableView.reloadData()
    }
}

extension EditRoutineTableViewController: ColorsCollectionViewControllerDelegate {
    func didSelectColor(colorValue: String) {
        workingObject.colorValue = colorValue
        tableView.reloadData()
    }
}
