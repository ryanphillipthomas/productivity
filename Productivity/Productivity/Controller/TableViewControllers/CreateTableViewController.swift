//
//  CreateTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

//MARK: CreateOptions
public enum CreateOptions: CaseIterable {
    case RoutineOption
    case TaskOption
    
    func text() -> String {
        switch(self){
            case .RoutineOption: return "Regular Routine"
            case .TaskOption: return "One Time Task"
        }
    }
    
    func image() -> UIImage? {
        switch(self){
            case .RoutineOption: return UIImage(named: "calendar")
            case .TaskOption: return UIImage(named: "check-square")
        }
    }
}

//MARK: TemplateOptions

public enum TemplateOptions: CaseIterable {
    case MorningOption
    case GoodNightOption
    case GetStuffDoneOption
    case AfternoonStretchOption
    case SundayMorningOption
    case BathNightOption
    case MustHaveOption
    
    func text() -> String {
        switch(self){
            case .MorningOption: return "Kick Ass Morning Routine"
            case .GoodNightOption: return "A Good Nights Sleep"
            case .GetStuffDoneOption: return "Get Stuff Done"
            case .AfternoonStretchOption: return "An Afternoon Stretch"
            case .SundayMorningOption: return "Sunday Morning Routine"
            case .BathNightOption: return "Luxious Bath Night"
            case .MustHaveOption: return "Must Have Habits"
        }
    }
    
    func subText() -> String {
        switch(self){
            case .MorningOption: return "Start your day off right!"
            case .GoodNightOption: return "Put the day to rest"
            case .GetStuffDoneOption: return "Cross off that todo list"
            case .AfternoonStretchOption: return "Keep your body in shape"
            case .SundayMorningOption: return "Reset from the week"
            case .BathNightOption: return "Extra time for yourself"
            case .MustHaveOption: return "Small habits, big results"
        }
    }
    
    func image() -> UIImage? {
        switch(self){
            case .MorningOption: return UIImage(named: "avataaar1")
            case .GoodNightOption: return UIImage(named: "avataaar2")
            case .GetStuffDoneOption: return UIImage(named: "avataaar3")
            case .AfternoonStretchOption: return UIImage(named: "avataaar4")
            case .SundayMorningOption: return UIImage(named: "avataaar5")
            case .BathNightOption: return UIImage(named: "avataaar6")
            case .MustHaveOption: return UIImage(named: "avataaar7")
        }
    }
}

//MARK: CreateHeaderFooterOptions
public enum CreateHeaderFooterOptions: CaseIterable {
    case CreateOption
    case TemplateOption
    
    func text() -> String {
        switch(self){
            case .CreateOption: return "Create your own"
            case .TemplateOption: return "Or choose from these options"
        }
    }
}

//MARK: TableViewController
class CreateTableViewController: PRBaseTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        registerTableViewCells()
    }
    
    func registerTableViewCells () {
        tableView.register(CreateTableViewCell.self, forCellReuseIdentifier: String(describing: CreateTableViewCell.self))
        tableView.register(CreateTemplateTableViewCell.self, forCellReuseIdentifier: String(describing: CreateTemplateTableViewCell.self))
        tableView.register(HeaderFooterTableViewCell.self, forCellReuseIdentifier: String(describing: HeaderFooterTableViewCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
    }
    
    func setNavigationBar() {
        if let nav = self.navigationController as? PRBaseNavigationController {
            nav.wuDelegate = self
            nav.configureNavBar(title: "Create", leftImage: UIImage(systemName: "xmark"))
        }
    }
}

//MARK: Extension's
extension CreateTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: EditRoutineTableViewController.classForCoder()), let routineTableViewController =
            segue.destination as? EditRoutineTableViewController {
            
            if let nav = self.navigationController as? PRBaseNavigationController {
                routineTableViewController.managedObjectContext = nav.managedObjectContext
            }
            
            let groupId = NSNumber(value: Date().millisecondsSince1970 as Int64)
            routineTableViewController.workingObject.id = groupId.int64Value
            routineTableViewController.workingObject.name = ""
            routineTableViewController.workingObject.iconName = "flame.fill"
            routineTableViewController.workingObject.colorValue = "#FCB711"
            routineTableViewController.workingObject.frequency = "daily"
            routineTableViewController.workingObject.frequencyDays = []
            routineTableViewController.workingObject.frequencyEveryDay = true
            routineTableViewController.workingObject.timeOfDay = "At any time"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateTemplateTableViewCell.classForCoder()), for: indexPath) as! CreateTemplateTableViewCell
            let option = TemplateOptions.allCases[indexPath.row]
            cell.configureText(text: option.text(), subText: option.subText())
            cell.configureImage(image: option.image())
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateTableViewCell.classForCoder()), for: indexPath) as! CreateTableViewCell
        let option = CreateOptions.allCases[indexPath.row]
        cell.configureText(text: option.text())
        cell.configureImage(image: option.image(), colorValue: nil)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeaderFooterTableViewCell.classForCoder())) as! HeaderFooterTableViewCell
        let option = CreateHeaderFooterOptions.allCases[section]
        cell.configureText(text: option.text())
        return cell
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 7
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: String(describing: EditRoutineTableViewController.classForCoder()), sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 104
        }
        return 74
    }
}

extension CreateTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {}
    func didPressLeftBarButtonItem() {
        dismiss(animated: true, completion: nil)
    }
}
