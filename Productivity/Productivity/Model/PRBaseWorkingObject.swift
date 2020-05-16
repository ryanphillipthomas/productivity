//
//  PRBaseWorkingObject.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/12/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation

class PRBaseWorkingObject: NSObject {
    var routineId: Int64?
    var taskId: Int64?
    
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
    var chimeSoundFileURL: String?
    var announceSoundFileURL: String?
    var musicSoundFileURL: String?
    var musicSoundTemplateFileURL: String?
    var itemDescription: String?
    var imageName: String?

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
            routineId = routine.id
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
            chimeSoundFileURL = task.chimeSoundFileURL
            announceSoundFileURL = task.announceSoundFileURL
            musicSoundFileURL = task.musicSoundFileURL
            musicSoundTemplateFileURL = task.musicSoundTemplateFileURL
            imageName = task.imageName
            itemDescription = task.itemDescription
            routineId = task.routineId
        }
    }
}
