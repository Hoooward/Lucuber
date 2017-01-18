//
//  Scrambling.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation

public class Scrambling {
    
    public static let shared = Scrambling()
    
    let scramblingStepText = ["R", "L", "F", "B", "U", "D"]
    
    var indexGroup = [Int]()
    let scramblingStep: Int = 20
    
    var randomInt: Int {
        let diceFaceCount: UInt32 = 100
        let randomRoll = Int(arc4random_uniform(diceFaceCount)) + 1
        return randomRoll
    }
    
    
    public func refreshScramblingText() -> String {
        
        var scramblingResult: String = ""
        var stepIndex: Int
        
        let stepTextCount = scramblingStepText.count
        
        for _ in 0..<stepTextCount {
            stepIndex = randomInt % stepTextCount
            indexGroup.append(stepIndex)
        }
        
        for _ in 0..<scramblingStep {
            
            repeat {
                stepIndex = randomInt % stepTextCount
            } while checkIndexIsUnvalid(with: stepIndex)
            
            indexGroup.append(stepIndex)
        }
        
        
        for index in stepTextCount..<indexGroup.count {
            
            //将tmp设为0~4之间的随机数
            let tmp = randomInt % 5
            
            let stepTextIndex = indexGroup[index]
            
            if tmp == 4 { // 取1/5的概率
                scramblingResult += String(format: "%@2 ", scramblingStepText[stepTextIndex])
                
            } else if tmp == 2 || tmp == 3 { // 取2/5的概率
                scramblingResult += String(format: "%@' ", scramblingStepText[stepTextIndex])
                
            } else {
                scramblingResult += String(format: "%@ ", scramblingStepText[stepTextIndex])
            }
        }
        
        indexGroup.removeAll()
        
        return scramblingResult
    }
    
    func checkIndexIsUnvalid(with index: Int) -> Bool {
        
        if index == indexGroup[indexGroup.count - 1] {
            return true
        } else if index == indexGroup[indexGroup.count - 2] && checkIndexIsUnvalidOfTowStep(firstIndex: index, secondIndex: indexGroup[indexGroup.count - 1]) {
            return true
        }
        
        return false
    }
    
    func checkIndexIsUnvalidOfTowStep(firstIndex: Int, secondIndex: Int) -> Bool {
        
        if floor(Double(firstIndex / 2)) == floor(Double(secondIndex / 2)) {
            return true
        }
        return false
    }
    
    public init() {
    }
}


