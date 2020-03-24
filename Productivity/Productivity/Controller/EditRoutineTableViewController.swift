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
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setNavigationBar()
    }
    
    func setNavigationBar() {
        if let nav = self.navigationController as? PRBaseNavigationController {
            nav.wuDelegate = self
            nav.configureNavBar(title: "New Routine", rightButtonText: "Done")
        }
    }
    
    func setTableView() {
        tableView.allowsSelection = false
        tableView.contentInset.top = 20
        tableView.backgroundColor = UIColor(red: 0.157, green: 0.161, blue: 0.165, alpha: 1.00)
        tableView.separatorColor = .clear
    }
    
    func setTarget(cell: EditIconColorTableViewCell) {
        if let view = cell.cellView as? IconColorButtonView {
            view.iconButton.addTarget(self, action: #selector(self.didSelectIconButton), for: .touchUpInside)
        }
    }
    
    @objc func didSelectIconButton(sender:UIButton) {
        performSegue(withIdentifier: String(describing: IconsCollectionViewController.classForCoder()), sender: nil)
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
        dismiss(animated: true, completion: nil)
    }
    func didPressLeftBarButtonItem() {}
}
