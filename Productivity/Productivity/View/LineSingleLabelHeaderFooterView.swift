//
//  LineSingleLabelHeaderFooterView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class LineSingleLabelHeaderFooterView: PRXibView {
    @IBOutlet weak var rightLine: PRBaseView!
    @IBOutlet weak var leftLine: PRBaseView!
    @IBOutlet weak var label: UILabel!

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
        
    }
}
