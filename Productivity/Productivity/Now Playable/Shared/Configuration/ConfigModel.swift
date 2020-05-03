/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`ConfigModel` is the data model containing the configuration to use for playback.
*/

import Foundation
import MediaPlayer
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ConfigModel {
    
    static var shared: ConfigModel!
    
    // The platform-specific customization of the NowPlayable protocol.
    
    let nowPlayableBehavior: NowPlayable
    
    // The data model describing the configuration to use for playback.
    
    var allowsExternalPlayback: Bool
    var assets: [ConfigAsset] = []
    var commandCollections: [ConfigCommandCollection] = []
    
    // Initialize a new configuration data model.
    
    init(nowPlayableBehavior: NowPlayable) {
        
        guard ConfigModel.shared == nil else { fatalError("ConfigModel must be a singleton") }
        
        self.nowPlayableBehavior = nowPlayableBehavior
        self.allowsExternalPlayback = false
        self.assets = defaultAssets
        self.commandCollections = defaultCommandCollections
        
        ConfigModel.shared = self
    }
    
}

extension ConfigModel {
    
    // Create the assets with synthesized metadata.
    
    fileprivate var defaultAssets: [ConfigAsset] {
        
        // Find the audio files in the app bundle.
        let song1URL = Bundle.main.url(forResource: "1-hour-and-20-minutes-of-silence", withExtension: ".mp3")!
        let song2URL = Bundle.main.url(forResource: "Song 1", withExtension: ".m4a")!
        let song3URL = Bundle.main.url(forResource: "Song 2", withExtension: ".m4a")!
        let song4URL = Bundle.main.url(forResource: "Song 3", withExtension: ".m4a")!
        let song5URL = Bundle.main.url(forResource: "space", withExtension: ".wav")!
        let song6URL = Bundle.main.url(forResource: "tick", withExtension: ".wav")!
        
        let song7URL = Bundle.main.url(forResource: "1-minute-of-silence", withExtension: ".mp3")!

        
        
        
        let videoURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
        
        // Create metadata.
        
        let metadatas: [NowPlayableStaticMetadata] = [
            
            NowPlayableStaticMetadata(assetURL: song1URL,
                                mediaType: .audio,
                                isLiveStream: false,
                                title: "Feed Pets",
                                artist: "1 of 7 - 5 min",
                                artwork: artworkNamed("Song 1"),
                                albumArtist: "Song 1",
                                albumTitle: "Feed Kitty & Oliver 2 Scoops Of Chicken"),
            
            NowPlayableStaticMetadata(assetURL: song2URL,
                                mediaType: .audio,
                                isLiveStream: false,
                                title: "Coffee",
                                artist: "2 of 7 - 4 min",
                                artwork: artworkNamed("Song 2"),
                                albumArtist: "Song 1",
                                albumTitle: "Enjoy a fresh cup and start the day off right!"),
            
            NowPlayableStaticMetadata(assetURL: song3URL,
                                mediaType: .audio,
                                isLiveStream: false,
                                title: "Read",
                                artist: "3 of 7 - 14 min",
                                artwork: artworkNamed("Song 3"),
                                albumArtist: "Song 1",
                                albumTitle: "No News, Social or Email!!"),
            
            
            NowPlayableStaticMetadata(assetURL: song4URL,
                                mediaType: .audio,
                                isLiveStream: false,
                                title: "Bathroom",
                                artist: "4 of 7 - 7 min",
                                artwork: artworkNamed("Song 1"),
                                albumArtist: "Song 1",
                                albumTitle: "Wash Face, Use Restroom"),
            
            
            NowPlayableStaticMetadata(assetURL: song5URL,
                                 mediaType: .audio,
                                 isLiveStream: false,
                                 title: "Meditate",
                                 artist: "5 of 7 - 7 min",
                                 artwork: artworkNamed("Song 2"),
                                 albumArtist: "Song 1",
                                 albumTitle: "Use the Calm app and meditate"),
            
            
            NowPlayableStaticMetadata(assetURL: song6URL,
                                 mediaType: .audio,
                                 isLiveStream: false,
                                 title: "Journel",
                                 artist: "6 of 7 - 8 min",
                                 artwork: artworkNamed("Song 3"),
                                 albumArtist: "Song 1",
                                 albumTitle: "Wash Face, Use Restroom"),
            
            
            NowPlayableStaticMetadata(assetURL: song7URL,
                                 mediaType: .audio,
                                 isLiveStream: false,
                                 title: "Workout",
                                 artist: "7 of 7 15 min",
                                 artwork: artworkNamed("Song 1"),
                                 albumArtist: "Song 1",
                                 albumTitle: "Wash Face, Use Restroom"),

//            NowPlayableStaticMetadata(assetURL: videoURL,
//                                mediaType: .video,
//                                isLiveStream: false,
//                                title: "Bip Bop, The Movie",
//                                artist: nil,
//                                artwork: nil,
//                                albumArtist: nil,
//                                albumTitle: nil),
        ]
        
        return metadatas.map { ConfigAsset(metadata: $0) }
    }
    
