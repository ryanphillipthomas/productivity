//
//  AQPlayerManager.swift
//  AQPlayer
//
//  Created by Ahmad Amri on 2/28/19.
//  Copyright © 2019 Amri. All rights reserved.
//

import AVFoundation
import MediaPlayer

public final class AQPlayerManager: NSObject {
    
    static public let shared = AQPlayerManager()
    
    public var delegate: AQPlayerDelegate?
    
    fileprivate let commandCenter = MPRemoteCommandCenter.shared()
    fileprivate var qPlayer: AQQueuePlayer?
    fileprivate var qPlayerItems: [AQPlayerItem] = []
    fileprivate var timer: Timer?
    fileprivate var isSessionSetup = false
    var qPlayerCategoryOptions: AVAudioSession.CategoryOptions = []
    var qPlayerActiveOptions : AVAudioSession.SetActiveOptions = []
    var qPlayerPolicy : AVAudioSession.RouteSharingPolicy = .longForm

    public var playerStatus: AQPlayerStatus {
        return self.status
    }
    public var playbackRates: [Float] = Defaults.playbackRates
    public var rate: Float = 1.0
    public var skipIntervalInSeconds = Defaults.skipIntervalInSeconds {
        didSet {
            self.commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: self.skipIntervalInSeconds)]
            self.commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: self.skipIntervalInSeconds)]
        }
    }
    fileprivate var status: AQPlayerStatus = .none {
        didSet {
            self.delegate?.aQPlayerManager(self, statusDidChange: status)
        }
    }
    public var currentItemInfo: AQPlayerItemInfo! {
        return (self.qPlayer?.currentItem as? AQPlayerItem)?.itemInfo ?? nil
    }
    public var currentItemIndex: Int {
       return (self.qPlayer?.currentItem as? AQPlayerItem)?.index ?? -1
    }
    public var currentTime: TimeInterval {
        return self.qPlayer?.currentItem?.currentTime().seconds ?? 0
    }
    public var duration: TimeInterval {
        return self.qPlayer?.currentItem?.asset.duration.seconds ?? 0
    }
    public var percentage: Double {
        guard let duration = qPlayer?.currentItem?.asset.duration else {
            return 0.0
        }
        
        let currentTime = self.qPlayer?.currentTime() ?? .zero
        return currentTime.seconds / duration.seconds
    }
    
    /// Check for headphones, used to handle audio route change
    private var headphonesConnected: Bool = false
    
    public override init() {
        super.init()
        
        self.setupRemoteControl()
        self.setupNotifications()
    }
    
    deinit {
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.clean()
    }
    
    public func clean() {
        qPlayer?.pause()
        qPlayer?.removeAllItems()
        qPlayer = nil
        qPlayerItems.removeAll()
    }
    
    public func setup(with items: [AQPlayerItemInfo], startFrom: Int = 0, playAfterSetup: Bool = false) {
        
        self.clean()
        self.status = .loading
        

        guard items.count > 0 else {
            return
        }
        
        // init new items
        for item in items {
            guard let url = item.url else {
                debugPrint("missing item url")
                continue
            }
            
            let asset = AVAsset(url: url)
            let item = AQPlayerItem(asset: asset, index: self.qPlayerItems.count, itemInfo: item)
            qPlayerItems.append(item)
        }
        
        // validate startFrom item index
        var toDrop = startFrom
        if startFrom < 0 {
            toDrop = 0
        }
        if startFrom >= items.count {
            toDrop = items.count - 1
        }
        
        
        // init the AQQueuePlayer
        qPlayer = AQQueuePlayer(items: Array(qPlayerItems.dropFirst(toDrop)))
        qPlayer?.allowsExternalPlayback = false
        
        let keysToObserve = ["currentItem","rate"]
        for key in keysToObserve {
            qPlayer?.addObserver(self, forKeyPath: key, options: [.new, .old, .initial], context: nil)
        }
        
        if playAfterSetup {
            self.play()
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        debugPrint(String(describing: keyPath))        
       
        
        guard let item = self.qPlayer?.currentItem as? AQPlayerItem else {
            self.status = .none
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
            return
        }
       
        switch keyPath {
        case "currentItem":
            self.status = .loading
            qPlayer?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                self.updateNowPlaying()
                self.delegate?.aQPlayerManager(self, itemDidChange: item.index)
                self.updateProgress()
            break
            
        case "status":
            if let item = object as? AVPlayerItem {
                switch (item.status) {
                case .unknown:
                    self.status = .none
                case .readyToPlay:
                    if qPlayer?.rate ?? 0 > 0 {
                        self.status = .playing
                    } else {
                        self.status = .readyToPlay
                    }
                case .failed:
                    self.status = .failed
                }
            }
            break
        case "rate":
            if let player = self.qPlayer {
                self.status = player.rate > 0 ? .playing : .paused
            } else {
                self.status = .none
            }
            break
       
        default:
            debugPrint("KeyPath: \(String(describing: keyPath)) not handeled in observer")
        }
       
    }
    
    public func setPlayerCategoryOptions(options: AVAudioSession.CategoryOptions) {
            qPlayerCategoryOptions = options
    }
    
    public func setPlayerActiveOptions(options: AVAudioSession.SetActiveOptions) {
        qPlayerActiveOptions = options
    }
    
    public func setPlayerPolicy(policy: AVAudioSession.RouteSharingPolicy) {
        qPlayerPolicy = policy
    }
    
    public func setCommandCenterMode(mode: AQRemoteControlMode) {
            commandCenter.skipBackwardCommand.isEnabled = mode == .skip
            commandCenter.skipForwardCommand.isEnabled = mode == .skip
        
            commandCenter.nextTrackCommand.isEnabled = mode == .nextprev
            commandCenter.previousTrackCommand.isEnabled = mode == .nextprev
        
            commandCenter.seekForwardCommand.isEnabled = false
            commandCenter.seekBackwardCommand.isEnabled = false
            commandCenter.changePlaybackRateCommand.isEnabled = false
    }
    
    fileprivate func setupAudioSession() {
        // activate audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default , policy: qPlayerPolicy, options: qPlayerCategoryOptions)
            try AVAudioSession.sharedInstance().setActive(true, options: qPlayerActiveOptions)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            isSessionSetup = true
        } catch {
            print("Activate AVAudioSession failed.")
        }
    }

    @objc fileprivate func updateProgress() {
        guard let delegate = self.delegate else {
            return
        }
        
        guard let duration = qPlayer?.currentItem?.asset.duration else {
            return
        }
        
        if self.status != .playing, qPlayer?.status == .readyToPlay, qPlayer?.rate ?? 0 > 0 {
            self.status = .playing
        }
        let currentTime = self.qPlayer?.currentTime() ?? .zero
        let percentage = currentTime.seconds / duration.seconds
        delegate.aQPlayerManager(self, progressDidUpdate: percentage)
        
    }
    
    
    
    
    fileprivate func updateNowPlaying(time: TimeInterval? = nil) {
        guard self.duration > 0.0 else {
            return
        }
        
        var nowPlayingInfo:[String: Any]? = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if nowPlayingInfo == nil {
            nowPlayingInfo = [String: Any]()
        }
        
        guard let item = self.qPlayer?.currentItem as? AQPlayerItem else {
            return
        }
        
        
        // init metadata
        nowPlayingInfo?[MPMediaItemPropertyTitle] = item.itemInfo.title
        nowPlayingInfo?[MPMediaItemPropertyArtist] = item.itemInfo.artist
        nowPlayingInfo?[MPMediaItemPropertyAlbumArtist] = item.itemInfo.albumArtist
        nowPlayingInfo?[MPMediaItemPropertyAlbumTitle] = item.itemInfo.albumTitle
        nowPlayingInfo?[MPMediaItemPropertyGenre] = "genre"
        nowPlayingInfo?[MPMediaItemPropertyComposer] = "composer"
        nowPlayingInfo?[MPMediaItemPropertyAlbumTrackNumber] = item.itemInfo.albumTrackNumber
        nowPlayingInfo?[MPMediaItemPropertyAlbumTrackCount] = item.itemInfo.albumTrackCount
        nowPlayingInfo?[MPNowPlayingInfoPropertyMediaType] = item.itemInfo.mediaType.rawValue
        nowPlayingInfo?[MPNowPlayingInfoPropertyIsLiveStream] = false
        nowPlayingInfo?[MPMediaItemPropertyPersistentID] = String(item.itemInfo.id)
        nowPlayingInfo?[MPMediaItemPropertyDiscCount] = item.itemInfo.albumTrackCount
        nowPlayingInfo?[MPMediaItemPropertyDiscNumber] = item.itemInfo.albumTrackNumber
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackQueueIndex] = item.itemInfo.albumTrackNumber
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackQueueCount] = item.itemInfo.albumTrackCount
        nowPlayingInfo?[MPNowPlayingInfoPropertyChapterNumber] = item.itemInfo.albumTrackNumber
        nowPlayingInfo?[MPNowPlayingInfoPropertyChapterCount] = item.itemInfo.albumTrackCount



        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (time == nil) ? self.qPlayer?.currentTime().seconds ?? 0 : time
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = self.duration
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = self.qPlayer?.rate ?? 0
        
        
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        self.updateMediaItemArtwork()
    }
    fileprivate func updateMediaItemArtwork() {
        // set cover image
        if let item = self.qPlayer?.currentItem as? AQPlayerItem, let image = item.itemInfo.coverImage {
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
        } else {
            self.delegate?.getCoverImage(self, { (coverImage) in
                if let image = coverImage {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
                }
            })
        }
    }
}

