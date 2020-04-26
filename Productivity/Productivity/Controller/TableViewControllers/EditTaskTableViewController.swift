//
//  EditTaskTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/24/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

//MARK: EditTaskOptions
public enum EditTaskOptions: CaseIterable {
    case nameOfTask
    case length

    func placeHolderText() -> String {
        switch(self){
        case .nameOfTask: return "Name of the task"
        case .length: return ""
        }
    }
    
    func image() -> UIImage? {
        switch(self){
            case .nameOfTask: return nil
            case .length: return nil
        }
    }
    
    func cellHeight() -> CGFloat {
        switch(self){
        case .nameOfTask: return 75
        case .length: return 120
        }
    }
    
    func numberOfRows() -> Int {
        switch(self){
        case .nameOfTask: return 2
        case .length: return 1
        }
    }
}


//MARK: EditTaskHeaderFooterOptions
public enum EditTaskHeaderFooterOptions: CaseIterable {
    case nameOfTask
    case length

    func text() -> String {
        switch(self){
        case .nameOfTask: return ""
        case .length: return ""
        }
    }
    
    func headerHeight() -> CGFloat {
        switch(self){
        case .nameOfTask: return CGFloat.leastNonzeroMagnitude
        case .length: return CGFloat.leastNonzeroMagnitude
        }
    }
}

class EditTaskTableViewController: PRBaseTableViewController {
    var taskID: Int64?
    var workingObject = PRBaseWorkingObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWorkingObject()
        registerTableViewCells()
    }
    
    func registerTableViewCells () {
        tableView.register(NameTableViewCell.self, forCellReuseIdentifier: String(describing: NameTableViewCell.self))
        tableView.register(IconColorTableViewCell.self, forCellReuseIdentifier: String(describing: IconColorTableViewCell.self))
        tableView.register(TimeLengthTableViewCell.self, forCellReuseIdentifier: String(describing: TimeLengthTableViewCell.self))
        tableView.register(HeaderFooterTableViewCell.self, forCellReuseIdentifier: String(describing: HeaderFooterTableViewCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
    }
    
    func setupWorkingObject() {
        if let taskID = taskID {
            let task = Task.find(moc: managedObjectContext, id: taskID)
            workingObject.configureFrom(task: task)
        }
    }
    
    func setNavigationBar() {
        if let nav = self.navigationController as? PRBaseNavigationController {
            nav.wuDelegate = self
            if let colorValue = workingObject.colorValue {
                nav.configureNavBar(title: "Task", rightButtonText: "Done", buttonColorOverride:UIColor(hexString: colorValue))
            } else {
                nav.configureNavBar(title: "New Task", rightButtonText: "Done")
            }
        }
    }
    
    @objc func didUpdateTime(sender: UIDatePicker) {
        workingObject.length = Int64(sender.countDownDuration)
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
    
    override func setTableView() {
        super.setTableView()
        tableView.allowsSelection = false
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
    
    func setTarget(cell: TimeLengthTableViewCell) {
        if let view = cell.cellView as? TimeLengthView {
            view.timePicker.addTarget(self, action: #selector(self.didUpdateTime(sender:)), for: .valueChanged)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return EditTaskHeaderFooterOptions.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let option = EditTaskOptions.allCases[section]
        return option.numberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let option = EditTaskOptions.allCases[indexPath.section]
        return option.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let option = EditTaskHeaderFooterOptions.allCases[section]
        return option.headerHeight()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IconColorTableViewCell.classForCoder()), for: indexPath) as! IconColorTableViewCell
            setTarget(cell: cell)
            cell.configureIconButton(workingObject: workingObject)
            cell.configureColorButton(workingObject: workingObject)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TimeLengthTableViewCell.classForCoder()), for: indexPath) as! TimeLengthTableViewCell
            cell.configureTimePicker(workingObject: workingObject)
            setTarget(cell: cell)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NameTableViewCell.classForCoder()), for: indexPath) as! NameTableViewCell
        setTarget(cell: cell)
        cell.configureName(workingObject: workingObject)
        cell.configureTintColor(workingObject: workingObject)
        let option = EditTaskOptions.allCases[indexPath.section]
        cell.configurePlaceholder(text: option.placeHolderText())
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeaderFooterTableViewCell.classForCoder())) as! HeaderFooterTableViewCell
        let option = EditTaskHeaderFooterOptions.allCases[section]
        cell.configureText(text: option.text())
        
        if section == 0 || section == 1 {
            return UIView()
        }
        
        return cell
    }
}

extension EditTaskTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {
        managedObjectContext.performChanges {
            Task.update(moc: self.managedObjectContext, workingObject: self.workingObject)
        }
        dismiss(animated: true, completion: nil)
    }
    func didPressLeftBarButtonItem() {}
}

extension EditTaskTableViewController: IconsCollectionViewControllerDelegate {
    func didSelectIcon(iconName: String) {
        workingObject.iconName = iconName
        tableView.reloadData()
    }
}

extension EditTaskTableViewController: ColorsCollectionViewControllerDelegate {
    func didSelectColor(colorValue: String) {
        workingObject.colorValue = colorValue
        tableView.reloadData()
    }
}

