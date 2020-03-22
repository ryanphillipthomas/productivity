//
//  LogManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import NSLogger

//MARK: LogLevel
public enum LogLevel: Int {
    case none = 0
    case trace          // The flow through the application.  Ex: Navigation, BE activity, IBActions, etc...
    case debug          // Expanded flow through the application including logs that are meant solely for debugging purposes
    case error          // NSErrors that occur for any reason
    case backend        // All backend calls
    case verbose        // All of the above
    
    func getDisplayLogLevel() -> String {
        switch self {
        case .trace:     return "Trace"
        case .debug:     return "Debug"
        case .error:     return "Error"
        case .backend:   return "API"
        default:         return ""
        }
    }
}

//MARK: LogQueueNode
public struct LogQueueNode {
    var log: String!
    var level: LogLevel!
    var origin: AnyClass!
    var timeStamp: Date?
    var url: String?
    var statusCode: Int?
    var httpMethod: String?
    var httpHeaders: [String : String]?
    var requestParameters: [String : Any]?
    var responseData: Data?
}

//MARK: LogManager
public class LogManager: NSObject {
    
    static let manager = LogManager()
    let logLevel = LogLevel.verbose
    let folderName = "logs"
    let logFile = "log.txt"
    let emptyFile = ""
    var logQueue: [LogQueueNode] = []
    var isVerbose: Bool {
        return logLevel == .verbose
    }
    
    //MARK: Private
    private override init() {}
    
    private func logForNSLogger(log: String, level: LogLevel) {
        #if targetEnvironment(simulator)
        return
        #else
        switch level {
        case .trace:    Logger.shared.log(.custom("Trace"), .info, log)
        case .debug:    Logger.shared.log(.custom("Debug"), .debug, log)
        case .error:    Logger.shared.log(.custom("Error"), .error, log)
        case .backend:  Logger.shared.log(.custom("Backend"), .debug, log)
        case .verbose:  LogMessageRaw(log)
        default:        return
        }
        #endif
    }
    
    private func logForConsole(log: String, level: LogLevel) {
        if isVerbose {
            print(log)
        } else {
            switch logLevel {
            case .trace:       if level == .trace { print(log) }
            case .debug:       if level == .trace || level == .debug { print(log) }
            case .error:       if level == .trace || level == .error { print(log) }
            case .backend:     if level == .backend { print(log) }
            default:           return
            }
        }
    }
    
    private func logForLogMode(node: LogQueueNode) {
        
//        #warning("Check for LogMode support code here and only log if LogMode is activated")
        logQueue.append(node)
    }
    
    //MARK: Public
    public class func shared() -> LogManager {
        return manager
    }
    
    public func getLoggerViewController() -> LoggerViewController {
        let vc = UIStoryboard(name: "Log", bundle: Bundle(for: self.classForCoder)).instantiateViewController(withIdentifier: String(describing: LoggerViewController.self)) as! LoggerViewController
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    public func logAPI(log: String,
                       timeStamp: Date,
                       level: LogLevel,
                       origin: AnyClass,
                       url: String,
                       httpMethod: String,
                       httpHeaders: [String : String],
                       statusCode: Int,
                       requestParameters: [String : Any]?,
                       responseData: Data?) {
        
        let node = LogQueueNode(log: log,
                                level: level,
                                origin: origin,
                                timeStamp: timeStamp,
                                url: url,
                                statusCode: statusCode,
                                httpMethod: httpMethod,
                                httpHeaders: httpHeaders,
                                requestParameters: requestParameters,
                                responseData: responseData)
        logForLogMode(node: node)
        self.log(log, level: level, origin: origin)
    }
        
    public func log(_ log: String, level: LogLevel, origin: AnyClass) {
        let formattedLog = "(\(String(describing: origin))) " + log
        logForNSLogger(log: formattedLog, level: level)
        logForConsole(log: formattedLog, level: level)
    }
    
    @discardableResult static func addSkipBackupAttribute(url: URL) throws -> Bool {
         var fileUrl = url
         do {
             if FileManager.default.fileExists(atPath: fileUrl.path) {
                 var resourceValues = URLResourceValues()
                 resourceValues.isExcludedFromBackup = true
                 try fileUrl.setResourceValues(resourceValues)
             }
             return true
         } catch {
             #if DEBUG
             print("failed setting isExcludedFromBackup \(error)")
             #endif
             return false
         }
     }
    
    public func createFileAndWrite(fileURL: URL, text: String) {
        
          //create directory
          do {
              try FileManager.default.createDirectory(atPath: fileURL.path, withIntermediateDirectories: true, attributes: nil)
          } catch {
              #if DEBUG
              print(error)
              #endif
          }
          
          //add skip backup attribute
          do {
            try LogManager.addSkipBackupAttribute(url: fileURL)
          } catch {
              #if DEBUG
              print(error)
              #endif
          }
          
          //write file
          let file = fileURL.appendingPathComponent(logFile)
          do {
              try text.write(to: file, atomically: false, encoding: .utf8)
          } catch {
              #if DEBUG
              print(error)
              #endif
          }
          
          if (!FileManager.default.fileExists(atPath: fileURL.path)) {
              print("FAILED!!")
          }
    }
    
    public func write(text: String) {
        let file = logFile
        if let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first, let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folderName) {
            let fileURL = writePath.appendingPathComponent(file)
            do {
                let existingText = try String(contentsOf: fileURL, encoding: .utf8)
                var finalText = text
                finalText += existingText
                
                ///DEV TODO: Get file size, check if file size is greater than restrited size. If so call clear before calling write.
                try finalText.write(to: fileURL, atomically: false, encoding: .utf8)
                
            } catch {
                if (!FileManager.default.fileExists(atPath: fileURL.absoluteString)) {
                    createFileAndWrite(fileURL: writePath, text: text)
                }
            }
        }
    }
            
    public func clearFile() {
        let file = logFile
        let empty = emptyFile
        if let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first, let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folderName) {
            let fileURL = writePath.appendingPathComponent(file)
            do {
                try empty.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                #if DEBUG
                print(error)
                #endif
            }
        }
    }
}
