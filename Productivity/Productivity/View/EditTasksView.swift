//
//  EditTasksView.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/19/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class EditTasksView: PRXibView {
    @IBOutlet weak var innerView: PRBaseView!
    @IBOutlet weak var tableView: UITableView!

    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyles()
    }
    
    //MARK: Styles
    private func setStyles() {
        innerView.roundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
