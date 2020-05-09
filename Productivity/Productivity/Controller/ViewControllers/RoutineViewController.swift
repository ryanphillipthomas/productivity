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
    var parts: [[String]] = [[""]]

    var isPaused = true
    var time: CMTime?
    
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
       parts = [["Feed Pets","song_1.m4a", "5 min", "Give Kitty and Oliver, dry chicken 2 scoops."],
                     ["Coffee","song_2.m4a", "4 min", "Have a fresh cup of coffee"],
                     ["Read","song_3.m4a", "14 min",  "No news, social or email!"],
                     ["Bathroom","song_1.m4a", "7 min", "Grab something good to read!"],
                     ["Meditate","song_2.m4a", "7 min", "Use the Calm app and Meditate"],
                     ["Journal","song_3.m4a", "8 min", "Use the DayOne app and Journal"],
                     ["Workout","song_1.m4a", "15 min", "Use the Seven app and Workout"]]

        for i in 0..<parts.count {
            if let url = Bundle.main.url(forResource: "\(parts[i][1])", withExtension: nil) {
                let item = AQPlayerItemInfo(id: i, url: url, title: "\(parts[i][0])", albumTitle: "\(parts[i][3])", coverImage: UIImage(named: "album"), startAt: 0, mediaType: .audio, artist: "\(parts[i][2])", albumTrackNumber:"\(i+1)", albumTrackCount:"\(parts.count)")
                playeritems.append(item)
            }
        }
    }
    
    //MARK: Update
    
    //Update UI
    func updateUI() {
        updateLabels()
        updateButtons()
    }
    
    //Update Labels
    private func updateLabels() {
        if let currentTask = AudioManager.shared().currentTask {
            let totalTasks = Task.countInContext(context: managedObjectContext)
            currentRoutineNumberLabel.text = "\(currentTask.order + 1) of \(totalTasks)"
            currentRoutineNameLabel.text = currentTask.name
            currentRoutineNumberLabel.textColor = UIColor(hexString: currentTask.colorValue)
            currentRoutineNameLabel.textColor = UIColor(hexString: currentTask.colorValue)
            taskTimeLeftLabel.textColor = UIColor(hexString: currentTask.colorValue)
            
            if let time = time {
                let taskTimeLeft = Int(Double(currentTask.length) - time.seconds)
                taskTimeLeftLabel.text = String().timeString(second: TimeInterval(taskTimeLeft))
            }
        }
    }
    
    //Update Buttons
    private func updateButtons() {
        //Add Aiplay if its missing
        if !buttonsStackView.arrangedSubviews.contains(routerPickerView) {
            buttonsStackView.insertArrangedSubview(routerPickerView, at: 1)
        }
        
        //Apply Tint Color to all Buttons
        if let currentTask = AudioManager.shared().currentTask {
            routerPickerView.activeTintColor = UIColor(hexString: currentTask.colorValue)
            
            for button in buttons {
                button.tintColor = UIColor(hexString: currentTask.colorValue)
            }
        }
    }
    
    //MARK: Actions
    
    //Select Play
    @IBAction func didSelectPlayButton() {
        if isPaused {
            resumeTask()
        } else {
            pauseTask()
        }
    }
    
    private func resumeTask() {
        isPaused = false
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        self.testFeedback(6)
    }
    
    private func pauseTask() {
        isPaused = true
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.testFeedback(6)
    }
    
    //Select Next
    @IBAction func didSelectNextButton() {
        nextTask()
    }
    
    private func nextTask() {
        self.testFeedback(2)
    }

    //Select Restart
    @IBAction func didSelectRestartButton() {
        resetTask()
    }
    
    private func resetTask() {
        updateLabels()
        self.testFeedback(1)
    }
    
    //Select Previous
    private func prevTask() {
        self.testFeedback(3)
    }
}