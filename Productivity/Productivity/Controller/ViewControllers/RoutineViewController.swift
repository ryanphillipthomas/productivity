//
//  RoutineViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AQPlayer
import IntentsUI

class RoutineViewController: PRBaseViewController {
    
    //MARK: Properties
    @IBOutlet var buttons: [UIButton]!

    @IBOutlet weak var resetPrevButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!

    @IBOutlet weak var currentRoutineNumberLabel: UILabel!
    @IBOutlet weak var currentRoutineNameLabel: UILabel!
    @IBOutlet weak var taskTimeLeftLabel: UILabel!
    
    let routerPickerView = AVRoutePickerView()
    var routineID: Int64!
    let detector = AVRouteDetector()
    
    let playerManager = AQPlayerManager.shared
    var playeritems: [AQPlayerItemInfo] = []
        
    //MARK:View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoutine()
        setupTasks()
        setupStyles()
        updateUI()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: Setup
    
    //Setup Styles
    private func setupStyles() {
        for button in buttons {
            button.roundCorners()
        }
        
        //Style Airplay Button
        routerPickerView.roundCorners()
        routerPickerView.tintColor = UIColor.darkGray
        routerPickerView.backgroundColor = UIColor(hexString: "1F2123")
    }
    
    //Setup Tasks
    func setupTasks() {
        // task title , audio file, task description
        let tasks = Task.fetchInContextForRoutine(context: managedObjectContext, routineID: routineID)
        for i in 0..<tasks.count {
            let task = tasks[i]
                //Chime Sound
            let chime_url = Bundle.main.url(forResource: task.chimeSoundFileURL, withExtension: nil)
            let chime = AQPlayerItemInfo(id: Int(task.id),
                                        url: chime_url,
                                        title: task.name,
                                        albumTitle: task.itemDescription,
                                        coverImage: UIImage(named: task.imageName),
                                        startAt: 0,
                                        mediaType: .audio,
                                        artist: "5 min",
                                        albumTrackNumber:"\(i+1)",
                                        albumTrackCount:"\(tasks.count)")
            playeritems.append(chime)
            
            //Announcement
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let announcement_url = documentsDirectory.appendingPathComponent(task.announceSoundFileURL)
            let announcement = AQPlayerItemInfo(id: Int(task.id),
                                        url: announcement_url,
                                        title: task.name,
                                        albumTitle: task.itemDescription,
                                        coverImage: UIImage(named: task.imageName),
                                        startAt: 0,
                                        mediaType: .audio,
                                        artist: "5 min",
                                        albumTrackNumber:"\(i+1)",
                                        albumTrackCount:"\(tasks.count)")
            playeritems.append(announcement)
            
            //Sound File
            
            let fileName = "\(task.id).m4a"
            let sound_url = documentsDirectory.appendingPathComponent(fileName)
            
            let sound = AQPlayerItemInfo(id: Int(task.id),
                                        url: sound_url,
                                        title: task.name,
                                        albumTitle: task.itemDescription,
                                        coverImage: UIImage(named: task.imageName),
                                        startAt: 0,
                                        mediaType: .audio,
                                        artist: "5 min",
                                        albumTrackNumber:"\(i+1)",
                                        albumTrackCount:"\(tasks.count)")
            playeritems.append(sound)
            
            
            if i == tasks.count - 1 {
                //Complete File
                let complete_url = Bundle.main.url(forResource: "complete.wav", withExtension: nil)!
                let sound = AQPlayerItemInfo(id: Int(task.id),
                                            url: complete_url,
                                            title: task.name,
                                            albumTitle: task.itemDescription,
                                            coverImage: UIImage(named: task.imageName),
                                            startAt: 0,
                                            mediaType: .audio,
                                            artist: "5 min",
                                            albumTrackNumber:"\(i+1)",
                                            albumTrackCount:"\(tasks.count)")
                playeritems.append(sound)
            }
        }
        playerManager.delegate = self
      
// Uncomment to allow for mixing with other audio
//        playerManager.setPlayerCategoryOptions(options: [.mixWithOthers, .duckOthers])
//        playerManager.setPlayerActiveOptions(options: [])
//        playerManager.setPlayerPolicy(policy: .default)
        
        
        playerManager.setCommandCenterMode(mode: .nextprev)
        playerManager.setup(with: playeritems, startFrom: 0, playAfterSetup: true)
    }
    
    func setupRoutine() {
        setupIntentsForSiri()
    }
    
    private func setupIntentsForSiri() {
       let actionIdentifier = "com.ryanphillipthomas.runRoutine"
       let activity = NSUserActivity(activityType: actionIdentifier)
        if let routine = currentRoutine {
            let title = "Run \(routine.name)"
            activity.title = title
            activity.userInfo = ["id": routine.id]
            activity.suggestedInvocationPhrase = title
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = String(routine.id)
        }
        
       view.userActivity = activity
       activity.becomeCurrent()
    }
    
