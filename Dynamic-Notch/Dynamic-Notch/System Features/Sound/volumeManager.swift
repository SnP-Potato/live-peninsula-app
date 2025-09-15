//
//  volumeManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//

import SwiftUI
import Combine

class VolumeManager: ObservableObject {
    static let shared = VolumeManager()
    
    @Published var currentVolume: Float = 0.5
    @Published var isMuted: Bool = false
    @Published var isVolumeHUDVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var hideTimer: Timer?
    
    private init() {
        updateVolumeState()
        startMonitoring()
    }
    
    // MARK: - Public Methods
    func showVolumeHUD() {
        updateVolumeState()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isVolumeHUDVisible = true
        }
        
        // 기존 타이머 취소
        hideTimer?.invalidate()
        
        // 2초 후 자동 숨김
        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.isVolumeHUDVisible = false
            }
        }
    }
    
    func hideVolumeHUD() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isVolumeHUDVisible = false
        }
    }
    
    // MARK: - Private Methods
    private func updateVolumeState() {
        DispatchQueue.global(qos: .userInitiated).async {
            let volume = self.getSystemVolume()
            let muted = self.getSystemMutedState()
            
            DispatchQueue.main.async {
                self.currentVolume = volume
                self.isMuted = muted
            }
        }
    }
    
    private func startMonitoring() {
        // 0.2초마다 볼륨 상태 체크
        Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.checkVolumeChanges()
            }
            .store(in: &cancellables)
    }
    
    private func checkVolumeChanges() {
        DispatchQueue.global(qos: .background).async {
            let newVolume = self.getSystemVolume()
            let newMuted = self.getSystemMutedState()
            
            DispatchQueue.main.async {
                // 변화 감지 (미세한 변화 무시)
                let volumeChanged = abs(newVolume - self.currentVolume) > 0.01
                let mutedChanged = newMuted != self.isMuted
                
                if volumeChanged || mutedChanged {
                    self.currentVolume = newVolume
                    self.isMuted = newMuted
                    self.showVolumeHUD()
                }
            }
        }
    }
    
    private func getSystemVolume() -> Float {
        do {
            let script = "return output volume of (get volume settings)"
            if let volumeString = try AppleScriptRunner.run(script: script),
               let volume = Float(volumeString) {
                return volume / 100.0
            }
        } catch {
            print("❌ 볼륨 가져오기 실패: \(error)")
        }
        return currentVolume
    }
    
    private func getSystemMutedState() -> Bool {
        do {
            let script = "return output muted of (get volume settings)"
            if let mutedString = try AppleScriptRunner.run(script: script) {
                return mutedString == "true"
            }
        } catch {
            print("❌ 음소거 상태 가져오기 실패: \(error)")
        }
        return isMuted
    }
    
    deinit {
        hideTimer?.invalidate()
    }
}
