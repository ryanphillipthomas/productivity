//
//  EditHeaderFooterHeaderFooterView.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

class EditHeaderFooterHeaderFooterView: PRBaseTableViewCell<UIView> {
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = LineSingleLabelHeaderFooterView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureText(text: String) {
        if let view = cellView as? LineSingleLabelHeaderFooterView {
            view.label.text = text
        }
    }
}
