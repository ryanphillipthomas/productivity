//
//  LoggerDetailsViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class LoggerDetailsViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var logTextView: UITextView!
    
    var logNode: LogQueueNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStyles()
        configureView()
    }
    
    //MARK: Private
    private func getFormattedLog() -> String {
        var logDetails = ""
        
        //TimeStamp
        if let timeStamp = logNode.timeStamp {
            logDetails += "\(timeStamp.dateAsStringWithFormat(format: DateFormats.monthDateYearHyphenHoursMinutesSecondsMilliseconds.rawValue))\n\n"
        } else {
            logDetails += "Timestamp N/A\n\n"
        }
        
        //URL
        if let url = logNode.url {
            logDetails += "url: \(url)\n\n"
        } else {
            logDetails += "url: N/A\n\n"
        }
        
        //Status
        if let status = logNode.statusCode {
            logDetails += "status: \(status)\n\n"
        } else {
            logDetails += "status: N/A\n\n"
        }
        
        //Headers
        if let headers = logNode.httpHeaders {
            logDetails += "headers: \(headers)\n\n"
        } else {
            logDetails += "headers: nil\n\n"
        }
        
        //Request Params
        if let params = logNode.requestParameters {
            logDetails += "parameters: \(params)\n\n"
        } else {
            logDetails += "parameters: nil\n\n"
        }
        
        //Response
        if let response = logNode.responseData {
            logDetails += "responseData: \(response.responseDataString())\n\n"
        } else {
            logDetails += "responseData: N/A\n\n"
        }
        
        logDetails += "jaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfajaskdflajskdflajskdlfjasdklf;jkasdfjkalsdkjfaklsdfasdfasdfa"
        
        return logDetails
    }
    
    //MARK: Public
    func setStyles() {
        logTextView.layer.borderColor = UIColor.black.cgColor
        logTextView.layer.borderWidth = 2.0
    }
    
    func configureView() {
        logTextView.text = getFormattedLog()
    }
    
    //MARK: IBActions
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        
        //Write the contents of the logTextView to the log.txt file
        LogManager.shared().clearFile()
        LogManager.shared().write(text: logTextView.text)
        
        //Share log.txt file
        let file = LogManager.shared().logFile
        let folderName = LogManager.shared().folderName
        var objectsToShare = [Any]()
        if let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first, let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folderName) {
            let fileURL = writePath.appendingPathComponent(file)
            objectsToShare.append(fileURL)
        } else {
            objectsToShare.append(logTextView.text as Any)
        }

        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        // Excluded Social / Unwanted Activities
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,
                                            UIActivity.ActivityType.addToReadingList,
                                            UIActivity.ActivityType.postToFacebook,
                                            UIActivity.ActivityType.postToTwitter,
                                            UIActivity.ActivityType.postToTencentWeibo,
                                            UIActivity.ActivityType.postToWeibo,
                                            UIActivity.ActivityType.postToVimeo]
        self.present(activityVC, animated: true, completion: nil)
    }
}
