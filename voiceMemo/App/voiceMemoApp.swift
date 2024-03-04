//
//  voiceMemoApp.swift
//  voiceMemo
//
//  Created by 박인호 on 1/19/24.
//

import SwiftUI

@main
struct voiceMemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // 앱 구조체가 때로는 UIKit의 기능이나 더 raw레벨의 iOS시스템 이벤트를 처리해야 하는 경우일때
    // SwiftUI에서 UIKit의 UIApplecationDelegate와 상호작용을 할 수 있다.
    // 즉, SwiftUI에서 UIKit AppDelegate를 생성하는데 사용하는 프로퍼티 래퍼
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
        }
    }
}