    // Create the command collections, and enable a default set of commands.
    
    fileprivate var defaultCommandCollections: [ConfigCommandCollection] {
        
        // Arrange the commands into collections.
        
        let collection1 = [ConfigCommand(.pause, "Pause"),
                           ConfigCommand(.play, "Play"),
                           ConfigCommand(.stop, "Stop"),
                           ConfigCommand(.togglePausePlay, "Play/Pause")]
        let collection2 = [ConfigCommand(.nextTrack, "Next Track"),
                           ConfigCommand(.previousTrack, "Previous Track"),
                           ConfigCommand(.changeRepeatMode, "Repeat Mode"),
                           ConfigCommand(.changeShuffleMode, "Shuffle Mode"),
                           ConfigCommand(.changePlaybackPosition, "Playback Position")]
        let collection3 = [ConfigCommand(.changePlaybackRate, "Playback Rate"),
                           ConfigCommand(.seekBackward, "Seek Backward"),
                           ConfigCommand(.seekForward, "Seek Forward"),
                           ConfigCommand(.skipBackward, "Skip Backward"),
                           ConfigCommand(.skipForward, "Skip Forward"),
                           ConfigCommand(.changePlaybackPosition, "Playback Position")]
        let collection4 = [ConfigCommand(.rating, "Rating"),
                           ConfigCommand(.like, "Like"),
                           ConfigCommand(.dislike, "Dislike")]
        let collection5 = [ConfigCommand(.bookmark, "Bookmark")]
        let collection6 = [ConfigCommand(.enableLanguageOption, "Enable Language Option"),
                           ConfigCommand(.disableLanguageOption, "Disable Language Option")]
        
        // Create the collections.
        
        let registeredCommands = nowPlayableBehavior.defaultRegisteredCommands
        let disabledCommands = nowPlayableBehavior.defaultDisabledCommands
        
        let commandCollections = [
            ConfigCommandCollection("Playback", commands: collection1, registered: registeredCommands, disabled: disabledCommands),
            ConfigCommandCollection("Navigating Between Tracks", commands: collection2, registered: registeredCommands, disabled: disabledCommands),
//            ConfigCommandCollection("Navigating Track Contents", commands: collection3, registered: registeredCommands, disabled: disabledCommands),
            ConfigCommandCollection("Rating Media Items", commands: collection4, registered: registeredCommands, disabled: disabledCommands),
            ConfigCommandCollection("Bookmarking Media Items", commands: collection5, registered: registeredCommands, disabled: disabledCommands),
            ConfigCommandCollection("Enabling Language Options", commands: collection6, registered: registeredCommands, disabled: disabledCommands)
        ]
        
        return commandCollections
    }
    
    // Create artwork.
    
    private func artworkNamed(_ imageName: String) -> MPMediaItemArtwork {
        
        #if os(macOS)
        let image = NSImage(named: imageName)!
        #else
        let image = UIImage(named: imageName)!
        #endif
        
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }
    
}

