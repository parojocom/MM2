//
//  TimeExt.swift
//  MM2
//
//  Created by 2fletch on 2020-12-13.
//

import Foundation

extension DateFormatter {
    static let mmoveFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }()
    
    static let mmoveFullDateFormatter: DateFormatter = {
        let fullDateFmtStr = "yyyy-MM-dd HH:mm:ss"
        let fmt = DateFormatter()
        fmt.dateFormat = fullDateFmtStr
        return fmt
    }()
    
    static let mmove24HTimeDateFormatter: DateFormatter = {
        let timeFmtStr = "HH:mm:ss"
        let fmt = DateFormatter()
        fmt.dateFormat = timeFmtStr
        return fmt
    }()
}

extension Date {
    var mmoveDateString: String {
        return DateFormatter.mmoveFormatter.string(from: self)
    }
}

extension TimeInterval {
    var mmoveDateString: String {
        return Date(timeIntervalSince1970: self).mmoveDateString
    }
}

extension Int {
    var milliToMicroSeconds: useconds_t {
        return UInt32(self).milliToMicroSeconds
    }
}

extension UInt32 {
    var milliToMicroSeconds: useconds_t {
        return self * 1000
    }
}
