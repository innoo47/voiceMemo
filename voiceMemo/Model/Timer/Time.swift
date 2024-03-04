//
//  Time.swift
//  voiceMemo
//
//  Created by 박인호 on 2/26/24.
//

import Foundation

struct Time {
    var hours: Int
    var minutes: Int
    var seconds: Int
    
    // 시,분,초를 초로 환산
    var convertedSeconds: Int {
        return (hours * 3600) + (minutes * 60) + seconds
    }
    
    // 전체 초를 시,분,초로 환산
    static func fromSeconds(_ seconds: Int) -> Time {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = (seconds % 3600) % 60
        
        return Time(hours: hours, minutes: minutes, seconds: remainingSeconds)
    }
    
}
