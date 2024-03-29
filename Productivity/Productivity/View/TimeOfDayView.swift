//
//  TimeOfDayView.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/18/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class TimeOfDayView: PRXibView {
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var morningButton: UIButton!
    @IBOutlet weak var afternoonButton: UIButton!
    @IBOutlet weak var eveningButton: UIButton!
    @IBOutlet weak var anyTimeButton: UIButton!
    
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
