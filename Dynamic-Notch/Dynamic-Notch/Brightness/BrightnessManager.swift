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
    
    private init() {
        updateBrightnessState()
        startKeyEventMonitoring()
    }
    
    // MARK: - Public Methods
    func showBrightnessHUD() {
        // 밝기 키를 누른 직후에는 실제 밝기 값이 즉시 반영되지 않을 수 있으므로
        // 짧은 시간 동안 지속적으로 업데이트
        startContinuousUpdate()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isBrightnessHUDVisible = true
        }
        
        // 기존 타이머 취소
        hideTimer?.invalidate()
        
        // 1.5초 후 자동 숨김
        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.isBrightnessHUDVisible = false
            }
        }
    }
    
    func hideBrightnessHUD() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isBrightnessHUDVisible = false
        }
        stopContinuousUpdate()
    }
    
    // MARK: - Private Methods
    
    private func startKeyEventMonitoring() {
        // 밝기 키 이벤트 감지를 위한 Notification 설정
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(brightnessKeyPressed),
            name: NSNotification.Name("BrightnessKeyPressed"),
            object: nil
        )
    }
    
    @objc private func brightnessKeyPressed() {
        print("밝기 키 감지됨")
        showBrightnessHUD()
    }
    
    private func startContinuousUpdate() {
        stopContinuousUpdate()
        
        // 0.1초마다 밝기 값 업데이트 (키 입력 후 실제 변경까지 시간이 걸림)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateBrightnessState()
        }
        
        // 0.5초 후 타이머 정지
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.stopContinuousUpdate()
        }
    }
    
    private func stopContinuousUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateBrightnessState() {
        DispatchQueue.global(qos: .userInitiated).async {
            let brightness = self.getSystemBrightness()
            
            DispatchQueue.main.async {
                self.currentBrightness = brightness
            }
        }
    }
    
    private func getSystemBrightness() -> Float {
        switch method {
        case .standard:
            do {
                return try getStandardDisplayBrightness()
            } catch {
                method = .m1
                return getSystemBrightness()
            }
        case .m1:
            do {
                return try getM1DisplayBrightness()
            } catch {
                method = .failed
                return currentBrightness
            }
        case .failed:
            return currentBrightness
        }
    }
    
    // MARK: - Intel Mac용 밝기 가져오기
    private func getStandardDisplayBrightness() throws -> Float {
        var brightness: float_t = 0.5
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                IOServiceMatching("IODisplayConnect"))
        defer {
            IOObjectRelease(service)
        }
        
        let result = IODisplayGetFloatParameter(service, 0,
                                              kIODisplayBrightnessKey as CFString, &brightness)
        if result != kIOReturnSuccess {
            throw BrightnessError.standardFailed
        }
        return brightness
    }
    
    // MARK: - Apple Silicon Mac용 밝기 가져오기
    private func getM1DisplayBrightness() throws -> Float {
        let task = Process()
        task.launchPath = "/usr/libexec/corebrightnessdiag"
        task.arguments = ["status-info"]
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
        } catch {
            throw BrightnessError.m1Failed
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? NSDictionary,
              let displays = plist["CBDisplays"] as? [String: [String: Any]] else {
            throw BrightnessError.m1Failed
        }
        
        for display in displays.values {
            if let displayInfo = display["Display"] as? [String: Any],
               displayInfo["DisplayServicesIsBuiltInDisplay"] as? Bool == true,
               let brightness = displayInfo["DisplayServicesBrightness"] as? Float {
                return brightness
            }
        }
        
        throw BrightnessError.m1Failed
    }
    
    deinit {
        hideTimer?.invalidate()
        updateTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Supporting Types
enum BrightnessMethod {
    case standard
    case m1
    case failed
}

enum BrightnessError: Error {
    case standardFailed
    case m1Failed
    case notFound
}
