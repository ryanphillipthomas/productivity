//
//  AddRecordingTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 5/17/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class AddRecordingTableViewCell: PRBaseTableViewCell<UIView> {

    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = AddRecorderView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureButtonColor(workingObject: PRBaseWorkingObject, isSelected: Bool) {
        if let view = cellView as? AddRecorderView {
            if let colorValue = workingObject.colorValue {
                view.clear()
                for button in view.buttons {
                    button.tintColor = UIColor(hexString: colorValue)
                }
            }
        }
    }
}