// MARK: Audio control methods
extension AQPlayerManager {
    public func playOrPause() -> AQPlayerStatus {
        guard qPlayer != nil, qPlayer?.currentItem != nil else {
            return .none
        }
        
        switch self.status {
            case .loading, .none:
                return .loading
        case .failed:
            return .failed
            
            
            case .readyToPlay, .paused:
                self.play()
                return .playing
            case .playing:
                self.pause()
                return.paused
        }
    }
    
    public func play() {
        guard qPlayer != nil, qPlayer?.currentItem != nil else {
            return
        }
        
        if !isSessionSetup {
            setupAudioSession()
        }
        
        self.qPlayer?.playImmediately(atRate: self.rate)
        //self.status = .playing
        self.updateProgress()
        self.updateNowPlaying()
        
        //update progress periodically
        if self.timer == nil {
            self.timer = Timer(timeInterval: Defaults.progressTimerInterval, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer!, forMode: .common)
        }
        
    }
    
    public func pause() {
        guard qPlayer != nil else {
            return
        }
        
        qPlayer?.pause()
        self.status = .paused
        timer?.invalidate()
        timer = nil
        updateProgress()
    }
    
    public func seek(toPercent: Double) {
        let duration = qPlayer?.currentItem?.duration ?? .zero
        let jumpToSec = duration.seconds * toPercent
        
        self.seek(toTime: jumpToSec)
    }
    
