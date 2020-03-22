//
//  Constants.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public enum APIEnvironment: String {
    case PRODUCTION_URL =   "https://api.com"
    
    func envFromBaseURLString(baseURL: String) -> APIEnvironment? {
        return APIEnvironment(rawValue: baseURL)
    }
}

public enum UserType: String {
    case WHL_STANDARD = "STANDARD"
}

public var appDelegateContext: NSManagedObjectContext {
    return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
}

public var isProductionServer: Bool {
    let baseURL = SettingsManager.shared().baseURLForDisplayOnly
    return baseURL == APIEnvironment.PRODUCTION_URL.rawValue
}

public var isUnitTesting: Bool {
    return NSClassFromString("XCTestCase") != nil
}

public var isSimulator: Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
}

public struct Constants {
    static let SERVICES_VERSION = "1.0"
    static let networkTimeout = 60.0
    
    struct Storyboards {
        static let logStoryboard = UIStoryboard(name: "Log", bundle: nil)
        static let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        static let tabBarStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
    }
    
    struct Notifications {
        static let nInternetAccessUnavailable = Notification.Name("kInternetAccessUnavailable")
    }
    
    struct Keys {
        static let kLoginArray = "kLoginArray"
        static let kLastSuccessfulTermsConditionsCheck = "LastSuccessfulTermsConditionsCheck"
    }
    
    struct Contact {
        static let Email_Support = "support@email.com"
    }
}
