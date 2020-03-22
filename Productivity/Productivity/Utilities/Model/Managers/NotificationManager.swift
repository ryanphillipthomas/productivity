//
//  NotificationManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

public class NotificationManager: NSObject {
    
    static let manager = NotificationManager()
    public var lastNotificationObserved: Notification?
    public var currentObservers: [String : Set<String>] = [:]
    
    //MARK: Private
    private override init() {}
    
    private func getStringForViewController(controller: UIViewController) -> String {
        return NSStringFromClass(type(of: controller))
    }
    
    //MARK: Public
    public class func sharedInstance() -> NotificationManager {
        return manager
    }
    
    public func getLastNotificationObserved() -> Notification? {
        return lastNotificationObserved
    }
    
    public func getAllCurrentObservers() -> [String] {
        var allObservers: [String] = []
        for key in currentObservers.keys {
            if let set = currentObservers[key] {
                allObservers += Array(set)
            }
        }
        return allObservers
    }
    
    public func getCurrentObserversForClass(vc: UIViewController) -> [NSString] {
        let key = getStringForViewController(controller: vc)
        if let observers = currentObservers[key] {
            return Array(observers) as [NSString]
        } else {
            return []
        }
    }
    
    public func insertObserverForClass(observer: String, vc: UIViewController) {
        let key = getStringForViewController(controller: vc)
        if (!(currentObservers[key] != nil)) {
            currentObservers[key] = [observer]
        } else {
            var observersForClass = currentObservers[key]
            observersForClass?.insert(observer)
            currentObservers[key] = observersForClass
        }
    }
    
    public func insertObserversForClass(observers: [String], vc: UIViewController) {
        for observer in observers {
            self.insertObserverForClass(observer: observer, vc: vc)
        }
    }
    
    public func removeAllObserversForClass(vc: UIViewController) {
        let key = getStringForViewController(controller: vc)
        currentObservers.removeValue(forKey: key)
    }
    
    public func didObserveForNotification(notification: Notification) {
        lastNotificationObserved = notification
    }
}
