//
//  SettingsManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation

let kBaseURLKey: String = "baseURLKey"
let kDefaultEnvKey: String = "DEFAULT_ENVIRONMENT"

class SettingsManager: NSObject {
    
    static let manager = SettingsManager()
    static var staticBaseURL: URL!
    
    var baseURL: URL {
        return SettingsManager.staticBaseURL
    }
    
    var baseURLForDisplayOnly: String {
        return baseURL.absoluteString
    }
    
    //MARK: Private
    private override init() {}
    
    //MARK: Class
    /*
        Base URL is now controlled by only WheelsUpSupportCode or ProcessInfo (Beta Target)
        If neither SupportCode or ProcessInfo exists, we can assume app should be using Prod URL
     */
    static func recreateBaseURL() {

        // Use the default environment from ProcessInfo if it exists
        if let defaultEnv = SettingsManager.environmentVariableDefaultURLString() {
            staticBaseURL = URL(string: defaultEnv)
            return
        }
        
        #if AUTOMATION
        staticBaseURL = URL(string: APIEnvironment.WHL_STAGING_URL)
        #endif
        
        staticBaseURL = URL(string: APIEnvironment.PRODUCTION_URL.rawValue)
    }
    
    static func environmentVariableDefaultURLString() -> String? {
        let environment: [String : String] = ProcessInfo.processInfo.environment
        return environment[kDefaultEnvKey]
    }
    
    //MARK: Public
    public class func shared() -> SettingsManager {
        SettingsManager.recreateBaseURL()
        return manager
    }

    public class func baseURLForSupportCode() -> String? {
        return APIEnvironment.PRODUCTION_URL.rawValue
    }
}
