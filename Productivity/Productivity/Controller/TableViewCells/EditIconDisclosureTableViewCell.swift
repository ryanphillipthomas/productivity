//
//  EditIconDisclosureTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class EditIconDisclosureTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconImageSingleLabelDisclosureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureText(text: String) {
        if let view = cellView as? IconImageSingleLabelDisclosureView {
            view.label.text = text
        }
    }
    
    func configureImage(image: UIImage?, workingObject: PRBaseWorkingObject) {
        if let view = cellView as? IconImageSingleLabelDisclosureView, let image = image {
            view.imageView.image = image
            if let colorValue = workingObject.colorValue {
                view.imageView.tintColor = UIColor(hexString: colorValue)
            }
        }
    }
}
