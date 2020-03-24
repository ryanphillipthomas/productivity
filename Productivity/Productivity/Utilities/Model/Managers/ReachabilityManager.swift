//
//  ReachabilityManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
//import SwiftMessages

struct ReachabilityConstants {
    static let pingURL = "www.google.com"   //URL does not matter...just a gateway to check if we have the means of getting there
    static let shouldRemoveBannerAfterTimeout = false
    static let availableNotification = Notification(name: Notification.Name("kInternetAccessAvailable"))
    static let unavailableNotification = Notification(name: Notification.Name("kInternetAccessUnavailable"))
}

@objc public class ReachabilityManager: NSObject {
    
    /*
     * Defines the various connection types detected by reachability flags
     *  - ethernetOrWifi: The connection type is either over Ethernet or Wifi
     *  - wwan:           The connection type is a WWAN connection
     */
    public enum ReachabilityConnectionType {
        case ethernetOrWiFi
        case wwan
    }
    
    /*
     * Defines the various states of network reachability
     *  - unknown:      It is unknown whether the network is reachable
     *  - notReachable: The network is not reachable
     *  - reachable:    The network is reachable
     */
    public enum ReachabilityStatus {
        case unknown
        case notReachable
        case reachable(ReachabilityConnectionType)
    }
    
    static let shared = ReachabilityManager()
    
    private let reachability = SCNetworkReachabilityCreateWithName(nil, ReachabilityConstants.pingURL)
    private let queue = DispatchQueue.main
    private var currentReachabilityFlags: SCNetworkReachabilityFlags?
    private var isListening = false
    private var isShowingNoInternetView = false
    
    /// Whether the network is currently reachable
    public var isReachable: Bool { return isReachableOnWWAN || isReachableOnEthernetOrWiFi }
    
    /// Whether the network is currently reachable over the WWAN interface
    public var isReachableOnWWAN: Bool { return networkReachabilityStatus == .reachable(.wwan) }
    
    /// Whether the network is currently reachable over Ethernet or WiFi interface
    public var isReachableOnEthernetOrWiFi: Bool { return networkReachabilityStatus == .reachable(.ethernetOrWiFi) }
    
    // The current network reachability status
    public var networkReachabilityStatus: ReachabilityStatus {
        guard let flags = self.currentReachabilityFlags else { return .unknown }
        return reachabilityStatusFromFlags(flags)
    }
    
//    private var noInternetConfig: SwiftMessages.Config {
//        var config = SwiftMessages.defaultConfig
//        config.presentationStyle = .top
//        config.duration = .forever
//        config.interactiveHide = false
//        return config
//    }
//
//    private var noInternetView: MessageView {
//        let error = MessageView.viewFromNib(layout: .cardView)
//        //error.configureTheme(backgroundColor: UIColor.blue, foregroundColor: UIColor.white, iconImage: UIImage(imageLiteralResourceName: "wuFlightTrackerDestinationError"), iconText: nil)
//        error.configureContent(title: " Lorem ipsum", body: " Lorem ipsum medok")
//        error.button?.setImage(UIImage.init(imageLiteralResourceName: "small-button-close"), for: .normal)
//        error.button?.backgroundColor = UIColor.clear
//        error.button?.setTitle("", for: .normal)
//        error.button?.tintColor = UIColor.white
//        error.buttonTapHandler = { (sender) -> Void in
//            self.dismissNoInternetView()
//        }
//        return error
//    }
    
    //MARK: Initialization
    @objc private override init(){}
    
    //MARK: Public
    @objc public class func sharedInstance() -> ReachabilityManager {
        return ReachabilityManager.shared
    }
    
    @objc public func isActive() -> Bool {
        return isListening
    }
    
