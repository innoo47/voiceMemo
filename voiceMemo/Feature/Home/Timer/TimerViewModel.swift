//
//  TimerViewModel.swift
//  voiceMemo
//
//  Created by 박인호 on 2/26/24.
//

import Foundation
import UIKit

class TimerViewModel: ObservableObject {
    @Published var isDisplaySetTimeView: Bool   // 설정된 시간의 존재 유뮤
    @Published var time: Time
    @Published var timer: Timer?
    @Published var timeRemaining: Int           // 남은 시간
    @Published var isPaused: Bool               // 정지 상태 유무
    var notificationService: NotificationService
    
    init(
        isDisplaySetTimeView: Bool = true,
        time: Time = .init(hours: 0, minutes: 0, seconds: 0),
        timer: Timer? = nil,
        timeRemaining: Int = 0,
        isPaused: Bool = false,
        notificationService: NotificationService = .init()
    ) {
        self.isDisplaySetTimeView = isDisplaySetTimeView
        self.time = time
        self.timer = timer
        self.timeRemaining = timeRemaining
        self.isPaused = isPaused
        self.notificationService = notificationService
    }
}


// MARK: - 공개 로직

extension TimerViewModel {
    
    // "설정하기" 버튼 클릭 시
    func settingBtnTapped() {
        
        self.isDisplaySetTimeView = false
        self.timeRemaining = time.convertedSeconds
        // TODO: - 타이머 시작 메서드 호출
        self.startTimer()
        
    }
    
    // "취소" 버튼 클릭 시
    func cancelBtnTapped() {
        
        // TODO: - 타이머 종료 메서드 호출
        self.stopTimer()
        
        self.isDisplaySetTimeView = true
    }
    
    // "일시정시" 및 "다시시작" 버튼 클릭 시
    func pauseOrRestartBtnTapped() {
        
        if self.isPaused {
            // TODO: - 타이머 시작 메서드 호출
            self.startTimer()
        } else {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.isPaused.toggle()
        
    }
}


// MARK: - 비공개 로직

private extension TimerViewModel {
    
    // 타이머 시작 메서드
    func startTimer() {
        
        guard self.timer == nil else { return }
        
        // 앱이 백그라운드로 전환되었을때 일부 작업을 계속 수행할 수 있게 해주는 메서드
        var backgroundTaskID: UIBackgroundTaskIdentifier?
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            if let task = backgroundTaskID {
                UIApplication.shared.endBackgroundTask(task)
                backgroundTaskID = .invalid
            }
        }
        
        self.timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                // TODO: - 타이머 종료 메서드 호출
                self.stopTimer()
                
                // TODO: - Locale Notification
                self.notificationService.sendNotification()
                
                if let task = backgroundTaskID {
                    UIApplication.shared.endBackgroundTask(task)
                    backgroundTaskID = .invalid
                }
            }
        }
    }
    
    // 타이머 정지 메서드
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
}
