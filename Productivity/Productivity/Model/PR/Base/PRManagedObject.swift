//
//  PRManagedObject.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData

open class PRManagedObject: NSManagedObject {

}

public protocol ManagedObjectType: class {
    static var sortedFetchRequest:NSFetchRequest<NSFetchRequestResult> {get}
    static var entityName:String {get}
    static var defaultSortDescriptors:[NSSortDescriptor] {get}
    static var defaultPredicate:NSPredicate? {get}
}

extension ManagedObjectType {
    public static var defaultSortDescriptors:[NSSortDescriptor] {
        let sectionSortDescriptor = NSSortDescriptor(key: "timeOfDay", ascending: true)
        return [sectionSortDescriptor]
    }
    
    public static var defaultPredicate: NSPredicate? {
        return nil
    }
    
    public static var sortedFetchRequest:NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}

extension ManagedObjectType where Self: PRManagedObject {
    
    public static func findOrCreateInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [], configure: (Self) -> ()) -> Self {
        guard let obj = findOrFetchInContext(moc: moc, matchingPredicate: predicate) else {
            let newObject: Self = moc.insertObject()
            configure(newObject)
            return newObject
        }
        configure(obj)
        return obj
    }
    
    
    public static func findOrFetchInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> Self? {
        guard let obj = materializedObjectInContext(moc: moc, matchingPredicate: predicate) else {
            return fetchInContext(context: moc) { request in
                request.predicate = predicate
                request.sortDescriptors = sortDescriptors
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                }.first
        }
        return obj
    }
    
    public static func fetchInContext(context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        configurationBlock(request)
        guard let result = try! context.fetch(request) as? [Self] else { fatalError("Fetched objects have wrong type") }
        return result
    }
    
    public static func countInContext(context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> () = { _ in }) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        configurationBlock(request)
        
        let result = try! context.count(for: request)
        
        return result
    }
    
    public static func materializedObjectInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate?) -> Self? {
        for obj in moc.registeredObjects where !obj.isFault {
            if let predicate = predicate {
                guard let res = obj as? Self, predicate.evaluate(with: res) else { continue }
                return res
            } else {
                guard let res = obj as? Self else { continue }
                return res
            }
        }
        return nil
    }
}

extension NSManagedObjectContext {
    public func insertObject<A:PRManagedObject>() -> A where A:ManagedObjectType {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {fatalError("wrong object type - Type should be \(A.entityName))")}
        return obj
    }
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performChanges(block:@escaping ()->()){
        perform {
            block()
            if self.saveOrRollback() {
                LogManager.shared().log("Success performing core data changes", level: .debug, origin: self.classForCoder)
            } else {
                LogManager.shared().log("Error performing core data changes", level: .error, origin: self.classForCoder)
            }
        }
    }
}
