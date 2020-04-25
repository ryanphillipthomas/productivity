//
//  EditIconColorTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class EditIconColorTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconColorButtonView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureIconButton(workingObject: PRBaseWorkingObject) {
        if let view = cellView as? IconColorButtonView, let iconName = workingObject.iconName {
            view.iconButton.setImage(UIImage(systemName: iconName), for: .normal)
            if let colorValue = workingObject.colorValue {
                view.iconButton.tintColor = UIColor(hexString: colorValue)
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
