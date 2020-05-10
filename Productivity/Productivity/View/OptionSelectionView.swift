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
let chimeSoundFileString = Bundle.main.url(forResource: "chime.wav", withExtension: nil)!.absoluteString
let chime_2_SoundFileString = Bundle.main.url(forResource: "chime_2.wav", withExtension: nil)!.absoluteString

let announceSoundFileString = Bundle.main.url(forResource: "bathroom.wav", withExtension: nil)!.absoluteString
let musicSoundFileString = Bundle.main.url(forResource: "1-minute-of-silence.mp3", withExtension: nil)!.absoluteString
let spaceSoundFileString = Bundle.main.url(forResource: "space.wav", withExtension: nil)!.absoluteString
let musicSoundTemplateFileString = Bundle.main.url(forResource: "1-hour-and-20-minutes-of-silence.mp3", withExtension: nil)!.absoluteString

let bathroomSoundFileString = Bundle.main.url(forResource: "bathroom.wav", withExtension: nil)!.absoluteString
let coffeeSoundFileString = Bundle.main.url(forResource: "coffee.wav", withExtension: nil)!.absoluteString
let journalSoundFileString = Bundle.main.url(forResource: "journal.wav", withExtension: nil)!.absoluteString
let meditateSoundFileString = Bundle.main.url(forResource: "meditate.wav", withExtension: nil)!.absoluteString
let petsSoundFileString = Bundle.main.url(forResource: "pets.wav", withExtension: nil)!.absoluteString
let readSoundFileString = Bundle.main.url(forResource: "read.wav", withExtension: nil)!.absoluteString
let workoutSoundFileString = Bundle.main.url(forResource: "workout.wav", withExtension: nil)!.absoluteString

//MARK: EditOptions
public enum OptionSelection: CaseIterable {
    case chimes
    case announcers
    case music

    func pickerDataOptions() -> [String] {
        switch(self){
        case .chimes: return [chimeSoundFileString, chime_2_SoundFileString]
        case .announcers: return [bathroomSoundFileString, coffeeSoundFileString, journalSoundFileString, meditateSoundFileString, petsSoundFileString, readSoundFileString, workoutSoundFileString]
        case .music: return [musicSoundFileString, spaceSoundFileString]
        }
    }
}

//MARK: OptionSelectionViewDelegate
protocol OptionSelectionViewDelegate: NSObjectProtocol {
    func didSelect(data: String)
}

class OptionSelectionView: PRXibView {
    @IBOutlet weak var picker: UIPickerView!
    var pickerData: [String] = [String]()
    weak var delegate: OptionSelectionViewDelegate?
    
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
        let data = OptionSelection.pickerDataOptions(pickerSelection)()
        pickerData = data
    }
}

extension OptionSelectionView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let delegate = delegate {
            let data = pickerData[row]
            delegate.didSelect(data: data)
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
