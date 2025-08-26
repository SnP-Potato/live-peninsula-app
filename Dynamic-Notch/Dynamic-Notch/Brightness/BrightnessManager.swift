//
//  BrightnessManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//

// MARK: - 오류 수정된 BrightnessManager.swift
import Foundation
import Combine
import IOKit
import ApplicationServices  // AXIsProcessTrustedWithOptions를 위해 필요

class BrightnessManager: ObservableObject {
    static let shared = BrightnessManager()
    
    @Published var currentBrightness: Float = 0.5
    @Published var isBrightnessHUDVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var hideTimer: Timer?
    private var brightnessMethod: BrightnessMethod = .unknown
    
    private enum BrightnessMethod {
        case unknown
        case corebrightnessdiag
        case shell_command
        case failed
    }
    
    private init() {
        print("BrightnessManager 초기화 - 권한 테스트 시작")
        testPermissions()
        updateBrightnessState()
        startMonitoring()
    }
    
    // MARK: - 권한 테스트
    func testPermissions() {
        print("=== 권한 테스트 시작 ===")
        
        // 1. 파일 존재 확인
        let path = "/usr/libexec/corebrightnessdiag"
        let fileExists = FileManager.default.fileExists(atPath: path)
        print("파일 존재: \(fileExists)")
        
        // 2. 파일 권한 확인
        if fileExists {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                print("파일 권한: \(attributes[.posixPermissions] ?? "Unknown")")
            } catch {
                print("권한 확인 실패: \(error)")
            }
        }
        
        // 3. 실행 테스트
        testCoreBrightnessExecution()
    }
    
    private func testCoreBrightnessExecution() {
        print("=== corebrightnessdiag 실행 테스트 ===")
        
        // 방법 1: Process로 직접 실행
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/libexec/corebrightnessdiag")
        task.arguments = ["status-info"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            print("종료 코드: \(task.terminationStatus)")
            print("데이터 크기: \(data.count) bytes")
            
            if let output = String(data: data, encoding: .utf8) {
                print("출력 미리보기: \(String(output.prefix(200)))")
            }
            
            if task.terminationStatus == 0 {
                print("✅ Process 방식 성공")
                parseCoreBrightnessOutput(data: data)
            } else {
                print("❌ Process 방식 실패")
                tryShellCommand()
            }
        } catch {
            print("❌ Process 실행 실패: \(error)")
            tryShellCommand()
        }
    }
    
    private func tryShellCommand() {
        print("=== shell 명령어 시도 ===")
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", "/usr/libexec/corebrightnessdiag status-info"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            print("Shell 종료 코드: \(task.terminationStatus)")
            
            if task.terminationStatus == 0 {
                print("✅ Shell 방식 성공")
                brightnessMethod = .shell_command
                parseCoreBrightnessOutput(data: data)
            } else {
                print("❌ Shell 방식도 실패")
                brightnessMethod = .failed
            }
        } catch {
            print("❌ Shell 실행 실패: \(error)")
            brightnessMethod = .failed
        }
    }
    
    private func parseCoreBrightnessOutput(data: Data) {
        do {
            guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                print("PropertyList 파싱 실패")
                return
            }
            
            print("성공! plist 키들: \(Array(plist.keys))")
            
            if let displays = plist["CBDisplays"] as? [String: [String: Any]] {
                print("CBDisplays 발견: \(displays.count)개")
                
                for (key, display) in displays {
                    print("디스플레이: \(key)")
                    if let displayInfo = display["Display"] as? [String: Any] {
                        let isBuiltIn = displayInfo["DisplayServicesIsBuiltInDisplay"] as? Bool ?? false
                        if let brightness = displayInfo["DisplayServicesBrightness"] as? Float {
                            print("  내장: \(isBuiltIn), 밝기: \(brightness)")
                            if isBuiltIn {
                                DispatchQueue.main.async {
                                    self.currentBrightness = brightness
                                }
                            }
                        }
                    }
                }
            }
            
            brightnessMethod = .corebrightnessdiag
        } catch {
            print("파싱 실패: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func showBrightnessHUD() {
        updateBrightnessState()
        
        DispatchQueue.main.async {
            self.isBrightnessHUDVisible = true
        }
        
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            DispatchQueue.main.async {
                self.isBrightnessHUDVisible = false
            }
        }
    }
    
    func hideBrightnessHUD() {
        DispatchQueue.main.async {
            self.isBrightnessHUDVisible = false
        }
    }
    
    // MARK: - Private Methods
    private func updateBrightnessState() {
        DispatchQueue.global(qos: .userInitiated).async {
            let brightness = self.getSystemBrightness()
            
            DispatchQueue.main.async {
                self.currentBrightness = brightness
            }
        }
    }
    
    private func startMonitoring() {
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.checkBrightnessChanges()
            }
            .store(in: &cancellables)
    }
    
    private func checkBrightnessChanges() {
        guard brightnessMethod != .failed else { return }
        
        DispatchQueue.global(qos: .background).async {
            let newBrightness = self.getSystemBrightness()
            
            DispatchQueue.main.async {
                if abs(newBrightness - self.currentBrightness) > 0.01 {
                    print("밝기 변화: \(self.currentBrightness) → \(newBrightness)")
                    self.currentBrightness = newBrightness
                    self.showBrightnessHUD()
                }
            }
        }
    }
    
    private func getSystemBrightness() -> Float {
        switch brightnessMethod {
        case .unknown, .failed:
            return currentBrightness
            
        case .corebrightnessdiag:
            return getCoreBrightnessBrightness() ?? currentBrightness
            
        case .shell_command:
            return getCoreBrightnessFromShell() ?? currentBrightness
        }
    }
    
    private func getCoreBrightnessBrightness() -> Float? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/libexec/corebrightnessdiag")
        task.arguments = ["status-info"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard task.terminationStatus == 0 else { return nil }
            
            return extractBrightnessFromData(data: data)
        } catch {
            return nil
        }
    }
    
    private func getCoreBrightnessFromShell() -> Float? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", "/usr/libexec/corebrightnessdiag status-info"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard task.terminationStatus == 0 else { return nil }
            
            return extractBrightnessFromData(data: data)
        } catch {
            return nil
        }
    }
    
    private func extractBrightnessFromData(data: Data) -> Float? {
        do {
            guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
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
        } catch {
            print("데이터 추출 실패: \(error)")
        }
        
        return nil
    }
    
    deinit {
        hideTimer?.invalidate()
    }
}

// MARK: - 권한 요청 도우미
extension BrightnessManager {
    
    func requestPermissionsIfNeeded() {
        // Accessibility 권한 체크 (수정된 버전)
        let options: [String: Any] = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            print("⚠️ Accessibility 권한이 필요합니다")
            
            DispatchQueue.main.async {
                // NSAlert 대신 print로 대체 (import Cocoa가 없어서)
                print("권한 필요: 밝기 제어를 위해 Accessibility 권한이 필요합니다.")
            }
        }
    }
}

// MARK: - 간단한 테스트 함수
extension BrightnessManager {
    func testBrightnessHUD() {
        print("테스트 HUD 표시")
        DispatchQueue.main.async {
            self.isBrightnessHUDVisible = true
        }
    }
}
