//
//  AudioManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/26/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class AudioManager: NSObject {

    static let manager = AudioManager()
    private var managedObjectContext: NSManagedObjectContext!
    var playerLooper: AVPlayerLooper!
    var player: AVQueuePlayer!

    //MARK: Private
    override private init() {}
    
    //MARK: Public
    public class func shared() -> AudioManager {
        return manager
    }
    
    var whiteNoise: URL {
        let path = Bundle.main.path(forResource: "white_noise", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    var space: URL {
        let path = Bundle.main.path(forResource: "space", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    var chime: URL {
        let path = Bundle.main.path(forResource: "chime", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    var complete: URL {
        let path = Bundle.main.path(forResource: "complete", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    func play(_ url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVQueuePlayer(playerItem: playerItem)
        player.play()
    }
    
    func play(_ url: URL, _ maxDuration: Double) {
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        let assetDuration = CMTimeGetSeconds(asset.duration)

        let introRange = CMTimeRangeMake(start: CMTimeMakeWithSeconds(0, preferredTimescale: 1), duration: CMTimeMakeWithSeconds(1, preferredTimescale: 1))
        let endingSecond = CMTimeRangeMake(start: CMTimeMakeWithSeconds(assetDuration - 1, preferredTimescale: 1), duration: CMTimeMakeWithSeconds(1, preferredTimescale: 1))

        let inputParams = AVMutableAudioMixInputParameters(track: asset.tracks.first! as AVAssetTrack)
        inputParams.setVolumeRamp(fromStartVolume: 0, toEndVolume: 1, timeRange: introRange)
        inputParams.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: endingSecond)

        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = [inputParams]
        playerItem.audioMix = audioMix

        player = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        player.play()

        let maxLoops = floor(maxDuration / assetDuration)
        let lastLoopDuration = maxDuration - (assetDuration * maxLoops)
        let boundaryTime = CMTimeMakeWithSeconds(lastLoopDuration, preferredTimescale: 1)
        let boundaryTimeValue = NSValue(time: boundaryTime)

        player.addBoundaryTimeObserver(forTimes: [boundaryTimeValue], queue: DispatchQueue.main) { [weak self] in
            if self?.playerLooper.loopCount == Int(maxLoops) {
                self?.player.pause()
            }
        }
    }
    
    func pause() {
        self.player.pause()
    }
        
    func setupWithManagedObjectContext(moc:NSManagedObjectContext) {
        managedObjectContext = moc
    }
    
    
}
