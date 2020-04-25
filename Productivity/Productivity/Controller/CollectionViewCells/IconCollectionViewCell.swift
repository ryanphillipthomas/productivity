//
//  IconCollectionViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class IconCollectionViewCell: PRBaseCollectionViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = IconView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureImage(image: UIImage?) {
        if let view = cellView as? IconView {
            view.imageView.tintColor = UIColor.random
            view.imageView.image = image
        }
    }
}
