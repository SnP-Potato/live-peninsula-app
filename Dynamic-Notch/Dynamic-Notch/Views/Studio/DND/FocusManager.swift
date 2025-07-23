//
//  FocusManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/22/25.
//

//import Foundation
//import SwiftUI
//
//
//class FocusManager: ObservableObject {
//    
//    static let shared = FocusManager()
//    
//    @Published var isFocused: Bool = false {
//        didSet {
//            UserDefaults.standard.set(isFocused, forKey: "isFocused")
//            print("집중모드 상태 저장 완료")
//        }
//    }
//    
//    private init() {
//        self.isFocused = UserDefaults.standard.bool(forKey: "isFocused")
//    }
//    
//    func toggleFocusMode() {
//        if isFocused {
//            focusModedeactivate()
//        } else {
//            focusModeactivation()
//        }
//    }
//    
//    
//    func focusModeactivation() {
//        executeShortcut()
//        isFocused = true
//        print("집중모드 비활성화")
//    }
//    
//    
//    func focusModedeactivate() {
//        executeShortcut()
//        isFocused = false
//        print("집중모드 활성화")
//    }
//    
//    func executeShortcut() {
//        let shortcutName = "Toggle DND"
//        
//        if let encodeName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            if let url = URL(string: "shortcuts://run-shortcut?name=\(encodeName)") {
//                NSWorkspace.shared.open(url)
//                print("Toggle DND 실행함")
//            }
//        }
//        
//    }
//}


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

import Foundation
import SwiftUI
import Combine

class FocusManager: ObservableObject {
    
    static let shared = FocusManager()
    
    @Published var isFocused: Bool = false {
        didSet {
            if oldValue != isFocused {
                UserDefaults.standard.set(isFocused, forKey: "isFocused")
                print("✅ 집중모드 상태 변경: \(isFocused ? "활성화" : "비활성화")")
            }
        }
    }
    
    private var lastUserAction: Date = Date.distantPast
    private var statusCheckTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // 사용자 액션 무시 시간을 더 길게 설정
    private let userActionIgnoreDuration: TimeInterval = 10.0
    
    private init() {
        self.isFocused = UserDefaults.standard.bool(forKey: "isFocused")
        setupDNDMonitoring()
    }
    
    deinit {
        statusCheckTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
    }
    
