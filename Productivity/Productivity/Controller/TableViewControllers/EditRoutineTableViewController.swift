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
    
    func text() -> String {
        switch(self){
            case .nameOfRoutine: return "Name of the routine"
        }
    }
}

//MARK: EditHeaderFooterOptions
public enum EditHeaderFooterOptions: CaseIterable {
    case nameOfRoutine
    
    func text() -> String {
        switch(self){
            case .nameOfRoutine: return ""
        }
    }
}

//MARK: EditRoutineTableViewController
class EditRoutineTableViewController: PRBaseTableViewController {
    var routineID: Int64?
    var workingObject = PRBaseWorkingObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setupWorkingObject()
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
            nav.configureNavBar(title: "New Routine", rightButtonText: "Done")
        }
    }
    
    override func setTableView() {
        super.setTableView()
        tableView.allowsSelection = false
    }
    
    func setTarget(cell: EditIconColorTableViewCell) {
        if let view = cell.cellView as? IconColorButtonView {
            view.iconButton.addTarget(self, action: #selector(self.didSelectIconButton), for: .touchUpInside)
        }
    }
    
    @objc func didSelectIconButton(sender:UIButton) {
        performSegue(withIdentifier: String(describing: IconsCollectionViewController.classForCoder()), sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: IconsCollectionViewController.classForCoder()), let iconsCollectionViewController =
            segue.destination as? IconsCollectionViewController {
            iconsCollectionViewController.delegate = self
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
    
    func configureText(text: String) {
        if let view = cellView as? SingleTextFieldNameView {
            view.textField.placeholder = text
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
        }
    }
    
    func configureColorButton(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? IconColorButtonView, let iconName = workingObject.iconName {
            view.colorButton.setImage(UIImage(systemName: iconName), for: .normal)
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
            delayWithSeconds(Constants.navigationTransitionTime) {
                cell.setTextFieldFirstResponder()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditIconColorTableViewCell.classForCoder()), for: indexPath) as! EditIconColorTableViewCell
            setTarget(cell: cell)
            cell.configureIconButton(workingObject: workingObject)
            cell.configureColorButton(workingObject: workingObject)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditNameTableViewCell.classForCoder()), for: indexPath) as! EditNameTableViewCell
        let option = EditOptions.allCases[indexPath.row]
        cell.configureText(text: option.text())
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
