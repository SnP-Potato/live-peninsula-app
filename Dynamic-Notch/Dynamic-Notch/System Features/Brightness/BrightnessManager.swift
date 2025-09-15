//
//  BrightnessManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//


import SwiftUI
import Combine
import IOKit.graphics
import CoreGraphics

class BrightnessManager: ObservableObject {
    static let shared = BrightnessManager()
    
    @Published var currentBrightness: Float = 0.5
    @Published var isBrightnessHUDVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var hideTimer: Timer?
    private var updateTimer: Timer?
    
    // 밝기 변화 감지를 위한 변수들
    private var previousBrightness: Float = 0.5
    private var method: BrightnessMethod = .standard
    
    // 성능 최적화를 위한 변수들
    private var lastUpdateTime: Date = Date()
    private let updateThrottleInterval: TimeInterval = 0.05 // 50ms
    
    private init() {
        print("🔆 BrightnessManager 초기화 시작...")
        initializeBrightness()
        startKeyEventMonitoring()
        print("✅ BrightnessManager 초기화 완료")
    }
    
    // MARK: - Initialization
    private func initializeBrightness() {
        // 초기 밝기 값 설정 및 최적 방법 감지
        DispatchQueue.global(qos: .utility).async {
            let brightness = self.detectAndGetBrightness()
            DispatchQueue.main.async {
                self.currentBrightness = brightness
                self.previousBrightness = brightness
                print("🔆 초기 밝기: \(Int(brightness * 100))% (방법: \(self.method))")
            }
        }
    }
    
    // MARK: - Public Methods
    func showBrightnessHUD() {
        print("🔆 밝기 HUD 표시 요청")
        
        // 연속 업데이트 시작 (키 입력 후 실제 밝기 변화 반영)
        startContinuousUpdate()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isBrightnessHUDVisible = true
        }
        
