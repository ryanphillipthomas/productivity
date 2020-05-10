//
//  TextView.swift
//  Productivity
//
//  Created by Ryan Thomas on 5/10/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class TextView: PRXibView {
    @IBOutlet weak var innerView: PRBaseView!
    @IBOutlet weak var textView: UITextView!

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
        textView.backgroundColor = .clear
        innerView.roundCorners()
    }
}
