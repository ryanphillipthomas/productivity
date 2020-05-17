//
//  AddRecorderView.swift
//  Productivity
//
//  Created by Ryan Thomas on 5/17/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class AddRecorderView: PRXibView {
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var editRecordingButton: UIButton!
    @IBOutlet weak var addRecordingButton: UIButton!
    @IBOutlet weak var innerView: PRBaseView!

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
        for button in buttons {
            button.roundCorners()
        }
    }
    
    func clear() {
        for button in buttons {
            button.backgroundColor = UIColor(hexString: "1F2123")
        }
    }
}
