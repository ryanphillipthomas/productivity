//
//  ToggleTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class ToggleTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconImageSingleLabelToggleView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureText(text: String) {
        if let view = cellView as? IconImageSingleLabelToggleView {
            view.label.text = text
        }
    }
    
    func configureImage(image: UIImage?, colorValue: UIColor?) {
        if let view = cellView as? IconImageSingleLabelToggleView, let image = image {
            view.imageView.image = image
            if let colorValue = colorValue {
                view.imageView.tintColor = colorValue
            }
        }
    }
    
    func configureToggle(colorValue: UIColor?) {
        if let view = cellView as? IconImageSingleLabelToggleView {
            if let colorValue = colorValue {
                view.toggle.onTintColor = colorValue
            }
        }
    }
}
