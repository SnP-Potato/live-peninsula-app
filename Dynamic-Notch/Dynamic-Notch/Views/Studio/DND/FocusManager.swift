//
//  FocusManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/22/25.
//

import Foundation
import SwiftUI


class FocusManager: ObservableObject {
    
    static let shared = FocusManager()
    
    @Published var isFocused: Bool = false {
        didSet {
            UserDefaults.standard.set(isFocused, forKey: "isFocused")
            print("집중모드 상태 저장 완료")
        }
    }
    
    private init() {
        self.isFocused = UserDefaults.standard.bool(forKey: "isFocused")
    }
    
    func toggleFocusMode() {
        if isFocused {
            focusModedeactivate()
        } else {
            focusModeactivation()
        }
    }
    
    
    func focusModeactivation() {
        executeShortcut()
        isFocused = true
        print("집중모드 활성화")
    }
    
    
    func focusModedeactivate() {
        executeShortcut()
        isFocused = false
        print("집중모드 비활성화")
    }
    
    func executeShortcut() {
        let shortcutName = "Focus"
        
        if let encodeName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: "shortcuts://run-shortcut?name=\(encodeName)") {
                NSWorkspace.shared.open(url)
                print("Toggle DND 실행함")
            }
        }
        
    }
}


//import Foundation
//import SwiftUI
//
//class FocusManager: ObservableObject {
//    
//    static let shared = FocusManager()
//    
//    @Published var isFocused: Bool = false {
//        didSet {
//            if oldValue != isFocused {
//                UserDefaults.standard.set(isFocused, forKey: "isFocused")
//                print("집중모드 상태 변경: \(isFocused ? "활성화" : "비활성화")")
//            }
//        }
//    }
//    
//    private var lastUserAction: Date = Date()
//    private var statusCheckTimer: Timer?
//    
//    private init() {
//        self.isFocused = UserDefaults.standard.bool(forKey: "isFocused")
//        setupSimpleMonitoring()
//    }
//    
//    deinit {
//        statusCheckTimer?.invalidate()
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    // MARK: - 사용자 액션
//    func toggleFocusMode() {
//        lastUserAction = Date()
//        if isFocused {
//            focusModeDeactivate()
//        } else {
//            focusModeActivate()
//        }
//    }
//    
//    func focusModeActivate() {
//        executeShortcut()
//        isFocused = true
//        print("집중모드 활성화")
//    }
//    
//    func focusModeDeactivate() {
//        executeShortcut()
//        isFocused = false
//        print("집중모드 비활성화")
//    }
//    
//    // MARK: - 간단한 모니터링
//    private func setupSimpleMonitoring() {
//        // 앱이 포커스를 받을 때마다 상태 체크
//        NotificationCenter.default.addObserver(
//            forName: NSApplication.didBecomeActiveNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            self?.checkStatusOnAppActivation()
//        }
//        
//        // 화면이 활성화될 때 체크
//        NotificationCenter.default.addObserver(
//            forName: NSWorkspace.screensDidWakeNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self?.checkStatusOnAppActivation()
//            }
//        }
//        
//        // 30초마다 가벼운 체크
//        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
//            self?.lightweightStatusCheck()
//        }
//    }
//    
//    private func checkStatusOnAppActivation() {
//        // 최근에 사용자가 버튼을 눌렀다면 체크하지 않음
//        let timeSinceUserAction = Date().timeIntervalSince(lastUserAction)
//        if timeSinceUserAction < 5.0 {
//            return
//        }
//        
//        print("📱 앱 활성화 - 집중모드 상태 체크")
//        performStatusCheck()
//    }
//    
//    private func lightweightStatusCheck() {
//        let timeSinceUserAction = Date().timeIntervalSince(lastUserAction)
//        if timeSinceUserAction < 10.0 {
//            return
//        }
//        
//        performStatusCheck()
//    }
//    
//    private func performStatusCheck() {
//        // 메뉴바에서 DND 아이콘 확인
//        let task = Process()
//        task.launchPath = "/usr/bin/defaults"
//        task.arguments = ["read", "com.apple.controlcenter", "NSStatusItem Visible DoNotDisturb"]
//        
//        let pipe = Pipe()
//        task.standardOutput = pipe
//        task.standardError = pipe
//        
//        do {
//            try task.run()
//            task.waitUntilExit()
//            
//            let data = pipe.fileHandleForReading.readDataToEndOfFile()
//            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//            
//            let shouldBeFocused = output == "1" || output.lowercased() == "true"
//            
//            if self.isFocused != shouldBeFocused {
//                print("🔍 메뉴바에서 집중모드 상태 감지: \(shouldBeFocused ? "활성화" : "비활성화")")
//                DispatchQueue.main.async {
//                    self.isFocused = shouldBeFocused
//                }
//            }
//        } catch {
//            print("❌ 집중모드 상태 체크 실패: \(error)")
//        }
//    }
//    
//    // MARK: - 단축어 실행
//    func executeShortcut() {
//        let shortcutName = "Toggle DND"
//        
//        if let encodeName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            if let url = URL(string: "shortcuts://run-shortcut?name=\(encodeName)") {
//                NSWorkspace.shared.open(url)
//                print("Toggle DND 실행함")
//            }
//        }
//    }
//}