    // MARK: - 사용자 액션
    func toggleFocusMode() {
        print("🎯 사용자가 집중모드 토글 버튼 클릭")
        lastUserAction = Date()
        
        if isFocused {
            focusModeDeactivate()
        } else {
            focusModeActivate()
        }
        
        // 단축어 실행 후 더 긴 시간 뒤에 상태 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.verifyStatusAfterUserAction()
        }
    }
    
    func focusModeActivate() {
        print("🌙 집중모드 활성화 시도")
        
        // 1. 먼저 단축어 실행
        executeShortcut()
        
        // 2. 내부 상태 업데이트
        isFocused = true
        
        // 3. 단축어가 실제로 작동했는지 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.checkShortcutSuccess()
        }
    }
    
    func focusModeDeactivate() {
        print("☀️ 집중모드 비활성화 시도")
        executeShortcut()
        isFocused = false
    }
    
    // 단축어 실행 성공 여부 확인
    private func checkShortcutSuccess() {
        print("🔍 단축어 실행 결과 확인 중...")
        Task {
            let actualStatus = await checkMultipleDNDMethods()
            
            DispatchQueue.main.async {
                if let actual = actualStatus {
                    if actual != self.isFocused {
                        print("⚠️ 단축어 실행 실패! 예상: \(self.isFocused ? "활성화" : "비활성화"), 실제: \(actual ? "활성화" : "비활성화")")
                        print("💡 단축어 'Toggle DND'가 제대로 설정되었는지 확인하세요!")
                    } else {
                        print("✅ 단축어 실행 성공! 상태 일치: \(actual ? "활성화" : "비활성화")")
                    }
                }
            }
        }
    }
    
    // 사용자 액션 후 실제 상태 검증
    private func verifyStatusAfterUserAction() {
        print("🔍 사용자 액션 후 상태 검증 중...")
        Task {
            await checkDNDStatusAndUpdate()
        }
    }
    
    // MARK: - DND 모니터링 설정
    private func setupDNDMonitoring() {
        // 앱 활성화/비활성화 감지
        setupAppStateMonitoring()
        
        // 주기적 체크 (간격을 더 늘림)
        setupPeriodicCheck()
        
        // 화면 깨우기 감지
        setupScreenStateMonitoring()
    }
    
    // MARK: - 앱 상태 모니터링
    private func setupAppStateMonitoring() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkStatusOnAppActivation()
        }
    }
    
    // MARK: - 화면 상태 모니터링
    private func setupScreenStateMonitoring() {
        NotificationCenter.default.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self?.performStatusCheck()
            }
        }
    }
    
    // MARK: - 주기적 체크 (간격을 60초로 증가)
    private func setupPeriodicCheck() {
        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.lightweightStatusCheck()
        }
    }
    
    private func checkStatusOnAppActivation() {
        let timeSinceUserAction = Date().timeIntervalSince(lastUserAction)
        if timeSinceUserAction < userActionIgnoreDuration {
            print("⏰ 사용자 액션 후 \(String(format: "%.1f", timeSinceUserAction))초 - 상태 체크 무시")
            return
        }
        
        print("📱 앱 활성화 - 집중모드 상태 체크")
        performStatusCheck()
    }
    
    private func lightweightStatusCheck() {
        let timeSinceUserAction = Date().timeIntervalSince(lastUserAction)
        if timeSinceUserAction < userActionIgnoreDuration {
            print("⏰ 사용자 액션 후 \(String(format: "%.1f", timeSinceUserAction))초 - 주기적 체크 무시")
            return
        }
        
        print("🔄 주기적 상태 체크 실행")
        performStatusCheck()
    }
    
    // MARK: - 상태 체크 메서드들
    private func performStatusCheck() {
        Task {
            await checkDNDStatusAndUpdate()
        }
    }
    
    @MainActor
    private func checkDNDStatusAndUpdate() async {
        let detectedStatus = await checkMultipleDNDMethods()
        
        if let detected = detectedStatus {
            let timeSinceUserAction = Date().timeIntervalSince(lastUserAction)
            
            if detected != self.isFocused {
                if timeSinceUserAction < userActionIgnoreDuration {
                    print("⚠️ 사용자 액션 후 \(String(format: "%.1f", timeSinceUserAction))초 - 상태 변경 무시 (감지된 상태: \(detected ? "활성화" : "비활성화"))")
                    return
                }
                
                print("🔍 시스템에서 집중모드 상태 변경 감지: \(detected ? "활성화" : "비활성화")")
                self.isFocused = detected
            } else {
                print("✅ 집중모드 상태 일치: \(detected ? "활성화" : "비활성화")")
            }
        } else {
            print("❌ 집중모드 상태 감지 실패")
        }
    }
    
    // MARK: - 여러 방법으로 DND 상태 확인
    private func checkMultipleDNDMethods() async -> Bool? {
        print("🔍 여러 방법으로 DND 상태 확인 시작...")
        
        // 방법 1: AppleScript로 직접 확인
        if let status = await checkDNDWithAppleScript() {
            print("📊 AppleScript로 DND 상태 확인: \(status ? "활성화" : "비활성화")")
            return status
        }
        
        // 방법 2: 메뉴바 상태 확인
        if let status = await checkMenuBarDNDStatus() {
            print("📊 메뉴바로 DND 상태 확인: \(status ? "활성화" : "비활성화")")
            return status
        }
        
        // 방법 3: plutil 확인
        if let status = await checkDNDWithPlutil() {
            print("📊 plutil로 DND 상태 확인: \(status ? "활성화" : "비활성화")")
            return status
        }
        
        print("❌ 모든 방법으로 DND 상태 확인 실패")
        return nil
    }
    
    // AppleScript를 사용한 DND 상태 확인 (가장 정확)
    private func checkDNDWithAppleScript() async -> Bool? {
        return await withCheckedContinuation { continuation in
            let script = """
            tell application "System Events"
                try
                    tell process "Control Center"
                        -- 제어센터가 실행중인지 확인하고 DND 상태 확인
                        return true
                    end tell
                on error
                    return false
                end try
            end tell
            """
            
            DispatchQueue.global().async {
                var error: NSDictionary?
                let appleScript = NSAppleScript(source: script)
                let result = appleScript?.executeAndReturnError(&error)
                
                if let error = error {
                    print("❌ AppleScript 실행 오류: \(error)")
                    continuation.resume(returning: nil)
                } else if let descriptor = result {
                    let isActive = descriptor.booleanValue
                    continuation.resume(returning: isActive)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // MARK: - 기존 메뉴바 DND 상태 확인
    private func checkMenuBarDNDStatus() async -> Bool? {
        return await withCheckedContinuation { continuation in
            let task = Process()
            task.launchPath = "/usr/bin/defaults"
            task.arguments = ["read", "com.apple.controlcenter", "NSStatusItem Visible DoNotDisturb"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            task.terminationHandler = { _ in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                if output == "1" || output.lowercased() == "true" {
                    continuation.resume(returning: true)
                } else if output == "0" || output.lowercased() == "false" {
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            do {
                try task.run()
            } catch {
                print("❌ 메뉴바 DND 상태 체크 실패: \(error)")
                continuation.resume(returning: nil)
            }
        }
    }
    
    // plutil을 사용한 DND 상태 확인
    private func checkDNDWithPlutil() async -> Bool? {
        return await withCheckedContinuation { continuation in
            let task = Process()
            task.launchPath = "/usr/bin/defaults"
            task.arguments = ["read", "com.apple.donotdisturb", "userPref"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            task.terminationHandler = { _ in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                // userPref 값이 있으면 DND 활성화
                let hasUserPref = !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                                 !output.contains("does not exist")
                
                continuation.resume(returning: hasUserPref)
            }
            
            do {
                try task.run()
            } catch {
                print("❌ plutil DND 상태 체크 실패: \(error)")
                continuation.resume(returning: nil)
            }
        }
    }
    
    // MARK: - 단축어 실행
    func executeShortcut() {
        let shortcutName = "Toggle DND"
        
        if let encodeName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: "shortcuts://run-shortcut?name=\(encodeName)") {
                NSWorkspace.shared.open(url)
                print("🚀 Toggle DND 실행함")
            } else {
                print("❌ 단축어 URL 생성 실패")
            }
        } else {
            print("❌ 단축어 이름 인코딩 실패")
        }
    }
    
    // MARK: - 수동 상태 체크
    func forceStatusCheck() {
        let timeSinceUserAction = Date().timeIntervalSince(lastUserAction)
        if timeSinceUserAction < userActionIgnoreDuration {
            print("⏰ 사용자 액션 후 \(String(format: "%.1f", timeSinceUserAction))초 - 수동 체크 무시")
            return
        }
        
        print("🔄 수동 상태 체크 실행")
        performStatusCheck()
    }
    
    // MARK: - 디버그용 메서드
    func printCurrentStatus() {
        print("📊 현재 집중모드 상태: \(isFocused ? "활성화" : "비활성화")")
        let timeSinceUserAction = Date().timeIntervalSince(lastUserAction)
        print("⏰ 마지막 사용자 액션으로부터: \(String(format: "%.1f", timeSinceUserAction))초")
    }
    
    // 단축어 테스트 함수
    func testShortcut() {
        print("🧪 단축어 테스트 시작...")
        executeShortcut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            Task {
                let status = await self.checkMultipleDNDMethods()
                print("🧪 단축어 테스트 결과: \(status?.description ?? "감지 실패")")
            }
        }
    }
}
