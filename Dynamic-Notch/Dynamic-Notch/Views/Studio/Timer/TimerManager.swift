//
//  TimerManager.swift
//  Live Peninsula
//
//  Created by PeterPark on 9/14/25.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    
    // MARK: - Published Properties
    @Published var timeRemaining: Int = 25 * 60 // 기본 25분 (1500초)
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var completedSessions: Int = 0
    @Published var isTimerHUDVisible: Bool = false
    
    // MARK: - Timer Properties
    let defaultDuration: Int = 25 * 60  // 기본 25분
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var startTime: Date?
    private var pausedDuration: TimeInterval = 0
    
    private init() {
        setupNotifications()
        print("✅ TimerManager 싱글톤 인스턴스 생성됨")
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Computed Properties
    var minutes: Int {
        timeRemaining / 60
    }
    
    var seconds: Int {
        timeRemaining % 60
    }
    
    var formattedTime: String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        let totalDuration = Double(defaultDuration)
        let elapsed = totalDuration - Double(timeRemaining)
        return min(max(elapsed / totalDuration, 0.0), 1.0)
    }
    
    var isActive: Bool {
        return isRunning || isPaused
    }
    
    // MARK: - Timer Control Methods
    func start() {
        guard !isRunning else { return }
        
        print("⏰ 타이머 시작: \(formattedTime)")
        
        isRunning = true
        isPaused = false
        isTimerHUDVisible = true
        startTime = Date()
        
        // 기존 타이머 정리
        stopTimer()
        
        // 새 타이머 시작
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // 백그라운드에서도 동작하도록 RunLoop에 추가
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
        
        scheduleNotification()
    }
    
    func pause() {
        guard isRunning else { return }
        
        print("⏸️ 타이머 일시정지: \(formattedTime)")
        
        isRunning = false
        isPaused = true
        
        if let startTime = startTime {
            pausedDuration += Date().timeIntervalSince(startTime)
        }
        
        stopTimer()
        cancelNotification()
    }
    
    func resume() {
        guard isPaused else { return }
        
        print("▶️ 타이머 재개: \(formattedTime)")
        start()
    }
    
    func reset() {
        print("🔄 타이머 리셋")
        
        stopTimer()
        cancelNotification()
        
        isRunning = false
        isPaused = false
        isTimerHUDVisible = false
        timeRemaining = defaultDuration
        pausedDuration = 0
        startTime = nil
    }
    
    func stop() {
        print("⏹️ 타이머 정지")
        
        stopTimer()
        cancelNotification()
        
        isRunning = false
        isPaused = false
        isTimerHUDVisible = false
        pausedDuration = 0
        startTime = nil
    }
    
    // MARK: - Session Management (단순화)
    func nextSession() {
        // 타이머 완료 시 카운터 증가 후 리셋
        completedSessions += 1
        reset()
        print("⏰ 타이머 완료 - 총 완료된 세션: \(completedSessions)")
    }
    
    // MARK: - Custom Timer Setup
    func setCustomTime(minutes: Int, seconds: Int = 0) {
        guard !isRunning else {
            print("⚠️ 타이머 실행 중에는 시간을 변경할 수 없습니다")
            return
        }
        
        let totalSeconds = minutes * 60 + seconds
        guard totalSeconds > 0 else { return }
        
        timeRemaining = totalSeconds
        print("⏰ 커스텀 시간 설정: \(minutes)분 \(seconds)초")
    }
    
    // MARK: - Private Methods
    private func updateTimer() {
        guard timeRemaining > 0 else {
            timerCompleted()
            return
        }
        
        timeRemaining -= 1
        
        // 30초, 10초, 5초 남았을 때 알림
        if timeRemaining == 30 || timeRemaining == 10 || timeRemaining == 5 {
            sendTimeWarning(secondsLeft: timeRemaining)
        }
    }
    
    private func timerCompleted() {
        print("✅ 타이머 완료")
        
        stop() // Live Activity도 함께 비활성화됨
        sendCompletionNotification()
        
        // 자동으로 다음 세션 제안 (자동 시작하지 않음)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // UI에서 다음 세션으로 전환할지 사용자에게 물어볼 수 있음
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Notification Methods
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 알림 권한 허용됨")
            } else {
                print("❌ 알림 권한 거부됨: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func scheduleNotification() {
        guard timeRemaining > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "타이머"
        content.body = "타이머가 완료되었습니다!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeRemaining), repeats: false)
        let request = UNNotificationRequest(identifier: "timer_completion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 스케줄링 실패: \(error.localizedDescription)")
            } else {
                print("✅ 완료 알림 스케줄링됨: \(self.timeRemaining)초 후")
            }
        }
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_completion"])
    }
    
    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 타이머 완료!"
        content.body = "타이머가 끝났습니다. 잘하셨어요!"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "session_completed", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 완료 알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendTimeWarning(secondsLeft: Int) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ 시간 알림"
        content.body = "타이머가 \(secondsLeft)초 남았습니다!"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "time_warning_\(secondsLeft)", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 경고 알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Debug Methods
    func printStatus() {
        print("""
        📊 TimerManager 상태:
        - 남은 시간: \(formattedTime)
        - 실행 중: \(isRunning)
        - 일시정지: \(isPaused)
        - 완료된 세션: \(completedSessions)
        - 진행률: \(String(format: "%.1f", progress * 100))%
        """)
    }
}
