//
//  TimerView.swift
//  voiceMemo
//
//  Created by 박인호 on 2/26/24.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    
    var body: some View {
        
        if timerViewModel.isDisplaySetTimeView {
            // 타이머 설정 뷰
            SetTimerView(timerViewModel: timerViewModel)
        } else {
            // 타이머 작동 뷰
            TimerOperationView(timerViewModel: timerViewModel)
            
        }
    }
}

// MARK: - 타이머 설정 뷰
private struct SetTimerView: View {
    @ObservedObject private var timerViewModel: TimerViewModel
    
    fileprivate init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel
    }
    
    fileprivate var body: some View {
        VStack {
            
            // 타이틀 뷰
            TitleView()
                
            Spacer()
                .frame(height: 100)
            
            // 타이머 피커 뷰
            TimerPickerView(timerViewModel: timerViewModel)
                
            Spacer()
                .frame(height: 30)
            
            // "설정하기" 버튼 뷰
            TimerCreateBtnView(timerViewModel: timerViewModel)
            
            Spacer()
            
        }
    }
}

// MARK: - 타이틀 뷰

private struct TitleView: View {
    
    fileprivate var body: some View {
        HStack {
            Text("타이머")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.customBlack)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
    }
}

// MARK: - 타이머 피커 뷰

private struct TimerPickerView: View {
    @ObservedObject private var timerViewModel: TimerViewModel
    
    fileprivate init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel
    }
    
    fileprivate var body: some View {
        VStack {
            Rectangle()
                .fill(Color.customGray2)
                .frame(height: 1)
            
            HStack {
                
                // 시
                Picker("Hour", selection: $timerViewModel.time.hours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour) 시")
                    }
                }
                
                // 분
                Picker("Minutes", selection: $timerViewModel.time.minutes) {
                    ForEach(0..<60) { minutes in
                        Text("\(minutes) 분")
                    }
                }
                
                // 초
                Picker("Seconds", selection: $timerViewModel.time.seconds) {
                    ForEach(0..<60) { seconds in
                        Text("\(seconds) 초")
                    }
                }
            }
            .labelsHidden()
            .pickerStyle(.wheel)
            .padding(.vertical, 10)
            
            Rectangle()
                .fill(Color.customGray2)
                .frame(height: 1)
        }
    }
    
}

// MARK: - "설정하기" 버튼 뷰

private struct TimerCreateBtnView: View {
    @ObservedObject private var timerViewModel: TimerViewModel
    
    fileprivate init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel
    }
    
    fileprivate var body: some View {
        HStack {
            Button(
                action: {
                    timerViewModel.settingBtnTapped()
                },
                label: {
                    Text("설정하기")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.customGreen)
                }
            )
        }
    }
}

// MARK: - 타이머 작동 뷰

private struct TimerOperationView: View {
    @ObservedObject private var timerViewModel: TimerViewModel
    
    fileprivate init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel
    }
    
    fileprivate var body: some View {
        VStack {
            
            // 타이머 메인 뷰
            ZStack {
                
                VStack {
                    
                    // 설정된 타이머
                    Text("\(timerViewModel.timeRemaining.formattedTimeString)")
                        .font(.system(size: 28))
                        .foregroundColor(.customBlack)
                        .monospaced() // 각 글자간에 고정된 폭을 갖기 위해 사용
                    
                    // 알람이 울릴 시간
                    HStack(alignment: .bottom) {
                        Image(systemName: "bell.fill")
                        
                        Text("\(timerViewModel.time.convertedSeconds.formattedSettingTime)")
                            .font(.system(size: 16))
                            .foregroundColor(.customBlack)
                            .padding(.top, 10)
                    }
                }
                
                // 가운데 원
                Circle()
                    .stroke(Color.customOrange, lineWidth: 6)
                    .frame(width: 350)
            }
            
            Spacer()
                .frame(height: 10)
            
            HStack {
                
                // "취소" 버튼
                Button(
                    action: {
                        timerViewModel.cancelBtnTapped()
                    },
                    label: {
                        Text("취소")
                            .font(.system(size: 16))
                            .foregroundColor(.customBlack)
                            .padding(.vertical, 25)
                            .padding(.horizontal, 22)
                            .background(
                                Circle()
                                    .fill(Color.customGray2.opacity(0.3))
                            )
                    }
                )
                
                Spacer()
                
                // "계속진행" 또는 "일시정지" 버튼
                Button(
                    action: {
                        timerViewModel.pauseOrRestartBtnTapped()
                    },
                    label: {
                        Text(timerViewModel.isPaused ? "계속진행" : "일시정지")
                            .font(.system(size: 16))
                            .foregroundColor(.customBlack)
                            .padding(.vertical, 25)
                            .padding(.horizontal, 7)
                            .background(
                                Circle()
                                    .fill(Color(red: 1, green: 0.75, blue: 0.52).opacity(0.3))
                            )
                    }
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
}

#Preview {
    TimerView()
}
