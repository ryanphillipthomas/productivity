//
//  GenericCodableManagedObject.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData

public enum CodableObject: String {
    case AuthorizedUser = "AuthorizedUser"
}

class GenericCodableManagedObject: PRManagedObject {

    @NSManaged var name: String
    @NSManaged var data: Data
    
    //MARK: Archive & Unarchive
    static func archive<T: Codable>(codableObject: T, context: NSManagedObjectContext) -> GenericCodableManagedObject? {
        do {
            let data = try JSONEncoder().encode(codableObject.self)
            let managedObject = GenericCodableManagedObject.insertIntoContext(moc: context)
            managedObject?.name = String(describing: T.self)
            managedObject?.data = data
            return managedObject
        } catch let error {
            LogManager.shared().log("\(error.localizedDescription)", level: .error, origin: self.classForCoder())
            return nil
        }
    }
    
    func unarchiveAs<T: Codable>(codable: T.Type) -> Codable? {
        do {
            return try JSONDecoder().decode(codable, from: data)
        } catch let error {
            LogManager.shared().log("\(error.localizedDescription)", level: .error, origin: self.classForCoder)
            return nil
        }
    }

    //MARK: Context
    public static func insertIntoContext(moc: NSManagedObjectContext) -> GenericCodableManagedObject? {
        let managedCodableObject = GenericCodableManagedObject.findOrCreateInContext(moc: moc) { (object) in
            // Nothing for now
        }
        return managedCodableObject
    }
}

extension GenericCodableManagedObject: ManagedObjectType {
    public static var entityName: String {
        return String(describing: self)
    }
}

protocol GenericCodableManagedObjectProtocol {
    func archive(context: NSManagedObjectContext) -> GenericCodableManagedObject?
}

