//
//  String+Extension.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

/*
 8/20/19 - IMPORTANT
 
 The following files were NOT migrated to new codebase.  These still exist in the old codebase and can be brought over from there on an adhoc
 basis.  Should be converted to Swift if/when migrated
 
 NSString+Hashes
 NSString+Extras
 NSString+URLEncode
 NSString+StringSupport
 NSMutableAttributedString+LinkSupport
 */

public extension String {
    
    //MARK: Formatting
    func titleCase() -> String {
        let smallWords = ["a", "an"]
        var words = self.lowercased().split(separator: " ").map({ String($0)})
        words[0] = words[0].capitalized
        for i in 1..<words.count {
            if !smallWords.contains(words[i]) {
                words[i] = words[i].capitalized
            }
        }
        return words.joined(separator: " ")
    }
    
    mutating func interpolateTemplate(placeholder: String, with value: String) {
        self = self.replacingOccurrences(of: placeholder, with: value)
    }
    
    
    //MARK: HTML
    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
    
    func convertHtml() -> NSMutableAttributedString {
        guard let data = data(using: .utf8) else { return NSMutableAttributedString() }
        do {
            let mutableString = try NSMutableAttributedString(data: data,
                                                              options: [.documentType : NSAttributedString.DocumentType.html,
                                                                        .characterEncoding: String.Encoding.utf8.rawValue],
                                                              documentAttributes: nil)
            let lineSpace = NSMutableParagraphStyle()
            lineSpace.lineSpacing = 12
            mutableString.addAttributes([NSAttributedString.Key.kern : 1,
                                         NSAttributedString.Key.paragraphStyle : lineSpace.copy()],
                                        range: NSMakeRange(0, mutableString.string.count))
            return mutableString
        } catch {
            return NSMutableAttributedString()
        }
    }
    
    //MARK: Firebase
    func safeStringForFirebase() -> String {
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "_")
    }
    
    //MARK: Price
    func priceString(price: Double) -> String {
        //In order to remove the space before the $ we end up adding the symbol after the space. At index 1
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "en_US_POSIX")
        currencyFormatter.groupingSize = 3
        currencyFormatter.generatesDecimalNumbers = false
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.currencySymbol = ""
        
        guard let priceString = currencyFormatter.string(from: NSNumber(value: price)), priceString.count > 1 else { return "" }
        
        let mutablePriceString = NSMutableString(string: priceString)
        mutablePriceString.insert("$", at: 1)
        return "\(mutablePriceString)"
    }
    
    func priceStringWithCents(price: Double) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return currencyFormatter.string(from: NSNumber(value: price)) ?? ""
    }
    
    //MARK: Time Formatting
    func hourToString(hour:Double, hourString: String = "H", minuteString: String = "M", startingString: String = "") -> String {
        var timeString = startingString
        let hours = Int(floor(hour))
        let mins = Int(floor(hour * 60).truncatingRemainder(dividingBy:60))
        if hours > 0 {
            timeString += "\(hours)\(hourString)"
        }
        if mins > 0 {
            if hour > 0 {
                timeString += " "
            }
            timeString += "\(mins)\(minuteString)"
        }
        
        return timeString
    }

    func hasMinutes(interval: TimeInterval) -> Bool {
        let minutes = Int(interval) / 60 % 60
        
        if minutes > 0 {
            return true
        }
        return false
    }
    
    func hasHours(interval: TimeInterval) -> Bool {
        let hours = Int(interval) / 3600
        
        if hours > 0 {
            return true
        }
        return false
    }
    
    func timeString(second: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        if hasMinutes(interval: second) && hasHours(interval: second) {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else if hasMinutes(interval: second) {
            formatter.allowedUnits = [.minute, .second]
        } else {
            formatter.allowedUnits = [.second]
        }
        
        return formatter.string(from: second)
    }
}
