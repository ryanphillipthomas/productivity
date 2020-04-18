//
//  SettingsTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/11/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

//MARK: CreateOptions
public enum SettingsOptions: CaseIterable {
    case TryForFreeOption
    case NotificationsOption
    case GeneralOption
    case iCloudSyncOption
    case ManageiCloudOption
    case SiriShortcutsOption
    case HelpOption
    case SendFeedbackOption
    case RateOption
    
    func text() -> String {
        switch(self){
        case .TryForFreeOption: return "Try For Free"
        case .NotificationsOption: return "Notifications"
        case .GeneralOption: return "General"
        case .iCloudSyncOption: return "iCloud Sync"
        case .ManageiCloudOption: return "Manage iCloud"
        case .SiriShortcutsOption: return "Siri Shortcuts"
        case .HelpOption: return "Help"
        case .SendFeedbackOption: return "Send Feedback"
        case .RateOption: return "Rate on the App Store"
        }
    }
    
    func image() -> UIImage? {
        switch(self){
        case .TryForFreeOption: return UIImage(systemName: "lock.open.fill")
        case .NotificationsOption: return UIImage(systemName: "clock.fill")
        case .GeneralOption: return UIImage(systemName: "gear")
        case .iCloudSyncOption: return UIImage(systemName: "cloud.fill")
        case .ManageiCloudOption: return UIImage(systemName: "icloud.and.arrow.down.fill")
        case .SiriShortcutsOption: return UIImage(systemName: "square.stack.3d.up.fill")
        case .HelpOption: return UIImage(systemName: "questionmark.circle.fill")
        case .SendFeedbackOption: return UIImage(systemName: "bubble.right.fill")
        case .RateOption: return UIImage(systemName: "star.fill")
        }
    }
    
    func color() -> UIColor? {
        let yellow = UIColor(hexString: "#FCB711")
        let orange = UIColor(hexString: "#F37021")
        let red = UIColor(hexString: "#CC004C")
        let purple = UIColor(hexString: "#6460AA")
        let blue = UIColor(hexString: "#0089D0")
        let green = UIColor(hexString: "#0DB14B")
        
        switch(self){
        case .TryForFreeOption: return yellow
        case .NotificationsOption: return orange
        case .GeneralOption: return purple
        case .iCloudSyncOption: return red
        case .ManageiCloudOption: return blue
        case .SiriShortcutsOption: return green
        case .HelpOption: return orange
        case .SendFeedbackOption: return blue
        case .RateOption: return yellow
        }
    }
}

//MARK: SettingsDisclosureTableViewCell
class SettingsDisclosureTableViewCell: PRBaseTableViewCell<UIView> {
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
    
    func configureImage(image: UIImage?, colorValue: UIColor?) {
        if let view = cellView as? IconImageSingleLabelDisclosureView, let image = image {
            view.imageView.image = image
            if let colorValue = colorValue {
                view.imageView.tintColor = colorValue
            }
        }
    }
}

//MARK: SettingsTableViewCell
class SettingsToggleTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconImageSingleLabelToggleView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureText(text: String) {
        if let view = cellView as? IconImageSingleLabelToggleView {
            view.label.text = text
        }
    }
    
    func configureImage(image: UIImage?, colorValue: UIColor?) {
        if let view = cellView as? IconImageSingleLabelToggleView, let image = image {
            view.imageView.image = image
            if let colorValue = colorValue {
                view.imageView.tintColor = colorValue
            }
        }
    }
    
    func configureToggle(colorValue: UIColor?) {
        if let view = cellView as? IconImageSingleLabelToggleView {
            if let colorValue = colorValue {
                view.toggle.onTintColor = colorValue
            }
        }
    }
}

class SettingsTableViewController: PRBaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
    }
    
    func setNavigationBar() {
        if let nav = self.navigationController as? PRBaseNavigationController {
            nav.wuDelegate = self
            nav.configureNavBar(title: "Settings")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SettingsOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsToggleTableViewCell.classForCoder()), for: indexPath) as! SettingsToggleTableViewCell
            let option = SettingsOptions.allCases[indexPath.row]
            cell.configureText(text: option.text())
            cell.configureImage(image: option.image(), colorValue: option.color())
            cell.configureToggle(colorValue: option.color())
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsDisclosureTableViewCell.classForCoder()), for: indexPath) as! SettingsDisclosureTableViewCell
        let option = SettingsOptions.allCases[indexPath.row]
        cell.configureText(text: option.text())
        cell.configureImage(image: option.image(), colorValue: option.color())
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            performSegue(withIdentifier: String(describing: PRSubscriptionViewController.classForCoder()), sender: nil)
        }
    }
}

extension SettingsTableViewController: PRBaseNavigationControllerDelegate {
    func didPressRightBarButtonItem() {}
    func didPressLeftBarButtonItem() {}
}
