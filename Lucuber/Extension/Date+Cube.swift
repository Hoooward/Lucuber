//
//  Date+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/15.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation

let kMinute = 60
let kDay = kMinute * 24
let kWeek = kDay * 7
let kMonth = kDay * 31
let kYear = kDay * 365

extension Date {
    
    public var isInCurrentWeek: Bool {
        return Calendar.current.isDateInWeekend(self)
    }

    public var timeAgo: String {
        
        let now = Date()
        let deltaSeconds = Int(fabs(timeIntervalSince(now)))
        let deltaMinutes = deltaSeconds / 60
        
        var value: Int!
        
        if deltaSeconds < 5 {
            return "现在"
        } else if deltaSeconds < kMinute {
            // seconds ago
            return String(format: "%d秒前 ", deltaSeconds)
        } else if deltaSeconds < 120 {
            // A minute Ago
            return "1分钟之前"
        } else if deltaMinutes < kMinute {
            // Minutes Ago
            return String(format: "%d分钟前", deltaMinutes)
        } else if deltaMinutes < 120 {
            // An Hour Ago
            return "1小时之前"
        } else if deltaMinutes < kDay {
            // Hour Ago
            value = Int(floor(Float(deltaMinutes / kMinute)))
            return  String(format: "%d小时前", value)
        } else if deltaMinutes < (kDay * 2) {
            // Last Day
            return "昨天"
        } else if deltaMinutes < kWeek {
            // Days Ago
            value = Int(floor(Float(deltaMinutes / kDay)))
            return String(format: "%d天前", value)
        } else if deltaMinutes < (kWeek * 2) {
            // Last week
            return "上星期"
        } else if deltaMinutes < kMonth {
            // Weeks Ago
            value = Int(floor(Float(deltaMinutes / kWeek)))
            return String(format: "%d星期前", value)
        } else if deltaMinutes < (kDay * 61) {
            // Last Month
            return "上个月"
        } else if deltaMinutes < kYear {
            // Month Ago
            value = Int(floor(Float(deltaMinutes / kMonth)))
            return String(format: "%d个月前", value)
        } else if deltaMinutes < (kDay * (kYear * 2)) {
            // Last Year
            return "去年"
        }
        
        value = Int(floor(Float(deltaMinutes / kYear)))
        return String(format: "%d年前", value)
    }
}
