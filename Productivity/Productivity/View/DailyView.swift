//
//  DailyView.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/17/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class DailyView: PRXibView {
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var everyDayButton: UIButton!

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
}
