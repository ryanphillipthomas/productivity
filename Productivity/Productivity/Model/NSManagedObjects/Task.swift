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
    @NSManaged var order: Int64
    @NSManaged var length: Int64

    //MARK: Update
    public static func update(moc: NSManagedObjectContext, workingObject: PRBaseWorkingObject) {
        //dev clean this up....
        let objDict = ["id": workingObject.id ?? 1,
                       "name": workingObject.name ?? "Ryan Test",
                       "iconName": workingObject.iconName ?? "gear",
                       "colorValue": workingObject.colorValue ?? "#F80DE2",
                       "length": workingObject.length ?? 60,
                       "order": workingObject.order ?? 0] as NSDictionary
        
        let _ = insertIntoContext(moc:moc, dictionary: objDict)
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sectionSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        return [sectionSortDescriptor]
    }

    //MARK: Insert
    public static func insertIntoContext(moc: NSManagedObjectContext, dictionary:NSDictionary) -> Task? {
        guard let id = dictionary["id"] as? Int64, let name = dictionary["name"] as? String, let iconName = dictionary["iconName"] as? String, let colorValue = dictionary["colorValue"] as? String, let order = dictionary["order"] as? Int64, let length = dictionary["length"] as? Int64
            else {
                return nil
        }

        let predicate = NSPredicate(format: "id == %lld", id)
        let task = Task.findOrCreateInContext(moc: moc, matchingPredicate: predicate) { (task) in
            task.id = id
            task.name = name
            task.iconName = iconName
            task.colorValue = colorValue
            task.order = order
            task.length = length
        }

        return task
    }
    
    //All
    public static func fetchInContext(context: NSManagedObjectContext) -> [Task] {
        let request = sortedFetchRequest
        guard let result = try! context.fetch(request) as? [Task] else { fatalError("Fetched objects have wrong type") }
        return result
    }
    
    //MARK: Find
    public static func find(moc: NSManagedObjectContext, id:Int64) -> Task? {
        let predicate = NSPredicate(format: "id == %lld", id)
        return Task.findOrFetchInContext(moc: moc, matchingPredicate: predicate)
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
        let predicate = NSPredicate(format: "id == %lld", id)
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
