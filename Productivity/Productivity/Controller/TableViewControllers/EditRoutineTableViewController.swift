//
//  EditRoutineTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/22/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit


//MARK: EditOptions
public enum EditOptions: CaseIterable {
    case nameOfRoutine
    case frequency
    case refinedFrequency
    case timeOfDay
    case reminder
    case location

    func placeHolderText() -> String {
        switch(self){
        case .nameOfRoutine: return "Name of the routine"
        case .frequency: return ""
        case .refinedFrequency: return ""
        case .timeOfDay: return ""
        case .reminder: return "Add time"
        case .location: return "Add location"
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
        }
    }
    
    func cellHeight() -> CGFloat {
        switch(self){
        case .nameOfRoutine: return 75
        case .frequency: return 75
        case .refinedFrequency: return 120
        case .timeOfDay: return 120
        case .reminder: return 75
        case .location: return 75
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

    func text() -> String {
        switch(self){
        case .nameOfRoutine: return ""
        case .frequency: return "I want to repeat this habit"
        case .refinedFrequency: return "on these days"
        case .timeOfDay: return "I will do it"
        case .reminder: return "Remind me at these times"
        case .location: return "Remind me at these locations"
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


//MARK: TableViewCells

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
//            view.textField.becomeFirstResponder()
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
        if let cell = cell as? EditNameTableViewCell {
            //linkely need to limit this...
            delayWithSeconds(Constants.navigationTransitionTime) {
                cell.setTextFieldFirstResponder()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconRepeatFrequencyTableViewCell.classForCoder()), for: indexPath) as! EditIconRepeatFrequencyTableViewCell
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconRepeatDailyTableViewCell.classForCoder()), for: indexPath) as! EditIconRepeatDailyTableViewCell
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconTimeOfDayTableViewCell.classForCoder()), for: indexPath) as! EditIconTimeOfDayTableViewCell
            return cell
        } else if indexPath.section == 4 || indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconDisclosureTableViewCell.classForCoder()), for: indexPath) as! EditIconDisclosureTableViewCell
            let option = EditOptions.allCases[indexPath.section]
            cell.configureText(text: option.placeHolderText())
            cell.configureImage(image: option.image(), workingObject: workingObject)
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
        return option.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let option = EditHeaderFooterOptions.allCases[section]
        return option.headerHeight()
    }
}

extension EditRoutineTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {
        Routine.update(moc: managedObjectContext, workingObject: workingObject)
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
