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
    var playerQueue: AVQueuePlayer!
    var playerLooper: AVPlayerLooper!
    var trimmedTaskUrls = [URL]()
    var tasks: [Task]?

    //MARK: Private
    override private init() {}
    
    //MARK: Public
    public class func shared() -> AudioManager {
        return manager
    }
    
    func trimmedItems() -> [AVPlayerItem] {
        var items = [AVPlayerItem]()
        for url in trimmedTaskUrls {
            let task = AVPlayerItem(url: url)
            items.append(task)
        }
        return items
    }
    
    func spokenItems() -> [AVPlayerItem] {
        var items = [AVPlayerItem]()
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "routine.bundle") {
            for (_, url) in urls.enumerated() {
                let asset = AVAsset(url: url)
                let nextUpTrackItem = AVPlayerItem(asset: asset)
                items.append(nextUpTrackItem)
            }
        }
        return items
    }
    
    func routineList(trimmedItems:[AVPlayerItem]) -> [AVPlayerItem] {
        var items = [AVPlayerItem]()
        for (index, trimmedItem) in trimmedItems.enumerated() {
            
            let chimeItem = AVPlayerItem(url: AudioManager_Old.shared().chime)
            items.append(chimeItem)
            
            let nextItem = spokenItems()[index]
            items.append(nextItem)
            
            items.append(trimmedItem)
        }
        return items
    }
    
    var tick: URL {
        let path = Bundle.main.path(forResource: "tick", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    var silence: URL {
        let path = Bundle.main.path(forResource: "1-hour-and-20-minutes-of-silence", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    func setupItems(items: [AVPlayerItem]) {
        do {
          try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
          try AVAudioSession.sharedInstance().setActive(true)
        } catch {
          print(error)
        }

        playerQueue = AVQueuePlayer(items: items)
    }
    
    func playNext() {
        playerQueue.advanceToNextItem()
    }
    
    func play() {
        playerQueue.play()
    }
    
    func pause() {
        playerQueue.pause()
    }
    
    func setupTasks() {
        //Setup will create all trimmed audio files from the tasks in the context.
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = delegate.persistentContainer.viewContext
        tasks = Task.fetchInContext(context: managedObjectContext)
        if let tasks = tasks, tasks.count > 0 {
            for task in tasks {
                AudioManager.shared().trim(task: "\(task.id)", desiredLength: task.length)
            }
        }
    }
    
    func trim(task: String, desiredLength: Int64) {
        if let asset = AVAsset(url: silence) as? AVAsset {
            exportAsset(asset, fileName: "\(task).m4a", desiredLength: desiredLength)
        }
    }
    
    func exportAsset(_ asset: AVAsset, fileName: String, desiredLength: Int64) {
        print("\(#function)")
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        
        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists, removing \(trimmedSoundFileURL.absoluteString)")
            do {
                if try trimmedSoundFileURL.checkResourceIsReachable() {
                    print("is reachable")
                }
                
                try FileManager.default.removeItem(atPath: trimmedSoundFileURL.absoluteString)
            } catch {
                print("could not remove \(trimmedSoundFileURL)")
                print(error.localizedDescription)
            }
            
        }
        
        print("creating export session for \(asset)")
        
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileType.m4a
            exporter.outputURL = trimmedSoundFileURL
            trimmedTaskUrls.append(trimmedSoundFileURL)
            
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
