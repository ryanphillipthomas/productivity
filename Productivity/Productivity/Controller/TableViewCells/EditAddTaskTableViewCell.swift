//
//  EditAddTaskTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

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
