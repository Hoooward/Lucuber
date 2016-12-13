//
//  Date+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/15.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation


extension Date {
    

    func isInCurrentWeek() -> Bool {

        let calendar = Calendar.current

        let firstDateOfWeek = calendar.firstWeekday




        if self.compare(firstDateOfWeek) == .orderedDescending {
            return true
        }

        return false

    }
    
}
