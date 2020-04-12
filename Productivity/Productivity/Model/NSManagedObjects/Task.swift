//
//  Task.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/11/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import CoreData

class Task: PRManagedObject {
    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var iconName: String
    @NSManaged var colorValue: String

    //MARK: Update
    public static func update(moc: NSManagedObjectContext, workingObject: PRBaseWorkingObject) {
        //dev clean this up....
        let objDict = ["id": workingObject.id ?? 1,
                       "name": workingObject.name ?? "Ryan Test",
                       "iconName": workingObject.iconName ?? "gear",
                       "colorValue": workingObject.colorValue ?? "#F80DE2"] as NSDictionary
        
        let _ = insertIntoContext(moc:moc, dictionary: objDict)
    }

    //MARK: Insert
    public static func insertIntoContext(moc: NSManagedObjectContext, dictionary:NSDictionary) -> Task? {
        guard let id = dictionary["id"] as? Int64, let name = dictionary["name"] as? String, let iconName = dictionary["iconName"] as? String, let colorValue = dictionary["colorValue"] as? String
            else {
                return nil
        }

        let predicate = NSPredicate(format: "id == %i", id)
        let task = Task.findOrCreateInContext(moc: moc, matchingPredicate: predicate) { (task) in
            task.id = id
            task.name = name
            task.iconName = iconName
            task.colorValue = colorValue
        }

        return task
    }

    //MARK: Delete
    public static func removeAll(moc: NSManagedObjectContext) {
        let tasksToRemove = fetchInContext(context: moc)

        // Loop and delete all task
        for task in tasksToRemove {
            moc.delete(task)
        }
        _ = moc.saveOrRollback()
    }

    public static func delete(id: Int64, moc: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "id == %i", id)
        if let task = Task.findOrFetchInContext(moc: moc, matchingPredicate: predicate) {
            moc.delete(task)
            _ = moc.saveOrRollback()
        }
    }

}

extension Task: ManagedObjectType {
    public static var entityName: String {
        return String(describing: self)
    }
}
