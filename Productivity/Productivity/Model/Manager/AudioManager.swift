//
//  AudioManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 5/1/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData
import UIKit

class AudioManager: NSObject {
    static let manager = AudioManager()
    typealias CompletionHandler = (_ success: Bool) -> Void

    //MARK: Private
    override private init() {}
    
    //MARK: Public
    public class func shared() -> AudioManager {
        return manager
    }
    
    
    func removeFile(itemName:String, fileExtension: String) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        let filePath = "\(dirPath)/\(itemName).\(fileExtension)"
        do {
          try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
          print(error.debugDescription)
        }
    }
        
    func exportAsset(_ asset: AVAsset, fileName: String, desiredLength: Int64, completionBlock: CompletionHandler?) {
           print("\(#function)")
           
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
           let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
           print("saving to \(trimmedSoundFileURL.path)")
           
           if FileManager.default.fileExists(atPath: trimmedSoundFileURL.path) {
               print("sound exists, removing \(trimmedSoundFileURL.path)")
               do {
                   if try trimmedSoundFileURL.checkResourceIsReachable() {
                       print("is reachable")
                   }
                   
                   try FileManager.default.removeItem(atPath: trimmedSoundFileURL.path)
               } catch {
                   print("could not remove \(trimmedSoundFileURL)")
                   print(error.localizedDescription)
               }
               
           }
           
           print("creating export session for \(asset)")
           
           if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
               exporter.outputFileType = AVFileType.m4a
               exporter.outputURL = trimmedSoundFileURL
               
               let duration = CMTimeGetSeconds(asset.duration)
               if Int64(duration) < desiredLength {
                   print("sound is not long enough")
                   return
               }
               // e.g. the first 5 seconds
            let startTime = CMTimeMake(value: 0, timescale: 1)
            let stopTime = CMTimeMake(value: desiredLength, timescale: 1)
            exporter.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
               
               // do it
               exporter.exportAsynchronously(completionHandler: {
                   print("export complete \(exporter.status)")
                   
                   switch exporter.status {
                   case  AVAssetExportSessionStatus.failed:
                       
                       if let e = exporter.error {
                           print("export failed \(e)")
                       }
                       
                   case AVAssetExportSessionStatus.cancelled:
                       print("export cancelled \(String(describing: exporter.error))")
                   default:
                       print("export complete")
                   }
               })
           } else {
               print("cannot create AVAssetExportSession for asset \(asset)")
           }
           
       }
}