    public func seek(toTime: TimeInterval) {
        var playAfterSeek = false
        if self.status == .playing {
            self.pause()
            playAfterSeek = true
        }
        
        self.status = .loading
        self.qPlayer?.seek(to: CMTime(seconds: toTime, preferredTimescale: Defaults.preferredTimescale) , completionHandler: { (value) in
            if playAfterSeek {
                self.play()
            }
        })
    }
    
    public func next() {
        guard qPlayer != nil, let index = self.qPlayer?.currentIndex, index < self.qPlayerItems.count - 1 else {
            return
        }
        
       self.goTo(index + 1)
    }
    
    public func previous() {
        guard qPlayer != nil, let index = self.qPlayer?.currentIndex, index > 0 else {
            return
        }
        
        self.goTo(index - 1)
    }
    
    public func goTo(_ index: Int) {
        guard qPlayer != nil, index >= 0, index < self.qPlayerItems.count else {
            return
        }
        
        var playAfterGo = false
        if self.status == .playing {
            self.pause()
            playAfterGo = true
        }
        
        qPlayer?.goTo(index: index, with: self.qPlayerItems)
        
        if playAfterGo {
            self.play()
        }
        
    }
    
    public func skipForward() {
        self.pause()
        let currentTime = self.qPlayer?.currentTime() ?? .zero
        var jumpToSec = currentTime + CMTime(seconds: self.skipIntervalInSeconds, preferredTimescale: Defaults.preferredTimescale) // dalta
        let duration = qPlayer?.currentItem?.duration ?? .zero
        
        if jumpToSec > duration {
            jumpToSec = duration
        }
        
        guard jumpToSec >= .zero else {
            return
        }
        
        self.qPlayer?.seek(to: jumpToSec, completionHandler: { (value) in
            self.play()
        })
    }
    
    public func skipBackward() {
        self.pause()
        let currentTime = self.qPlayer?.currentTime() ?? .zero
        var jumpToSec = currentTime - CMTime(seconds: self.skipIntervalInSeconds, preferredTimescale: Defaults.preferredTimescale) // dalta
        // let duration = qPlayer?.currentItem?.duration ?? .zero
        
        if jumpToSec < .zero {
            jumpToSec = .zero
        }
        
        guard jumpToSec >= .zero else {
            return
        }
        
        self.qPlayer?.seek(to: jumpToSec, completionHandler: { (value) in
            self.play()
        })
    }
    
    public func changeToNextRate() -> Float {
        guard let index = self.playbackRates.lastIndex(of: self.rate) else {
            self.rate = 1.0
            return 1.0
        }
        
        var newRateIndex = index + 1
        if newRateIndex == playbackRates.count {
            newRateIndex = 0
        }
        
        self.rate = self.playbackRates[newRateIndex]
        self.qPlayer?.rate = self.rate
        
        return self.rate
    }
}

