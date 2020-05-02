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

class RoutineViewController: PRBaseViewController {
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

    var isPaused = true
    var timeObserverToken: Any?
    var time: CMTime?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTasks()
        setupStyles()
        updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AudioManager.shared().pause()
        removeTaskObserver()
    }
    
    //MARK: Styles
    private func setupStyles() {
        for button in buttons {
            button.roundCorners()
        }
        
        //Style Airplay Button
        routerPickerView.roundCorners()
        routerPickerView.tintColor = UIColor.darkGray
        routerPickerView.backgroundColor = UIColor(hexString: "1F2123")
    }
    
    //MARK: Setup Tasks
    func setupTasks() {
        AudioManager.shared().setupTasks()
        AudioManager.shared().setupItems(items: AudioManager.shared().routineList())
        addTaskObserver()
    }
    
    //MARK: Update UX
    func updateUI() {
        updateLabels()
        updateButtons()
    }
    
    //MARK: Update Labels
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
    
    //MARK: Update Buttons
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
    
    //MARK: Select Play
    @IBAction func didSelectPlayButton() {
        if isPaused {
            resumeTask()
        } else {
            pauseTask()
        }
    }
    
    //MARK: Select Next
    @IBAction func didSelectNextButton() {
        nextTask()
    }

    //MARK: Select Restart
    @IBAction func didSelectRestartButton() {
        resetTask()
    }
    
    private func nextTask() {
        AudioManager.shared().playNext()
        self.testFeedback(6)
    }
    
    private func prevTask() {
        AudioManager.shared().play()
        self.testFeedback(6)
    }
    
    private func resumeTask() {
        isPaused = false
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        AudioManager.shared().play()
        self.testFeedback(6)
    }
    
    private func pauseTask() {
        isPaused = true
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        AudioManager.shared().pause()
        self.testFeedback(6)
    }
    
    private func resetTask() {
        updateLabels()
        self.testFeedback(6)
    }
    
    //Add Observer For Updating Task UI
    func addTaskObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = AudioManager.shared().playerQueue.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.time = time
            self?.updateUI()
        }
    }

    //Remove Observer For Updating Task UI
    func removeTaskObserver() {
        if let timeObserverToken = timeObserverToken {
            AudioManager.shared().playerQueue.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}
