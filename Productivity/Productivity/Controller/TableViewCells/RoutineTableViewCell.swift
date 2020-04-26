//
//  RoutineTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class RoutineTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconImageSingleLabelButtonView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureRoutineID(routineID: Int64) {
        if let view = cellView as? IconImageSingleLabelButtonView {
            view.button.tag = Int(routineID)
        }
    }
    
    func configureText(text: String) {
        if let view = cellView as? IconImageSingleLabelButtonView {
            view.label.text = text
        }
    }
    
    func configureImage(image: UIImage?, colorValue: UIColor?) {
        if let view = cellView as? IconImageSingleLabelButtonView, let image = image {
            view.imageView.image = image
            if let colorValue = colorValue {
                view.imageView.tintColor = colorValue
                view.button.imageView?.tintColor = colorValue
            }
        }
    }
}