// Remote Control Setup
extension AQPlayerManager {
    fileprivate func setupRemoteControl() {
        
        self.setCommandCenterMode(mode: Defaults.commandCenterMode)
        
        // MARK: Remote Commands handlers
        
        // play , pause , stop
        commandCenter.togglePlayPauseCommand.addTarget(handler: {[weak self]  (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("togglePlayPauseCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            if strongSelf.playOrPause() != .none {
                return .success
            } else {
                return .commandFailed
            }
        })
        commandCenter.playCommand.addTarget { [weak self] event in
            debugPrint("playCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.play()
            return checkSatatus(strongSelf)
        }
        commandCenter.pauseCommand.addTarget { [weak self] event in
            debugPrint("pauseCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.pause()
           return checkSatatus(strongSelf)
        }
        commandCenter.stopCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("stopCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.pause()
            return checkSatatus(strongSelf)
        })
        
        // next , prev
        commandCenter.nextTrackCommand.addTarget( handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("nextTrackCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.next()
            return checkSatatus(strongSelf)
        })
        commandCenter.previousTrackCommand.addTarget( handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("previousTrackCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.previous()
            return checkSatatus(strongSelf)
        })
        
        // seek fwd , seek bwd
        commandCenter.seekForwardCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("seekForwardCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            debugPrint("Seek forward ")
            return .commandFailed
        })
        commandCenter.seekBackwardCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("seekBackwardCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            debugPrint("Seek backward ")
            return .commandFailed
        })
       
        // skip fwd , skip bwd
        commandCenter.skipForwardCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("skipForwardCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.skipForward()
            return checkSatatus(strongSelf)
        })
        commandCenter.skipBackwardCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("skipBackwardCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.skipBackward()
            return checkSatatus(strongSelf)
        })

        // playback rate
        commandCenter.changePlaybackRateCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("changePlaybackRateCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            debugPrint("Change Rate ")
            return .commandFailed
        })
        
        // seek to position
        commandCenter.changePlaybackPositionCommand.addTarget(handler: {[weak self] ( event) -> MPRemoteCommandHandlerStatus in
            debugPrint("changePlaybackPositionCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            //   var playAfterSeek = strongSelf.status == .playing
            // strongSelf.pause()
            
            let e = event as! MPChangePlaybackPositionCommandEvent
            strongSelf.updateNowPlaying(time: e.positionTime)
            strongSelf.seek(toTime: e.positionTime)
            return checkSatatus(strongSelf)
            
        })
        
        // check status and return MPRemoteCommandHandlerStatus
        func checkSatatus(_ strongSelf: AQPlayerManager) -> MPRemoteCommandHandlerStatus {
            if strongSelf.status != .none {
                return .success
            } else {
                return .commandFailed
            }
        }
        
        // Enters Background
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil, using: {[weak self] (_) in
            debugPrint("willResignActiveNotification")
            guard let strongSelf = self else {return}
            
            strongSelf.updateNowPlaying()
        })
    }
    
    // MARK: - Notifications
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    // MARK: - Responding to Route Changes
    
    private func checkHeadphonesConnection(outputs: [AVAudioSessionPortDescription]) {
        for output in outputs where output.portType == .headphones {
            headphonesConnected = true
            break
        }
        headphonesConnected = false
    }
    
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else { return }
        
        switch reason {
        case .newDeviceAvailable:
            checkHeadphonesConnection(outputs: AVAudioSession.sharedInstance().currentRoute.outputs)
        case .oldDeviceUnavailable:
            guard let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription else { return }
            checkHeadphonesConnection(outputs: previousRoute.outputs);
            DispatchQueue.main.async { self.headphonesConnected ? () : self.pause() }
        default: break
        }
    }
    
    
    // MARK: - Responding to Interruptions
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
        case .began:
            DispatchQueue.main.async { self.pause() }
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { break }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            DispatchQueue.main.async { options.contains(.shouldResume) ? self.play() : self.pause() }
        @unknown default:
            break
        }
    }
}

public enum AQRemoteControlMode {
    case skip
    case nextprev
}

// default config values
final class Defaults {
    static let progressTimerInterval: TimeInterval = 1.0
    static let preferredTimescale: CMTimeScale = 1000
    static let skipIntervalInSeconds: TimeInterval = 15.0
    static let playbackRates: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    static let commandCenterMode = AQRemoteControlMode.nextprev
}
