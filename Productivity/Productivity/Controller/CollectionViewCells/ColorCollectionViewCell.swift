//
//  ColorCollectionViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class ColorCollectionViewCell: PRBaseCollectionViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureColor(color: UIColor?) {
        if let view = cellView as? IconView {
            view.imageView.image = UIImage(systemName: "circle.fill")
            view.imageView.tintColor = color
        }
    }
}
