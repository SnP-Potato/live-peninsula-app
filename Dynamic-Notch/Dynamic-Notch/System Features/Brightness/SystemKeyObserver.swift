//
//  BrightnessKeyObserver.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/27/25.
//


import Cocoa

class BrightnessKeyMonitor {
    static let shared = BrightnessKeyMonitor()
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var debugMode: Bool = false
    
    // 키 반복 방지를 위한 디바운스
    private var lastKeyTime: Date = Date.distantPast
    private let debounceInterval: TimeInterval = 0.2
    
    private init() {}
    
    func startMonitoring() {
        print("🔍 밝기 키 모니터링 시작...")
        
        // 접근성 권한 확인
        let trusted = AXIsProcessTrusted()
        if !trusted {
            print("❌ 접근성 권한이 필요합니다!")
            print("시스템 환경설정 > 보안 및 개인정보보호 > 개인정보보호 > 손쉬운 사용에서 Dynamic Notch를 허용해주세요.")
            return
        }
        
        print("✅ 접근성 권한 확인됨")
        
        // 디버그 모드 활성화 (처음에는 모든 키 로깅)
        enableDebugMode()
        
        // 글로벌 키 이벤트 모니터 (다른 앱이 활성화되어 있을 때)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        // 로컬 키 이벤트 모니터 (내 앱이 활성화되어 있을 때)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
        
        print("✅ 밝기 키 모니터링 활성화됨")
    }
    
    func stopMonitoring() {
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
        
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
        
        print("🛑 밝기 키 모니터링 중지")
    }
    
    func enableDebugMode() {
        debugMode = true
        print("🐛 디버그 모드 활성화 - 모든 키 이벤트를 로깅합니다")
    }
    
    func disableDebugMode() {
        debugMode = false
        print("🐛 디버그 모드 비활성화")
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let now = Date()
        let keyCode = event.keyCode
        let modifierFlags = event.modifierFlags
        
        // 디버그 모드일 때 모든 키 로깅
        if debugMode {
            let char = event.charactersIgnoringModifiers ?? "nil"
            print("🔑 Key: \(keyCode) (\(char)) - Modifiers: \(modifierFlags.rawValue)")
        }
        
        // 디바운스 처리
        guard now.timeIntervalSince(lastKeyTime) > debounceInterval else {
            return
        }
        
        // 밝기 키 감지 (다양한 방법으로)
        var isBrightnessKey = false
        var brightnessDirection: String = ""
        
        // 방법 1: 표준 F1, F2 키
        if keyCode == 122 { // F1 (밝기 다운)
            isBrightnessKey = true
            brightnessDirection = "down"
        } else if keyCode == 120 { // F2 (밝기 업)
            isBrightnessKey = true
            brightnessDirection = "up"
        }
        
        // 방법 2: Fn 키와 조합
        else if modifierFlags.contains(.function) {
            switch keyCode {
            case 122, 120:
                isBrightnessKey = true
                brightnessDirection = keyCode == 122 ? "down" : "up"
            default:
                break
            }
        }
        
        // 방법 3: 다양한 키보드의 밝기 키들
        else {
            switch keyCode {
            case 107, 113: // 일부 키보드의 F1, F2
                isBrightnessKey = true
                brightnessDirection = keyCode == 107 ? "down" : "up"
            case 144: // F15 (일부 키보드)
                isBrightnessKey = true
                brightnessDirection = "down"
            case 145: // F14 (일부 키보드)
                isBrightnessKey = true
                brightnessDirection = "up"
            case 53: // ESC 키 (테스트용)
                print("🧪 ESC 키로 밝기 테스트")
                isBrightnessKey = true
                brightnessDirection = "test"
            default:
                break
            }
        }
        
        if isBrightnessKey {
            lastKeyTime = now
            
            print("🔆 밝기 키 감지됨: \(brightnessDirection) (keyCode: \(keyCode))")
            
            // 알림 전송
            NotificationCenter.default.post(
                name: NSNotification.Name("BrightnessKeyPressed"),
                object: nil,
                userInfo: [
                    "keyCode": keyCode,
                    "direction": brightnessDirection
                ]
            )
            
            // 5초 후 디버그 모드 자동 비활성화
            if debugMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.disableDebugMode()
                }
            }
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
