//
//  Date+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation

/*
 8/20/19 - IMPORTANT
 
 The following files were NOT migrated to new codebase.  These still exist in the old codebase and can be brought over from there on an adhoc
 basis.  Should be converted to Swift if/when migrated
 
 NSDate+MillisecondEpoch
 NSDate+Extras
 */

public enum DateFormatComponents: String {
    case y = "y"                    // (2008) Year no padding
    case yy = "yy"                  // (08)   Year, two digits (padding with zero if necessary)
    case yyyy = "yyyy"              // (2008) Year, min of 4 digits (padding with zero if necessary)
    
    case Q = "Q"                    // (4)  The quarter of the year.  User QQ if you want zero padding
    case QQQ = "QQQ"                // (Q4) Quarter including the "Q"
    case QQQQ = "QQQQ"              // (4th quarter) Quarter spelled out
    
    case M = "M"                    // (12)  The numeric month of the year. A single M will use "1" for January
    case MM = "MM"                  // (12)  The numeric month of the year.  A double M will use "01" for January
    case MMM = "MMM"                // (Dec) The shorthand name of the month
    case MMMM = "MMMM"              // (December) Full name of the month
    case MMMMM = "MMMMM"            // (D)   The narrow name of the month
    
    case d = "d"                    // (14) The day of the month. A single d will use "1" for January 1st
    case dd = "dd"                  // (14) The day of the month. A double d will use "01" for January 1st
    case F = "F"                    // (3rd Tuesday in December) The day of the week in the month
    case E = "E"                    // (Tues) The shorthand day of the week in the month
    case EEEE = "EEEE"              // (Tuesday) The full name of the day
    case EEEEE = "EEEEE"            // (T) The narrow day of week
    
    case h = "h"                    // (4) The 12-hour hour
    case hh = "hh"                  // (04) The 12-hour hour padding with a zero if there is only 1 digit
    case H = "H"                    // (16) The 24-hour hour
    case HH = "HH"                  // (16) The 24-hour hour padding with a zero if there is only 1 digit
    case a = "a"                    // (PM) AM / PM for 12-hour time formats
    
    case m = "m"                    // (35) The minute, with no padding for zeros
    case mm = "mm"                  // (35) The minute, with zero padding
    
    case s = "s"                    // (8) The seconds, with no padding for zeros
    case ss = "ss"                  // (08) The seconds, with padding for zeros
    case SSS = "SSS"                // (1234) The milliseconds
    
    case zzz = "zzz"                // (CST) The 3 letter name of the time zone.  Falls back to GMT-08:00 (hour offset) if the name is unknown
    case zzzz = "zzzz"              // (Central Standard Time) The expanded time zone name, falls back to GMT-08:00 (hour offset) if the name is unknown
    case ZZZZ = "ZZZZ"              // (CST-06:00) Time zone with abbreviation and offset
    case Z = "Z"                    // (-06:00) RFC 822 GMT format.  Can also match a literal Z for Zulu (UTC) time
    case ZZZZZ = "ZZZZZ"            // (-06:00) ISO 8601 time zone format
}

/*
 ALL date formats used in the app should be defined here.  In an effort to maintain consistency across date formats so we can easily modify
 all locations that are using a certain date format as well as easily search for where certain date formats are used
 */
public enum DateFormats: String {
    
    case monthDateYearSlash = "MM/dd/yyyy"
    case shorthandMonthDateYearComma = "MMM dd, yyyy"
    case shorthandMonthYear = "MMM yyyy"
    
    case hoursMinutesMeridian = "h:mm a"
    case hoursMinutes = "h:mm"
    case militaryHoursMinutesSecondsZulu = "HH:mm:ss:z"     //Used for analytics
    
    case weekdayMonthDay = "E MMM d"
    
    case monthDateYearSlashHoursMinutesMeridian = "MM/dd/yyyy hh:m a"
    case monthDateYearHyphenHoursMinutesSecondsMilliseconds = "MM-dd-yyyy H:m:ss:SSS"
    case monthDateYearSlashHoursMinutes = "MM/dd/yyyy hh:m"

}

public extension Date {
    
    //MARK: Computed Properties
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var asMonthDateYearSlash: String {
        return dateAsStringWithFormat(format: DateFormats.monthDateYearSlash.rawValue)
    }
    
    var asHoursMinutesMeridian: String {
        return dateAsStringWithFormat(format: DateFormats.hoursMinutesMeridian.rawValue)
    }
    
    var asHoursMinutes: String {
        return dateAsStringWithFormat(format: DateFormats.hoursMinutes.rawValue)
    }
    
    var asWeekdayMonthDay: String {
        return dateAsStringWithFormat(format: DateFormats.weekdayMonthDay.rawValue)
    }
    
    //MARK: Convenience Init
    init(seconds: Double) {
        self = Date(timeIntervalSince1970: seconds)
    }
    
    init(milliseconds:Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    //MARK: Generic
    func dateAsStringWithFormat(format: String,
                                timeZone: TimeZone = TimeZone.autoupdatingCurrent,
                                locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = locale
        return dateFormatter.string(from: self)
    }
    
    //MARK: Time Manipulation
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    func combineWithTime(time: Date) -> Date? {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
    }
    /*
    //MARK: Static (Double -> Date String)
    static func asDate(input: Double) -> String {
        return Date(milliseconds: input).dateAsStringWithFormat(format: "MM/dd/yyyy")
    }

    static func asDateHoursMin(_ input: Double) -> String {
        return Date(timeIntervalSince1970: input).dateAsStringWithFormat(format: "MM/dd/yyyy h:mm a")
    }
    
    static func ftConvertTimeStampToDate(_ input: Double) -> String {
        let timestampDate = Date(timeIntervalSince1970: input)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
        let result = dateFormatter.string(from: timestampDate)
        return "updated, \(result.uppercased())"
    }
    
    static func ftConvertDepartureTimeToDate(_ input: Double) -> [String] {
        let timestampDate = Date(timeIntervalSince1970: input)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "EEE MMM d"
        let result = dateFormatter.string(from: timestampDate)
        return result.components(separatedBy: " ")
    }
    
    static func ftConvertToTime(_ input: Double) -> String {
        let timestampDate = Date(timeIntervalSince1970: input)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a"
        let result = dateFormatter.string(from: timestampDate)
        return result.uppercased()
    }
    */
}

extension TimeInterval {
    public var humanReadableWithSocialRuleset: String {
        let date = Date(milliseconds: self)
        let isSameDay = Calendar.current.isDate(date, inSameDayAs: Date())
        return date.dateAsStringWithFormat(format: isSameDay ? DateFormats.hoursMinutesMeridian.rawValue : DateFormats.shorthandMonthDateYearComma.rawValue,
                                           timeZone: NSTimeZone.local)
    }
}
