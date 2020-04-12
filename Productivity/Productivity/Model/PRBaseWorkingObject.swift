//
//  PRBaseWorkingObject.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/12/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation

class PRBaseWorkingObject: NSObject {
    var id: Int64?
    var name: String?
    var iconName: String?
    var colorValue: String?

    func configureFrom(routine: Routine?) {
        if let routine = routine {
            id = routine.id
            name = routine.name
            iconName = routine.iconName
            colorValue = routine.colorValue
        }
    }
}
