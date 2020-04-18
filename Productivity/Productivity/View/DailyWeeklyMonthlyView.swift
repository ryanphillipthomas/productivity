//
//  DailyWeeklyMonthlyView.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/17/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class DailyWeeklyMonthlyView: PRXibView {
    @IBOutlet weak var dailyButton: UIButton!
    @IBOutlet weak var weeklyButton: UIButton!
    @IBOutlet weak var monthlyButton: UIButton!

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
        dailyButton.roundCorners()
        weeklyButton.roundCorners()
        monthlyButton.roundCorners()
        
    }
}
