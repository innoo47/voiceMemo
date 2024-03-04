//
//  HomeView.swift
//  voiceMemo
//
//  Created by 박인호 on 2/29/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var pathModel = PathModel()
    @StateObject private var homeViewModel =  HomeViewModel()
    
    var body: some View {
        ZStack {
            
            // 탭 뷰
            TabView(selection: $homeViewModel.selectedTab) {
                
                TodoListView()
                    .tabItem {
                        Image (
                            homeViewModel.selectedTab == .todoList
                            ? "todoIcon_selected"
                            : "todoIcon"
                        )
                    }
                    .tag(Tab.todoList)
                
                MemoListView()
                    .tabItem {
                        Image (
                            homeViewModel.selectedTab == .memo
                            ? "memoIcon_selected"
                            : "memoIcon"
                        )
                    }
                    .tag(Tab.memo)
                
                VoiceRecorderView()
                    .tabItem {
                        Image (
                            homeViewModel.selectedTab == .voiceRecorder
                            ? "recordIcon_selected"
                            : "recordIcon"
                        )
                    }
                    .tag(Tab.voiceRecorder)
                
                TimerView()
                    .tabItem {
                        Image (
                            homeViewModel.selectedTab == .timer
                            ? "timerIcon_selected"
                            : "timerIcon"
                        )
                    }
                    .tag(Tab.timer)
                
                SettingView()
                    .tabItem {
                        Image (
                            homeViewModel.selectedTab == .setting
                            ? "settingIcon_selected"
                            : "settingIcon"
                        )
                    }
                    .tag(Tab.setting)
            }
            .environmentObject(homeViewModel)
            
            // 구분선
            SeperatorLineView()
        }
    }
}

// MARK: - 구분선

private struct SeperatorLineView: View {
    fileprivate var body: some View {
        VStack {
            Spacer()
            
            // 그림자 효과 구분선
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 10)
                .padding(.bottom, 60)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(PathModel())
        .environmentObject(TodoListViewModel())
        .environmentObject(MemoListViewModel())
    // Todo와 Memo의 Path Stack이 쌓일 수 있기 때문에 environmentObject 사용
}
