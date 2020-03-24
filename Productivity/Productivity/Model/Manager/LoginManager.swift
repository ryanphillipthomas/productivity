//
//  LoginManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData

public class LoginManager: NSObject {
    
    //*Needs Coverage*/
    
    static let manager = LoginManager()
    private var managedObjectContext: NSManagedObjectContext!
    var authorizedSession: URLSession!
    var loggedIn = false
    var suppressUpdateCounter: Int?

    //MARK: Private
    override private init() {}
    
    //MARK: Public
    public class func shared() -> LoginManager {
        return manager
    }
    
    func setupWithManagedObjectContext(moc:NSManagedObjectContext) {
        managedObjectContext = moc
    }
    
    //MARK: First Login
    func isUserFirstLogin(userId: NSNumber) -> Bool {
        let userDefaults = UserDefaults.standard
        guard let loginArray = userDefaults.array(forKey: Constants.Keys.kLoginArray) as? [NSNumber] else {
            return true
        }
        return !loginArray.contains(userId)
    }
    
    func setUserLogin(userId: NSNumber) {
        let userDefaults = UserDefaults.standard
        if var loginArray = userDefaults.array(forKey: Constants.Keys.kLoginArray) as? [NSNumber] {
            if (!loginArray.contains(userId)){
                loginArray.append(userId)
                userDefaults.set(loginArray, forKey: Constants.Keys.kLoginArray)
            }
        } else {
            userDefaults.set([userId], forKey: Constants.Keys.kLoginArray)
        }
    }

    //MARK: Login & Logout Public Methods
    func save(email: String, token: String, uuid: NSUUID, auth:String) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "CurrentUserEmail")
        defaults.set(uuid.uuidString, forKey: "CurrentWUUUID")
        defaults.set(token, forKey: "WUToken")
        defaults.set(auth, forKey: "WUAuth")
        defaults.synchronize()
        
        DispatchQueue.main.async {
            self.asynchronouslyUpdateLoggedInAndAuthorizedSession()
        }
    }
    
    var hasCurrentUserEmail: Bool {
        let defaults = UserDefaults.standard
        return defaults.value(forKey: "CurrentUserEmail") != nil
    }
    
    func logoutAndLogin(statusCode: Int, token: String, name: String) {
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "WUToken-Auto")
        defaults.set(token, forKey: "WUName-Auto")
        defaults.synchronize()
        logout()
    }
    
    func logout() {
        if !loggedIn {
            return
        }
        
        //Post Did Logout Notification
        NotificationCenter.default.post(name: .didLogout, object: nil)
        
        //Invalidate Session and Login State
        authorizedSession.invalidateAndCancel()
        authorizedSession = nil
        loggedIn = false
        
        //Reset User Defaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "LastSuccessfulTermsConditionsCheck")
        defaults.removeObject(forKey: "CurrentUserEmail")
        defaults.removeObject(forKey: "CurrentWUUUID")
        defaults.removeObject(forKey: "WUToken")
        defaults.removeObject(forKey: "WUAuth")
        defaults.set("LoggedOut", forKey: "LoggedOut") //depricate?
        
        defaults.synchronize()
        
        //Remove all managedObjects
        User.removeAllUsers(moc: managedObjectContext)
    }
    
    private func asynchronouslyUpdateLoggedInAndAuthorizedSession() {
        if loggedIn {
            return
        }
        
        // Pull from NSUserDefaults, which is thread-safe.
        // Short circuit if we've got nothing.
        let defaults = UserDefaults.standard
        guard let email = defaults.object(forKey: "CurrentUserEmail") as? String, let token = defaults.object(forKey: "WUToken") as? String, let auth = defaults.object(forKey: "WUAuth") as? String else {
            return logout()
        }
        
        if email.isEmpty || token.isEmpty || auth.isEmpty {
            return logout()
        }
        
        // Make an Authorization header
        let unencAuthPayload = "\(email):\(token)"
        let userPwdData = unencAuthPayload.data(using: .utf8)
        
        guard let base64EncodedCredential = userPwdData?.base64EncodedString(options: .lineLength64Characters) else {
            return logout()
        }
        
        let authString = "Basic \(base64EncodedCredential)"
        guard let infoDictionary = Bundle.main.infoDictionary else {
            return logout()
        }
        
        let internalVersion = infoDictionary["CFBundleShortVersionString"] ?? "1.0"
        
        // The HTTP headers we need. We'll either plug these into a
        // new NSURLSessionConfigure or just use it for comparison.
        let requiredHeaders = ["WUToken" : token,
                               "WU-UUID" : "WU-UUID",
                               "Authorization" : authString,
                               "WU-Authorization" : auth,
                               "WU-Client-Type" : "MOBILE_IOS",
                               "WU-App-Version" : internalVersion]
        
        // (Re-)create the authorized session if we current have none
        // or its most important configuration properties differ from
        // what we're expecting.
        
        if authorizedSession == nil {
            createSession(requiredHeaders: requiredHeaders)
        }
        
        let curConfig = authorizedSession.configuration
        if let additionalHeaders = curConfig.httpAdditionalHeaders {
            let httpAdditionalHeadersDictionary = NSDictionary(dictionary: additionalHeaders)
            let requiredHeadersDictionary = NSDictionary(dictionary: requiredHeaders)
            if httpAdditionalHeadersDictionary != requiredHeadersDictionary {
                createSession(requiredHeaders: requiredHeaders)
            }
        }
        
        loggedIn = true
        
        //Post Did Login Notification
        NotificationCenter.default.post(name: .didLogin, object: nil)
    }
    
    private func createSession(requiredHeaders:[String : Any?]) {
        authorizedSession.invalidateAndCancel()
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = requiredHeaders as [AnyHashable : Any]
        config.httpCookieAcceptPolicy = .always
        config.httpCookieStorage?.cookieAcceptPolicy = .always
        config.httpShouldSetCookies = false
        authorizedSession = URLSession(configuration: config)
    }
}

extension Notification.Name {
    static let didLogin = Notification.Name("didLogin")
    static let didLogout = Notification.Name("didLogout")
}
