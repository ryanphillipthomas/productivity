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
    var frequency: String?
    var frequencyDays: [Int?]?
    var frequencyEveryDay: Bool?
    var timeOfDay: String?
    var length: Int64?
    var order: Int64?
    var chimeSoundFileName: String?
    var announceSoundFileName: String?
    var musicSoundFileName: String?
    var musicSoundTemplateFileName: String?

    func configureFrom(routine: Routine?) {
        if let routine = routine {
            id = routine.id
            name = routine.name
            iconName = routine.iconName
            colorValue = routine.colorValue
            frequency = routine.frequency
            frequencyDays = routine.frequencyDays
            frequencyEveryDay = routine.frequencyEveryDay
            timeOfDay = routine.timeOfDay
            length = routine.length
        }
    }
    
    func configureFrom(task: Task?) {
        if let task = task {
            id = task.id
            name = task.name
            iconName = task.iconName
            colorValue = task.colorValue
            length = task.length
            order = task.order
            chimeSoundFileName = task.chimeSoundFileName
            announceSoundFileName = task.announceSoundFileName
            musicSoundFileName = task.musicSoundFileName
            musicSoundTemplateFileName = task.musicSoundTemplateFileName
        }
    }
}
