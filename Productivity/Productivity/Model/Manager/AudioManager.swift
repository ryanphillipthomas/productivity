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
    var playerQueue: AVQueuePlayer?
    var playerLooper: AVPlayerLooper!
    var trimmedTaskUrls = [URL]()
    
    var tasks: [Task]?
    var timeObserverToken: Any?

    //MARK: Private
    override private init() {
        do {
          try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
          try AVAudioSession.sharedInstance().setActive(true)
        } catch {
          print(error)
        }
    }
    
    //MARK: Public
    public class func shared() -> AudioManager {
        return manager
    }
    
    //MARK: Get Current Task
    var currentTask: Task? {
        var currentTask: Task?
        if let que = AudioManager.shared().playerQueue, let item = que.currentItem {
            //Get the TaskIDString of the current item
            var taskIDString: String = ""
            for i in item.externalMetadata {
                if i.identifier == .commonIdentifierAssetIdentifier {
                    taskIDString = i.value as! String
                }
            }
            
            //Fetch the Task by TaskID
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = delegate.persistentContainer.viewContext
            if let taskID = Int64(taskIDString){
                currentTask = Task.find(moc: managedObjectContext, id: taskID)
            }
        }
        
        return currentTask
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
    
    func setupPlayerItems() {
        //Dev todo, can probally work twards getting this to be conditional and only needed when tasks change
        //Setup will create all trimmed audio files from the tasks in the context.
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = delegate.persistentContainer.viewContext
        tasks = Task.fetchInContext(context: managedObjectContext)
        
        if let tasks = tasks, tasks.count > 0 {
            var items = [AVPlayerItem]()
            for task in tasks {
                
                //chime audio
                let chimePath = Bundle.main.path(forResource: task.chimeSoundFileName, ofType:nil)!
                let chimeURL = URL(fileURLWithPath: chimePath)
                let chimeAsset = AVAsset(url: chimeURL)
                let chimePlayerItem = AVPlayerItem(asset: chimeAsset)
                configureItemMetadata(item: chimePlayerItem, taskID: String(task.id))
                items.append(chimePlayerItem)
                
                //has routine bundele
                if let routineBundlePath = Bundle.main.path(forResource: "routine", ofType: "bundle"),
                    let bundle = Bundle(path: routineBundlePath),
                    let announcePath = bundle.path(forResource: task.announceSoundFileName, ofType:nil) {
                    
                    //announce audio
                    let announceURL = URL(fileURLWithPath: announcePath)
                    let announceAsset = AVAsset(url: announceURL)
                    let announcePlayerItem = AVPlayerItem(asset: announceAsset)
                    configureItemMetadata(item: announcePlayerItem, taskID: String(task.id))
                    items.append(announcePlayerItem)
                    print(announcePath)
                } else {
                    print("not found")
                }

                //music audio
                let musicPath = Bundle.main.path(forResource: task.musicSoundFileName, ofType:nil)!
                let musicURL = URL(fileURLWithPath: musicPath)
                let musicAsset = AVAsset(url: musicURL)
                let musicPlayerItem = AVPlayerItem(asset: musicAsset)
                configureItemMetadata(item: musicPlayerItem, taskID: String(task.id))
                items.append(musicPlayerItem)

            }
            
            playerQueue = AVQueuePlayer(items: items)
        }
    }
    
    //Associate AVPlayerItem to Task ID by using the commonIdentifierTitle
    func configureItemMetadata(item: AVPlayerItem, taskID: String) {
        let metadata = AVMutableMetadataItem()
        metadata.identifier = .commonIdentifierAssetIdentifier
        metadata.value = taskID as (NSCopying & NSObjectProtocol)?
        item.externalMetadata.append(metadata)
    }
    
    func routineItems() -> [AVPlayerItem] {
        var items = [AVPlayerItem]()
        for (index, url) in trimmedTaskUrls.enumerated() {

            //test tagging
            let fileNameWithExtension = url.deletingPathExtension()
            let fileName = fileNameWithExtension.lastPathComponent
            
            let chimeItem = AVPlayerItem(url: AudioManager_Old.shared().chime)
            configureItemMetadata(item: chimeItem, taskID: fileName)
            items.append(chimeItem)
            
            let nextItem = spokenItems()[index]
            configureItemMetadata(item: nextItem, taskID: fileName)
            items.append(nextItem)
            
            let trimmedItem = AVPlayerItem(url: url)
            configureItemMetadata(item: trimmedItem, taskID: fileName)
            items.append(trimmedItem)
        }
        return items
    }
    
    func playNext() {
        if let que = AudioManager.shared().playerQueue {
            que.advanceToNextItem()
        }
    }
    
    func play() {
        if let que = AudioManager.shared().playerQueue {
            que.play()
        }
    }
    
    func pause() {
        if let que = AudioManager.shared().playerQueue {
        que.pause()
        }
    }
    
    
    
    
    ////bring back //                AudioManager.shared().trim(task: "\(task.id)", desiredLength: task.length)

    
    func trim(task: String, desiredLength: Int64) {
      //  let asset = AVAsset(url: silence)
        //exportAsset(asset, fileName: "\(task).m4a", desiredLength: desiredLength)
    }
    
    func exportAsset(_ asset: AVAsset, fileName: String, desiredLength: Int64) {
        //needs fix, this function is failing to clear already wrttien files, cases duplicates.
        
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
