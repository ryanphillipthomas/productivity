//
//  AddTaskTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class AddTaskTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = AddTaskView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureButtonColor(workingObject: PRBaseWorkingObject, isSelected: Bool) {
        if let view = cellView as? AddTaskView {
            if let colorValue = workingObject.colorValue {
                view.clear()
                for button in view.buttons {
                    if button == view.editTaskButton {
                        if isSelected {
                            button.backgroundColor = UIColor(hexString: colorValue)
                        }
                    } else {
                        button.backgroundColor = UIColor(hexString: colorValue)
                    }
                }
            }
        }
    }
}
