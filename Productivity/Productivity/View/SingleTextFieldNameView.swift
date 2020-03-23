//
//  SingleTextFieldNameView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/22/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class SingleTextFieldNameView: PRXibView {
    @IBOutlet weak var innerView: PRBaseView!
    @IBOutlet weak var textField: PRBaseTextField!

    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Styles
    private func setStyles() {
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        innerView.roundCorners()
    }
}
