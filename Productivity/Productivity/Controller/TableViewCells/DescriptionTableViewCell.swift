//
//  DescriptionTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 5/10/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class DescriptionTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = TextView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureDescription(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? TextView, let description = workingObject.itemDescription {
            view.textView.text = description
        }
    }
    
    func configureTintColor(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? TextView, let colorValue = workingObject.colorValue {
            view.textView.tintColor = UIColor(hexString: colorValue)
        }
    }
    
    func setTextViewFirstResponder() {
        if let view = cellView as? TextView {
            view.textView.becomeFirstResponder()
        }
    }
}