    // Starts listening to any changes in network connection
    @objc public func startListening() {
        
        guard !isListening, let reachability = reachability else {
            return
        }
        
        // Create a context
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        
        // Sets self as listener object
        context.info = UnsafeMutableRawPointer(Unmanaged<ReachabilityManager>.passUnretained(self).toOpaque())
        
        // Define our callback closures so we can check the flags
        let callbackClosure: SCNetworkReachabilityCallBack? = { (reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            
            guard let info = info else {
                return
            }
            
            // Gets the manager object from the context info
            let manager = Unmanaged<ReachabilityManager>.fromOpaque(info).takeUnretainedValue()
            
            //Check the flags on the main queue
            DispatchQueue.main.async {
                manager.checkReachability(flags)
            }
        }
        
        // Register the callback
        if !SCNetworkReachabilitySetCallback(reachability, callbackClosure, &context) {
            LogManager.shared().log("Error in configuring Reachability Callback", level: .error, origin: self.classForCoder)
        }
        
        // Set the dispatch queue (main)
        if !SCNetworkReachabilitySetDispatchQueue(reachability, queue) {
            LogManager.shared().log("Error in configuring Reachability Queue", level: .error, origin: self.classForCoder)
        }
        
        // Run so we set the current flags
        queue.async {
            
            // Reset flags
            self.currentReachabilityFlags = nil
            
            // Get new flags
            var flags = SCNetworkReachabilityFlags()
            SCNetworkReachabilityGetFlags(reachability, &flags)
            self.checkReachability(flags)
        }
        isListening = true
    }
    
    //Stops listening
    @objc public func stopListening() {
        guard isListening, let reachability = reachability else {
            return
        }
        
        // Remove callback and dispatch queue
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        isListening = false
    }
    
    //Returns whether or not you have internet access
    @objc public func isInternetAccessAvailable() -> Bool {
        if let flags = currentReachabilityFlags {
            return isReachableFromFlags(flags)
        } else {
            guard let reachability = reachability else {
                return false
            }
            
            // Synchronously get flags and check status that way
            var flags = SCNetworkReachabilityFlags()
            SCNetworkReachabilityGetFlags(reachability, &flags)
            currentReachabilityFlags = flags
            return isReachableFromFlags(flags)
        }
    }
    
    //MARK: Private
    private func reachabilityStatusFromFlags(_ flags: SCNetworkReachabilityFlags) -> ReachabilityStatus {
        guard isReachableFromFlags(flags) else {
            return .notReachable
        }
        var networkStatus: ReachabilityStatus = .reachable(.ethernetOrWiFi)
        
        #if os(iOS)
        if flags.contains(.isWWAN) { networkStatus = .reachable(.wwan) }
        #endif
        
        return networkStatus
    }
    
    private func isReachableFromFlags(_ flags: SCNetworkReachabilityFlags) -> Bool{
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
    
    private func presentNoInternetView() {
        DispatchQueue.main.async {
            //SwiftMessages.show(config: self.noInternetConfig, view: self.noInternetView)
        }
        isShowingNoInternetView = true
    }
    
    private func dismissNoInternetView() {
        DispatchQueue.main.async {
            //SwiftMessages.hide(id: self.noInternetView.id)
        }
        isShowingNoInternetView = false
    }
    
    private func checkReachability(_ flags: SCNetworkReachabilityFlags) {
        if(currentReachabilityFlags != flags) {
            currentReachabilityFlags = flags
            let isInternetAvailable = isInternetAccessAvailable()
            if (!isInternetAvailable && !isShowingNoInternetView) {
                presentNoInternetView()
            } else {
                dismissNoInternetView()
            }
            NotificationCenter.default.post(isInternetAvailable ? ReachabilityConstants.availableNotification : ReachabilityConstants.unavailableNotification)
        }
    }
}

extension ReachabilityManager.ReachabilityStatus: Equatable {}
public func ==(left:   ReachabilityManager.ReachabilityStatus,
               right:  ReachabilityManager.ReachabilityStatus) -> Bool {
    switch (left, right) {
    case (.unknown, .unknown):
        return true
    case (.notReachable, .notReachable):
        return true
    case let (.reachable(leftConnectionType), .reachable(rightConnectionType)):
        return leftConnectionType == rightConnectionType
    default:
        return false
    }
}
