//
//  CreateTemplateTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

//MARK: CreateTemplateTableViewCell
class CreateTemplateTableViewCell: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = TwoLabelImageView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureText(text: String, subText: String) {
        if let view = cellView as? TwoLabelImageView {
            view.label.text = text
            view.subLabel.text = subText
        }
    }
    
    func configureImage(image: UIImage?) {
        if let view = cellView as? TwoLabelImageView, let image = image {
            view.imageView.image = image
        }
    }
}
