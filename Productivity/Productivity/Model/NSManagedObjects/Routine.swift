//
//  Routine.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/11/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import CoreData

class Routine: PRManagedObject {
    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var iconName: String
    @NSManaged var colorValue: String
    
    @NSManaged var frequency: String
    @NSManaged var frequencyDays: [Int]
    @NSManaged var frequencyEveryDay: Bool
    @NSManaged var timeOfDay: String
    
    @NSManaged var length: Int64

    //MARK: Update
    public static func update(moc: NSManagedObjectContext, workingObject: PRBaseWorkingObject) {
        //dev clean this up....
        let objDict = ["id": workingObject.id ?? 1,
                       "name": workingObject.name ?? "Ryan Test",
                       "iconName": workingObject.iconName ?? "gear",
                       "colorValue": workingObject.colorValue ?? "#F80DE2",
                       "frequency": workingObject.frequency ?? "daily",
                       "frequencyDays": workingObject.frequencyDays ?? [],
                       "frequencyEveryDay": workingObject.frequencyEveryDay ?? true,
                       "timeOfDay": workingObject.timeOfDay ?? "At any time" ] as NSDictionary
        
        let _ = insertIntoContext(moc:moc, dictionary: objDict)
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sectionSortDescriptor = NSSortDescriptor(key: "timeOfDay", ascending: true)
        return [sectionSortDescriptor]
    }
    
    //MARK: Insert
    public static func insertIntoContext(moc: NSManagedObjectContext, dictionary:NSDictionary) -> Routine? {
        guard let id = dictionary["id"] as? Int64, let name = dictionary["name"] as? String, let iconName = dictionary["iconName"] as? String, let colorValue = dictionary["colorValue"] as? String, let frequency = dictionary["frequency"] as? String, let frequencyDays = dictionary["frequencyDays"] as? [Int], let timeOfDay = dictionary["timeOfDay"] as? String, let frequencyEveryDay = dictionary["frequencyEveryDay"] as? Bool
            else {
                return nil
        }

        let predicate = NSPredicate(format: "id == %lld", id)
        let routine = Routine.findOrCreateInContext(moc: moc, matchingPredicate: predicate) { (routine) in
            routine.id = id
            routine.name = name
            routine.iconName = iconName
            routine.colorValue = colorValue
            routine.frequency = frequency
            routine.frequencyDays = frequencyDays
            routine.frequencyEveryDay = frequencyEveryDay
            routine.timeOfDay = timeOfDay
        }
        
        return routine
    }
    
    //MARK: Find
    public static func find(moc: NSManagedObjectContext, id:Int64) -> Routine? {
        let predicate = NSPredicate(format: "id == %lld", id)
        return Routine.findOrFetchInContext(moc: moc, matchingPredicate: predicate)
    }

    //MARK: Delete
    public static func removeAll(moc: NSManagedObjectContext) {
        let routinesToRemove = fetchInContext(context: moc)

        // Loop and delete all routines
        for routine in routinesToRemove {
            moc.delete(routine)
        }
        _ = moc.saveOrRollback()
    }

    public static func delete(id: Int64, moc: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "id == %lld", id)
        if let routine = Routine.findOrFetchInContext(moc: moc, matchingPredicate: predicate) {
            moc.delete(routine)
            _ = moc.saveOrRollback()
        }
    }
}

extension Routine: ManagedObjectType {
    public static var entityName: String {
        return String(describing: self)
    }
}
