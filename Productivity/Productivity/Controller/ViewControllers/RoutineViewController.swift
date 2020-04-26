//
//  RoutineViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/25/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData

class RoutineViewController: PRBaseViewController {
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var resetPrevButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var currentRoutineNumberLabel: UILabel!
    @IBOutlet weak var currentRoutineNameLabel: UILabel!
    @IBOutlet weak var taskTimeLeftLabel: UILabel!

    var routineID: Int64?
    var workingObject = PRBaseWorkingObject()
    var routine: Routine?
    var tasks: [Task]?
    var taskCounter = 0
    
    var taskTimer: Timer?
    var taskTimeLeft = 0
    
    var isPaused = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoutine()
        setupTasks()
        runTimer(shouldReset: true)
        setupStyles()
        
        updateUI()
    }
    
    //MARK: Styles
    private func setupStyles() {
        for button in buttons {
            button.roundCorners()
        }
    }
    
    //MARK: Setup Timer
    func runTimer(shouldReset:Bool) {
        if let tasks = tasks {
            if shouldReset {
                taskTimer?.invalidate()
                taskTimer = nil
                taskTimeLeft = Int(tasks[taskCounter].length)
            } else {
                taskTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
            }
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
        tasks = Task.fetchInContext(context: managedObjectContext)
    }
    
    //MARK: Update UX
    func updateUI() {
        updateLabels()
        updateButtons()
    }
    
    private func updateLabels() {
        if let routine = routine, let tasks = tasks {
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
        if let routine = routine, let tasks = tasks {
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
    
    private func nextTask() {
        guard let tasks = tasks, tasks.count > taskCounter + 1  else { return }
        taskCounter = taskCounter + 1
        updateUI()
    }
    
    private func prevTask() {
        guard let _ = tasks, taskCounter >= 1  else { return }
        taskCounter = taskCounter - 1
        updateUI()
    }
    
    private func resumeTask() {
        isPaused = false
        runTimer(shouldReset: false)
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    private func pauseTask() {
        isPaused = true
        taskTimer?.invalidate()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    private func resetTask() {
        updateLabels()
        runTimer(shouldReset: true)
        pauseTask()
    }
    
    @objc func onTimerFires()
    {
        taskTimeLeft -= 1
        taskTimeLeftLabel.text = String().timeString(second: TimeInterval(taskTimeLeft))

        if taskTimeLeft <= 0 {
            taskTimer?.invalidate()
            taskTimer = nil
                        
            //has remaining tasks
            if let tasks = tasks {
                if taskCounter + 1 < tasks.count {
                    nextTask()
                    resumeTask()
                }
            }
        }
    }
}