    func displaySiriShortcutPopup() {
        if #available(iOS 12.0, *) {
            guard let userActivity = view.userActivity else { return }
            let shortcut = INShortcut(userActivity: userActivity)
            let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: Update
    
    //Update UI
    func updateUI() {
        updateLabels()
        updateButtons()
    }
    
    //MARK: Get Current Task
    var currentTask: Task? {
        var currentTask: Task?
        if let itemInfo = playerManager.currentItemInfo {
            //Fetch the Task by TaskID
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = delegate.persistentContainer.viewContext
            currentTask = Task.find(moc: managedObjectContext, id: Int64(itemInfo.id))
        }
        
        return currentTask
    }
    
    //MARK: Get Current Routine
    var currentRoutine: Routine? {
        var currentRoutine: Routine?
        if let routineID = routineID {
            //Fetch the Task by TaskID
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = delegate.persistentContainer.viewContext
            currentRoutine = Routine.find(moc: managedObjectContext, id: Int64(routineID))
        }
        
        return currentRoutine
    }
    
    //Update Labels
    private func updateLabels() {
        if let currentTask = currentTask {
            currentRoutineNumberLabel.text = "\(currentTask.order + 1) of \(Task.countInContextForRoutineID(routineID, context: managedObjectContext))"
            currentRoutineNameLabel.text = currentTask.name
            taskTimeLeftLabel.text = String().timeString(second: (playerManager.duration - playerManager.currentTime))
            currentRoutineNumberLabel.textColor = UIColor(hexString: currentTask.colorValue)
            currentRoutineNameLabel.textColor = UIColor(hexString: currentTask.colorValue)
            taskTimeLeftLabel.textColor = UIColor(hexString: currentTask.colorValue)
        }
    }
    
    //Update Buttons
    private func updateButtons() {
        //Add Aiplay if its missing
        if !buttonsStackView.arrangedSubviews.contains(routerPickerView) {
            buttonsStackView.insertArrangedSubview(routerPickerView, at: 1)
        }
        
        //Apply Tint Color to all Buttons
        if let currentTask = currentTask {
            routerPickerView.activeTintColor = UIColor(hexString: currentTask.colorValue)
            
            for button in buttons {
                button.tintColor = UIColor(hexString: currentTask.colorValue)
            }
        }
    }
    
    //MARK: Actions
    
    //Select Play
    @IBAction func didSelectPlayButton() {
        let status = playerManager.playOrPause()
        setPlayPauseButtonImage(status)
        generateButtonFeedback(6)
    }
    
    //Select Next
    @IBAction func didSelectNextButton() {
        playerManager.next()
        generateButtonFeedback(2)
    }

    //Select Restart
    @IBAction func didSelectRestartButton() {
        if playerManager.playerStatus == .playing {
            playerManager.seek(toTime: TimeInterval())
        } else {
            playerManager.seek(toTime: TimeInterval())
            taskTimeLeftLabel.text = String().timeString(second: (playerManager.duration - playerManager.currentTime))
            playerManager.pause()
        }
        generateButtonFeedback(1)
    }
    
    // MARK: helpers
    fileprivate func setPlayPauseButtonImage(_ status: AQPlayerStatus) {
        switch status {
        case .loading, .none:
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playPauseButton.isEnabled = false
        case .readyToPlay, .paused:
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playPauseButton.isEnabled = true
        case .playing:
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playPauseButton.isEnabled = true
        case .failed:
            playPauseButton.setImage(UIImage(systemName: "exclamationmark.circle.fill"), for: .normal)
            playPauseButton.isEnabled = false
        }
    }
}

extension RoutineViewController: AQPlayerDelegate {
    func aQPlayerManager(_ playerManager: AQPlayerManager, progressDidUpdate percentage: Double) {
        updateUI()
    }
    
    func aQPlayerManager(_ playerManager: AQPlayerManager, itemDidChange itemIndex: Int) {
        nextButton.isEnabled = itemIndex < self.playeritems.count - 1
        
        if itemIndex == playeritems.count - 1 {
            delayWithSeconds(5) {
                self.displaySiriShortcutPopup()
            }
        }
        
        updateUI()
    }
    
    func aQPlayerManager(_ playerManager: AQPlayerManager, statusDidChange status: AQPlayerStatus) {
        setPlayPauseButtonImage(status)
    }
    
    func getCoverImage(_ player: AQPlayerManager, _ callBack: @escaping (UIImage?) -> Void) {
        //update
    }
}

extension RoutineViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }
}
