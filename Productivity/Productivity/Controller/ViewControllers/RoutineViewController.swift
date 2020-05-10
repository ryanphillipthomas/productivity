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
    var routineID: Int64?
    let detector = AVRouteDetector()
    
    let playerManager = AQPlayerManager.shared
    var playeritems: [AQPlayerItemInfo] = []
        
    //MARK:View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let tasks = Task.fetchInContext(context: managedObjectContext)
        for i in 0..<tasks.count {
            let task = tasks[i]
            if let url = Bundle.main.url(forResource: task.musicSoundFileName, withExtension: nil) {
                let item = AQPlayerItemInfo(id: Int(task.id),
                                            url: url,
                                            title: task.name,
                                            albumTitle: task.itemDescription,
                                            coverImage: UIImage(named: task.imageName),
                                            startAt: 0,
                                            mediaType: .audio,
                                            artist: "5 min",
                                            albumTrackNumber:"\(i+1)",
                                            albumTrackCount:"\(tasks.count)")
                playeritems.append(item)
            }
        }
        
        playerManager.delegate = self
        playerManager.setup(with: playeritems, startFrom: 0, playAfterSetup: false)
        playerManager.setCommandCenterMode(mode: .nextprev)
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
    
    //Update Labels
    private func updateLabels() {
        if let currentTask = currentTask {
            currentRoutineNameLabel.text = currentTask.name
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
    }
    
    //Select Next
    @IBAction func didSelectNextButton() {
        playerManager.next()
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
    }
    
    // MARK: helpers
    fileprivate func setPlayPauseButtonImage(_ status: AQPlayerStatus) {
        switch status {
        case .loading, .none:
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        case .readyToPlay, .paused:
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
        case .playing:
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            
        case .failed:
            playPauseButton.setImage(UIImage(systemName: "exclamationmark.circle.fill"), for: .normal)
        }
    }
}

extension RoutineViewController: AQPlayerDelegate {
    func aQPlayerManager(_ playerManager: AQPlayerManager, progressDidUpdate percentage: Double) {
        self.taskTimeLeftLabel.text = String().timeString(second: (playerManager.duration - playerManager.currentTime))
    }
    
    func aQPlayerManager(_ playerManager: AQPlayerManager, itemDidChange itemIndex: Int) {
        currentRoutineNumberLabel.text = "\(itemIndex + 1) of \(playeritems.count)"
        nextButton.isEnabled = itemIndex < self.playeritems.count - 1
        updateUI()
    }
    
    func aQPlayerManager(_ playerManager: AQPlayerManager, statusDidChange status: AQPlayerStatus) {
        setPlayPauseButtonImage(status)
    }
    
    func getCoverImage(_ player: AQPlayerManager, _ callBack: @escaping (UIImage?) -> Void) {
        //update
    }
}
