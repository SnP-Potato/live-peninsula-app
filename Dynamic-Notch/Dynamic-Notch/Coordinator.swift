//
//  Coordinator.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import Foundation
import SwiftUI
import Combine

class Coordinator: ObservableObject {
    static let shared = Coordinator()
    
    // 화면 관련 설정
    @Published var selectedScreen: String = NSScreen.main?.localizedName ?? "Unknown" {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("SelectedScreenChanged"), object: nil)
        }
    }
    
    @Published var firstLaunch: Bool = true
    // 노치 관련 설정
    @AppStorage("openNotchOnHover") var openNotchOnHover: Bool = true
    @AppStorage("minimumHoverDuration") var minimumHoverDuration: TimeInterval = 0.0
    
    // 뷰 관련 설정
    @AppStorage("alwaysShowTabs") var alwaysShowTabs: Bool = true
    @Published var currentView: NotchMainFeaturesView = .studio
    
    private init() {
        setupNotifications()
    }
    
    // 알림 관찰 설정
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenConfigurationChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    // 화면 구성 변경 처리
    @objc private func screenConfigurationChanged() {
        // 선택된 화면이 여전히 존재하는지 확인
        if !NSScreen.screens.contains(where: { $0.localizedName == selectedScreen }) {
            selectedScreen = NSScreen.main?.localizedName ?? "Unknown"
        }
    }
    
    // 메모리 정리
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
