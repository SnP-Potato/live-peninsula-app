//
//  TimerManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/28/25.
//

import Foundation


class TimerManager: NSObject,  ObservableObject {
    @Published var process: CGFloat = 1
    @Published var value: String = "00:00"
    @Published var hour: Int = 0
    @Published var min: Int = 0
    @Published var second: Int = 0
    
    @Published var isRun: Bool = false
    private var timer: Timer?
    private var totalTime: Int = 0
    private var remainingTime: Int = 0
    
    override init() {
        super.init()
    }
    
    func startTimer() {
        guard !isRun else { return }
        
        totalTime = hour * 3600 + min * 60 + second
        remainingTime = totalTime
        
        guard totalTime > 0 else { return }
        
        isRun = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func pauseTimer() {
        isRun = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        isRun = false
        timer?.invalidate()
        timer = nil
        
        remainingTime = totalTime
        process = 1.0
        updateDisplayValue()
    }
    
    private func updateTimer() {
        guard remainingTime > 0 else {
            timerFinished()
            return
        }
        
        remainingTime -= 1
        
        // Progress 업데이트 (1.0에서 0.0으로)
        if totalTime > 0 {
            process = CGFloat(remainingTime) / CGFloat(totalTime)
        }
        
        updateDisplayValue()
    }
    
    private func updateDisplayValue() {
        let hours = remainingTime / 3600
        let minutes = (remainingTime % 3600) / 60
        let seconds = remainingTime % 60
        
        if hours > 0 {
            value = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            value = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func timerFinished() {
        isRun = false
        timer?.invalidate()
        timer = nil
        process = 0.0
        value = "00:00"
        
        // 타이머 완료 시 알림이나 다른 액션을 여기에 추가
        print("Timer finished!")
        // TODO: 알림 소리, 진동, 알림 등 추가
    }
    
    deinit {
        timer?.invalidate()
    }
}
