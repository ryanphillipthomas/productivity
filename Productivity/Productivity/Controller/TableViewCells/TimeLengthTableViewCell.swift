//
//  Cell5.swift
//  TimeLengthTableViewCell
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class TimeLengthTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = TimeLengthView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureTimePicker(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? TimeLengthView {
            if let colorValue = workingObject.colorValue {
                view.timePicker.datePickerMode = .countDownTimer
                view.timePicker.backgroundColor = UIColor(hexString: colorValue)
                if let length = workingObject.length {
                    DispatchQueue.main.async(execute: {
                        view.timePicker.countDownDuration = TimeInterval(length)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        view.timePicker.countDownDuration = TimeInterval()
                    })
                }
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
