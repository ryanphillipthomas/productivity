//
//  EditIconRepeatFrequencyTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

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
