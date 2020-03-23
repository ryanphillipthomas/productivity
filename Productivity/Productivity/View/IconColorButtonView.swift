//
//  IconColorButtonView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/22/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class IconColorButtonView: PRXibView {
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!

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
        colorButton.roundCorners()
        iconButton.roundCorners()
    }
}
