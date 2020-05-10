//
//  OptionSelectionTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 5/10/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

//MARK: OptionSelectionTableViewCellDelegate
protocol OptionSelectionTableViewCellDelegate: NSObjectProtocol {
    func didSelect(data: String)
}

class OptionSelectionTableViewCell: PRBaseTableViewCell<UIView> {
    weak var delegate: OptionSelectionViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = OptionSelectionView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configurePicker(workingObject: PRBaseWorkingObject, pickerSelection: OptionSelection) {
        if let view = cellView as? OptionSelectionView {
            if let colorValue = workingObject.colorValue {
                view.picker.backgroundColor = UIColor(hexString: colorValue)
            }
            view.setupData(workingObject: workingObject, pickerSelection: pickerSelection)
            view.delegate = self
        }
    }
}

extension OptionSelectionTableViewCell: OptionSelectionViewDelegate {
    func didSelect(data: String) {
        if let delegate = delegate {
            delegate.didSelect(data: data)
        }
    }
}
