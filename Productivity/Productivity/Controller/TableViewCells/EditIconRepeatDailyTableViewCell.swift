//
//  EditIconRepeatDailyTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class EditIconRepeatDailyTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = DailyView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureButtonColor(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? DailyView {
            if let colorValue = workingObject.colorValue {
                view.clear()
                for button in view.buttons {
                    if let frequencyDays = workingObject.frequencyDays {
                        for day in frequencyDays {
                            if day == button.tag {
                                button.backgroundColor = UIColor(hexString: colorValue)
                                
                                let allDayButton = view.buttons[7]
                                allDayButton.backgroundColor = UIColor(hexString: "1F2123")
                                break
                            }
                        }
                        
                        //Check for All Day Button
                        if button.tag == 7 {
                            if let frequencyEveryDay = workingObject.frequencyEveryDay, frequencyEveryDay == true {
                                button.backgroundColor = UIColor(hexString: colorValue)
                            }
                        }
                    }
                }
            }
        }
    }
}