        // 기존 타이머 취소 및 새 타이머 설정
        resetHideTimer()
    }
    
    func hideBrightnessHUD() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isBrightnessHUDVisible = false
        }
        stopContinuousUpdate()
    }
    
    func setBrightness(_ brightness: Float) {
        let clampedBrightness = max(0.0, min(1.0, brightness))
        
        DispatchQueue.global(qos: .userInitiated).async {
            switch self.method {
            case .standard:
                self.setStandardBrightness(clampedBrightness)
            case .m1:
                self.setM1Brightness(clampedBrightness)
            case .appleScript:
                self.setAppleScriptBrightness(clampedBrightness)
            case .failed:
                print("❌ 밝기 설정 불가능 - 지원되지 않는 시스템")
            }
            
            DispatchQueue.main.async {
                self.currentBrightness = clampedBrightness
                self.showBrightnessHUD()
            }
        }
    }
    
    func increaseBrightness(step: Float = 0.1) {
        setBrightness(currentBrightness + step)
    }
    
    func decreaseBrightness(step: Float = 0.1) {
        setBrightness(currentBrightness - step)
    }
    
    // MARK: - Private Methods
    
    private func startKeyEventMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(brightnessKeyPressed),
            name: NSNotification.Name("BrightnessKeyPressed"),
            object: nil
        )
        print("🎯 밝기 키 이벤트 모니터링 시작")
    }
    
    @objc private func brightnessKeyPressed() {
        print("🔆 밝기 키 감지됨 - HUD 표시")
        showBrightnessHUD()
    }
    
    private func resetHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.isBrightnessHUDVisible = false
            }
            print("🔆 밝기 HUD 자동 숨김")
        }
    }
    
    private func startContinuousUpdate() {
        stopContinuousUpdate()
        
        // 더 빠른 간격으로 업데이트 (키 입력 반응성 향상)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.updateBrightnessState()
        }
        
        // 1초 후 업데이트 중지
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.stopContinuousUpdate()
        }
    }
    
    private func stopContinuousUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateBrightnessState() {
        // 스로틀링으로 성능 최적화
        let now = Date()
        guard now.timeIntervalSince(lastUpdateTime) >= updateThrottleInterval else { return }
        lastUpdateTime = now
        
        DispatchQueue.global(qos: .userInitiated).async {
            let brightness = self.getSystemBrightness()
            
            DispatchQueue.main.async {
                // 의미있는 변화만 업데이트 (1% 이상)
                if abs(brightness - self.currentBrightness) > 0.01 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.currentBrightness = brightness
                    }
                    print("🔆 밝기 업데이트: \(Int(brightness * 100))%")
                }
            }
        }
    }
    
    // MARK: - Brightness Detection and Getting
    
    private func detectAndGetBrightness() -> Float {
        // 1차: Standard 방법 시도 (Intel Mac)
        if let brightness = tryStandardBrightness() {
            method = .standard
            print("✅ Standard 방법 사용 (Intel Mac)")
            return brightness
        }
        
        // 2차: M1 방법 시도 (Apple Silicon)
        if let brightness = tryM1Brightness() {
            method = .m1
            print("✅ M1 방법 사용 (Apple Silicon)")
            return brightness
        }
        
        // 3차: AppleScript 방법 시도 (최후의 수단)
        if let brightness = tryAppleScriptBrightness() {
            method = .appleScript
            print("⚠️ AppleScript 방법 사용 (성능 저하 가능)")
            return brightness
        }
        
        // 모든 방법 실패
        method = .failed
        print("❌ 모든 밝기 감지 방법 실패")
        return 0.5
    }
    
    private func getSystemBrightness() -> Float {
        switch method {
        case .standard:
            return tryStandardBrightness() ?? fallbackToDifferentMethod()
        case .m1:
            return tryM1Brightness() ?? fallbackToDifferentMethod()
        case .appleScript:
            return tryAppleScriptBrightness() ?? currentBrightness
        case .failed:
            return currentBrightness
        }
    }
    
    private func fallbackToDifferentMethod() -> Float {
        // 현재 방법이 실패하면 다른 방법으로 전환
        print("⚠️ 현재 방법(\(method)) 실패, 다른 방법 시도")
        return detectAndGetBrightness()
    }
    
    // MARK: - Standard Method (Intel Mac)
    
    private func tryStandardBrightness() -> Float? {
        var brightness: float_t = 0.5
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                IOServiceMatching("IODisplayConnect"))
        defer {
            if service != 0 {
                IOObjectRelease(service)
            }
        }
        
        guard service != 0 else { return nil }
        
        let result = IODisplayGetFloatParameter(service, 0,
                                              kIODisplayBrightnessKey as CFString, &brightness)
        guard result == kIOReturnSuccess else { return nil }
        
        return brightness
    }
    
    private func setStandardBrightness(_ brightness: Float) {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                IOServiceMatching("IODisplayConnect"))
        defer {
            if service != 0 {
                IOObjectRelease(service)
            }
        }
        
        guard service != 0 else {
            print("❌ IODisplayConnect 서비스를 찾을 수 없음")
            return
        }
        
        let result = IODisplaySetFloatParameter(service, 0,
                                              kIODisplayBrightnessKey as CFString, brightness)
        if result != kIOReturnSuccess {
            print("❌ Standard 방법으로 밝기 설정 실패")
        } else {
            print("✅ Standard 방법으로 밝기 설정: \(Int(brightness * 100))%")
        }
    }
    
    // MARK: - M1 Method (Apple Silicon)
    
    private func tryM1Brightness() -> Float? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/libexec/corebrightnessdiag")
        task.arguments = ["status-info"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe() // 에러 출력 무시
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard task.terminationStatus == 0 else { return nil }
            
            return parseM1BrightnessData(data)
        } catch {
            return nil
        }
    }
    
    private func parseM1BrightnessData(_ data: Data) -> Float? {
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? NSDictionary,
              let displays = plist["CBDisplays"] as? [String: [String: Any]] else {
            return nil
        }
        
        for display in displays.values {
            if let displayInfo = display["Display"] as? [String: Any],
               displayInfo["DisplayServicesIsBuiltInDisplay"] as? Bool == true,
               let brightness = displayInfo["DisplayServicesBrightness"] as? Float {
                return brightness
            }
        }
        
        return nil
    }
    
    private func setM1Brightness(_ brightness: Float) {
        // M1에서는 직접 설정이 제한적이므로 시뮬레이션
        print("⚠️ M1 Mac에서 직접 밝기 설정은 제한적입니다")
        
        // 여기에 M1 전용 밝기 설정 로직 구현 가능
        // 예: 시스템 환경설정 자동화, 또는 다른 API 사용
    }
    
    // MARK: - AppleScript Method (Fallback)
    
    private func tryAppleScriptBrightness() -> Float? {
        // 성능상 이유로 AppleScript는 최후의 수단으로만 사용
        print("⚠️ AppleScript 방법은 성능상 권장되지 않습니다")
        return nil
    }
    
    private func setAppleScriptBrightness(_ brightness: Float) {
        let script = """
            tell application "System Events"
                key code 107 using {shift down} -- F1 키 (밝기 다운) 시뮬레이션
            end tell
            """
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            
            if let error = error {
                print("❌ AppleScript 실행 실패: \(error)")
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func getBrightnessPercentage() -> Int {
        return Int(currentBrightness * 100)
    }
    
    func setBrightnessPercentage(_ percentage: Int) {
        let brightness = Float(max(0, min(100, percentage))) / 100.0
        setBrightness(brightness)
    }
    
    func getCurrentMethod() -> BrightnessMethod {
        return method
    }
    
    func isBrightnessControlAvailable() -> Bool {
        return method != .failed
    }
    
    deinit {
        hideTimer?.invalidate()
        updateTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Supporting Types
enum BrightnessMethod: String, CaseIterable {
    case standard = "Standard (Intel Mac)"
    case m1 = "CoreBrightness (Apple Silicon)"
    case appleScript = "AppleScript (Fallback)"
    case failed = "Not Available"
}

enum BrightnessError: Error {
    case standardFailed
    case m1Failed
    case appleScriptFailed
    case notFound
    case permissionDenied
    
    var localizedDescription: String {
        switch self {
        case .standardFailed:
            return "Standard IOKit method failed"
        case .m1Failed:
            return "CoreBrightness method failed"
        case .appleScriptFailed:
            return "AppleScript method failed"
        case .notFound:
            return "No brightness control method found"
        case .permissionDenied:
            return "Permission denied for brightness control"
        }
    }
}

// MARK: - Extension for Convenience
extension BrightnessManager {
    
    /// 시스템 정보 출력 (디버깅용)
    func printSystemInfo() {
        print("\n=== 밝기 제어 시스템 정보 ===")
        print("현재 방법: \(method.rawValue)")
        print("현재 밝기: \(getBrightnessPercentage())%")
        print("제어 가능 여부: \(isBrightnessControlAvailable() ? "Yes" : "No")")
        print("=============================\n")
    }
    
    /// 모든 방법 테스트 (디버깅용)
    func testAllMethods() {
        print("\n🧪 모든 밝기 제어 방법 테스트")
        
        for method in BrightnessMethod.allCases {
            switch method {
            case .standard:
                let result = tryStandardBrightness()
                print("Standard: \(result != nil ? "✅ \(Int((result ?? 0) * 100))%" : "❌ Failed")")
            case .m1:
                let result = tryM1Brightness()
                print("M1: \(result != nil ? "✅ \(Int((result ?? 0) * 100))%" : "❌ Failed")")
            case .appleScript:
                let result = tryAppleScriptBrightness()
                print("AppleScript: \(result != nil ? "✅ \(Int((result ?? 0) * 100))%" : "❌ Failed")")
            case .failed:
                break
            }
        }
    }
}
