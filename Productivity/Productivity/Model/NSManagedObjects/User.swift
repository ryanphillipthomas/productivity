//
//  User.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import CoreData

class User: PRManagedObject {
    @NSManaged var id: Int64
    @NSManaged var passengerId: Int64
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var email: String
    @NSManaged var imageUrl: String
    @NSManaged var type: String
    
    @NSManaged var isPrincipal: Bool
    @NSManaged var enabled: Bool
    @NSManaged var isCurrentUser: Bool
    @NSManaged var termsAndConditionsAccepted: Bool
    @NSManaged var gdprAccepted: Bool
    
    //MARK: Insert
    public static func insertIntoContext(moc: NSManagedObjectContext, userDictionary:NSDictionary) -> User? {
        guard let id = userDictionary["id"] as? Int64
            else {
                return nil
        }
        
        let predicate = NSPredicate(format: "id == %i", id)
        let user = User.findOrCreateInContext(moc: moc, matchingPredicate: predicate) { (user) in
            user.id = id
        }
        
        return user
    }
    
    //MARK: Delete
    public static func removeAllUsers(moc: NSManagedObjectContext) {
        let usersToRemove = fetchInContext(context: moc)
        
        // Loop and delete all users
        for user in usersToRemove {
            moc.delete(user)
        }
        _ = moc.saveOrRollback()
    }
    
    public static func delete(id: Int, moc: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "id == %i", id)
        if let user = User.findOrFetchInContext(moc: moc, matchingPredicate: predicate) {
            moc.delete(user)
            _ = moc.saveOrRollback()
        }
    }
    
    //MARK: Current User
    public static func currentUser(moc: NSManagedObjectContext) -> User? {
        let predicate = NSPredicate(format: "isCurrentUser = YES")
        guard let user = User.findOrFetchInContext(moc: moc, matchingPredicate: predicate) else {
            return nil
        }
        return user
    }
}

extension User: ManagedObjectType {
    public static var entityName: String {
        return String(describing: self)
    }
}

