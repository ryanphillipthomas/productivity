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

    //MARK: Insert
    public static func insertIntoContext(moc: NSManagedObjectContext, dictionary:NSDictionary) -> Task? {
        guard let id = dictionary["id"] as? Int64
            else {
                return nil
        }

        let predicate = NSPredicate(format: "id == %i", id)
        let routine = Task.findOrCreateInContext(moc: moc, matchingPredicate: predicate) { (routine) in
            routine.id = id
        }

        return routine
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
        let predicate = NSPredicate(format: "id == %i", id)
        if let routine = Task.findOrFetchInContext(moc: moc, matchingPredicate: predicate) {
            moc.delete(routine)
            _ = moc.saveOrRollback()
        }
    }

}

extension Task: ManagedObjectType {
    public static var entityName: String {
        return String(describing: self)
    }
}
