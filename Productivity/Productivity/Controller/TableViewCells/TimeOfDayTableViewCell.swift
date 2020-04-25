//
//  TimeOfDayTableViewCell.swift
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class TimeOfDayTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = TimeOfDayView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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
