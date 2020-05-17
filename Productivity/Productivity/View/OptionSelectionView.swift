//
//  OptionSelectionView.swift
//  Productivity
//
//  Created by Ryan Thomas on 5/10/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

//let key = Array(pickerData)[component].key
//let value = Array(pickerData)[component].value

import UIKit

//Move These Somewhere Else...
let chimeSoundFileString = "chime.wav"
let chime_2_SoundFileString = "chime_2.wav"

let announceSoundFileString = "bathroom.wav"
let musicSoundFileString = "1-minute-of-silence.mp3"
let spaceSoundFileString = "space.wav"
let musicSoundTemplateFileString = "1-hour-and-20-minutes-of-silence.mp3"

let bathroomSoundFileString = "bathroom.wav"
let coffeeSoundFileString = "coffee.wav"
let journalSoundFileString = "journal.wav"
let meditateSoundFileString = "meditate.wav"
let petsSoundFileString = "pets.wav"
let readSoundFileString = "read.wav"
let workoutSoundFileString = "workout.wav"

//MARK: EditOptions
public enum OptionSelection: CaseIterable {
    case chimes
    case announcers
    case music

    func pickerDataOptions() -> [String] {
        switch(self){
        case .chimes: return [chimeSoundFileString, chime_2_SoundFileString]
        case .announcers: return [bathroomSoundFileString, coffeeSoundFileString, journalSoundFileString, meditateSoundFileString, petsSoundFileString, readSoundFileString, workoutSoundFileString]
        case .music: return [musicSoundTemplateFileString]
        }
    }
    
    func rawValue() -> Int {
        switch(self){
        case .chimes: return 0
        case .announcers: return 1
        case .music: return 2
        }
    }
}

//MARK: OptionSelectionViewDelegate
protocol OptionSelectionViewDelegate: NSObjectProtocol {
    func didSelect(data: String, pickerSelection: OptionSelection)
}

class OptionSelectionView: PRXibView {
    @IBOutlet weak var picker: UIPickerView!
    var pickerData: [String] = [String]()
    weak var delegate: OptionSelectionViewDelegate?
    var pickerDataType: Int!
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyles()
        picker.dataSource = self
        picker.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Styles
    private func setStyles() {
        picker.roundCorners()
    }
    
    //MARK: Helpers
    private func fileNameForURL(urlString:String) -> String {
        let url = URL(string: urlString)!.deletingPathExtension()
        let fileName = url.lastPathComponent
        return fileName.titleCase()
    }
    
    func setupData(workingObject: PRBaseWorkingObject, pickerSelection: OptionSelection) {
        
        //setup data
        let data = OptionSelection.pickerDataOptions(pickerSelection)()
        pickerData = data
        pickerDataType = pickerSelection.rawValue()
        
        var url: String?
        switch pickerSelection {
        case .chimes:
            url = workingObject.chimeSoundFileURL
        case .announcers:
            url = workingObject.announceSoundFileURL
        case .music:
            url = workingObject.musicSoundFileURL
        }
        
        //default selection
        if let url = url {
            if let index = data.firstIndex(of: url) {
                DispatchQueue.main.async {
                    self.picker.selectRow(index, inComponent: 0, animated: false)
                }
            }
        }
    }
}

extension OptionSelectionView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let delegate = delegate {
            let data = pickerData[row]
            delegate.didSelect(data: data, pickerSelection: OptionSelection.allCases[pickerDataType])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let fileName = fileNameForURL(urlString: pickerData[row])
        return fileName
    }
}

extension OptionSelectionView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
}
