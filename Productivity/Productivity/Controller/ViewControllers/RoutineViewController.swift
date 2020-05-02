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
    let detector = AVRouteDetector()

    var routineID: Int64?
    var workingObject = PRBaseWorkingObject()
    var routine: Routine?
    var tasks: [Task]?
    var taskCounter = 0
    var taskTimeLeft = 0
    
    var isPaused = true
    var timeObserverToken: Any?
    var itemContext = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoutine()
        setupTasks()
        setupStyles()
        updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AudioManager.shared().pause()
        removePeriodicTimeObserver()
    }
    
    //MARK: Styles
    private func setupStyles() {
        for button in buttons {
            button.roundCorners()
        }
    }
    
    //MARK: Setup Routine
    func setupRoutine() {
        if let routineID = routineID {
            routine = Routine.find(moc: managedObjectContext, id: routineID)
        }
    }
    
    //MARK: Setup Tasks
    func setupTasks() {
        AudioManager.shared().setupTasks()
        
        let trimmedItems = AudioManager.shared().trimmedItems()
        for item in trimmedItems {
            // Register as an observer of the player item's status property
            item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &itemContext)
        }
        
        AudioManager.shared().setupItems(items: AudioManager.shared().routineList(trimmedItems: trimmedItems))
        addPeriodicTimeObserver()
    }
    
    //MARK: Update UX
    func updateUI() {
        updateLabels()
        updateButtons()
        updateAirplayButton()
    }
    
    private func updateLabels() {
        if  let tasks = tasks, tasks.count > 0 {
            currentRoutineNumberLabel.text = "\(taskCounter + 1) of \(tasks.count)"
            currentRoutineNameLabel.text = tasks[taskCounter].name
            taskTimeLeft = Int(tasks[taskCounter].length)
            
            taskTimeLeftLabel.text = String().timeString(second: TimeInterval(taskTimeLeft))
            
            let currentTask = tasks[taskCounter]
            currentRoutineNumberLabel.textColor = UIColor(hexString: currentTask.colorValue)
            currentRoutineNameLabel.textColor = UIColor(hexString: currentTask.colorValue)
            taskTimeLeftLabel.textColor = UIColor(hexString: currentTask.colorValue)
        }
    }
    
    private func updateButtons() {
        if let tasks = tasks, tasks.count > 0 {
            for button in buttons {
                let currentTask = tasks[taskCounter]
                button.tintColor = UIColor(hexString: currentTask.colorValue)
            }
        }
    }
    
    @IBAction func didSelectPlayButton() {
        if isPaused {
            resumeTask()
        } else {
            pauseTask()
        }
    }
    
    @IBAction func didSelectNextButton() {
        nextTask()
    }

    @IBAction func didSelectRestartButton() {
        resetTask()
    }
    
    private func updateAirplayButton() {
        if let tasks = tasks, tasks.count > 0 {
            if !buttonsStackView.arrangedSubviews.contains(routerPickerView) {
                buttonsStackView.insertArrangedSubview(routerPickerView, at: 1)
            }
            
            let currentTask = tasks[taskCounter]
            routerPickerView.delegate = self
            routerPickerView.prioritizesVideoDevices = true
            routerPickerView.activeTintColor = UIColor(hexString: currentTask.colorValue)
            routerPickerView.tintColor = UIColor.darkGray
            routerPickerView.backgroundColor = UIColor(hexString: "1F2123")
            routerPickerView.roundCorners()
        }
    }
    
    private func nextTask() {
        taskCounter = taskCounter + 1
        updateUI()
        AudioManager.shared().playNext()
        self.testFeedback(6)
    }
    
    private func prevTask() {
        taskCounter = taskCounter - 1
        updateUI()
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
    
    //Add Time Observer for Time Countdown UX
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = AudioManager.shared().playerQueue.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            if let routineViewController = self {
                if let tasks = routineViewController.tasks, tasks.count > 0 {
                    let currentTask = tasks[routineViewController.taskCounter]
                    routineViewController.taskTimeLeft = Int(Double(currentTask.length) - time.seconds)
                    routineViewController.taskTimeLeftLabel.text = String().timeString(second: TimeInterval(routineViewController.taskTimeLeft))
                }
            }
        }
    }

    //Remove Time Observer for Time Countdown UX
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            AudioManager.shared().playerQueue.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // Player Status Observers
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &itemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
            case .readyToPlay:
                //Player is running an active task, grab the current one in the que based on the routine and tell UX to display it.
                updateUI()
                break
                // Player item is ready to play.
            case .failed:
                break
                // Player item failed. See error.
            case .unknown:
                break
                // Player item is not yet ready.
            @unknown default:
                break
            }
        }
    }
    
    //Get Current Item URL
    func getCurrentItemURL() -> URL? {
        let asset = AudioManager.shared().playerQueue.currentItem?.asset
        if asset == nil {
            return nil
        }
        if let urlAsset = asset as? AVURLAsset {
            return urlAsset.url
        }
        return nil
    }
    
    //Get Next Item URL
    func getNextItemURL() -> URL? {
        var asset: AVAsset?
        
        if let currentItem = AudioManager.shared().playerQueue.currentItem {
            if let index = AudioManager.shared().playerQueue.items().firstIndex(of: currentItem) {
                let nextIndex = AudioManager.shared().playerQueue.items().index(after: index)
                asset = AudioManager.shared().playerQueue.items()[nextIndex].asset
            }
        }
        
        if asset == nil {
            return nil
        }
        if let urlAsset = asset as? AVURLAsset {
            return urlAsset.url
        }
        return nil
    }
    
    func currentTask() -> Task? {
        if let nextItemURL = getNextItemURL() {
            let fileNameWithExtension = nextItemURL.deletingPathExtension()
            let fileName = fileNameWithExtension.lastPathComponent
            if let id = Int64(fileName) {
                let task = Task.find(moc: managedObjectContext, id: id)
                return task
            }
        }
        return nil
    }
}

extension RoutineViewController: AVRoutePickerViewDelegate {
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
    }
    
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
    }
}

