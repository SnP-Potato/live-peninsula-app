//
//  Coordinator.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import Foundation
import SwiftUI
import Combine
import Defaults

class Coordinator: ObservableObject {
    
    static let shared = Coordinator()
        
        // 현재 화면 관리
        @Published var selectedScreen: String = NSScreen.main?.localizedName ?? "Unknown"
        
        // 탭 표시 여부
        @AppStorage("alwaysShowTabs") var alwaysShowTabs: Bool = true
        
        // 호버 시 노치 열기 설정
        @AppStorage("openNotchOnHover") var openNotchOnHover: Bool = true
        // 호버 최소 지속 시간
        @AppStorage("minimumHoverDuration") var minimumHoverDuration: TimeInterval = 0.0
        
        private init() {
            selectedScreen = NSScreen.main?.localizedName ?? "Unknown"
        }
    
}
