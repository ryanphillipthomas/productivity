//
//  EditNameTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class EditNameTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = SingleTextFieldNameView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureName(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? SingleTextFieldNameView, let name = workingObject.name {
            view.textField.text = name
        }
    }
    
    func configurePlaceholder(text: String) {
        if let view = cellView as? SingleTextFieldNameView {
            view.textField.placeholder = text
        }
    }
    
    func configureTintColor(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? SingleTextFieldNameView, let colorValue = workingObject.colorValue {
            view.textField.tintColor = UIColor(hexString: colorValue)
        }
    }
    
    func setTextFieldFirstResponder() {
        if let view = cellView as? SingleTextFieldNameView {
            view.textField.becomeFirstResponder()
        }
    }
}
