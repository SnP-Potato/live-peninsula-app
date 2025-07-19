//
//  TimerView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/18/25.
//
//
//  TimerView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/18/25.
//

import SwiftUI

struct TimerView: View {
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var isRunning: Bool = false
    @State private var isInputMode: Bool = true
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.1))
            
            HStack(spacing: 8) {
                VStack(spacing: 8) {
                    Image("Group 50")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    
                    Text("Timer")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(height: 80)
                
                // 오른쪽 - 시간과 버튼들
                VStack(spacing: 12) {
                    // 시간 표시/입력
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white.opacity(0.2))
                        .frame(width: 120, height: 34)
                        .overlay {
                            if isInputMode {
                                // 입력 모드 - 시간과 분만
                                HStack(spacing: 4) {
                                    // 시간 입력
                                    TextField("00", text: Binding(
                                        get: { String(format: "%02d", hours) },
                                        set: { newValue in
                                            if let intValue = Int(newValue) {
                                                hours = max(0, min(23, intValue))
                                            }
                                        }
                                    ))
                                    .frame(width: 30)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    
                                    Text(":")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    // 분 입력
                                    TextField("00", text: Binding(
                                        get: { String(format: "%02d", minutes) },
                                        set: { newValue in
                                            if let intValue = Int(newValue) {
                                                minutes = max(0, min(59, intValue))
                                            }
                                        }
                                    ))
                                    .frame(width: 30)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    
                                    Text(": 00")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            } else {
                                // 카운트다운 표시
                                Text(formatTime(remainingSeconds))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(remainingSeconds <= 10 ? .red : .white)
                                    .animation(.easeInOut, value: remainingSeconds)
                            }
                        }
                    
                    // 버튼들
                    HStack(spacing: 18) {
                        Button(action: {
                            resetTimer()
                        }) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.2))
                                .frame(width: 45, height: 25)
                                .overlay {
                                    Text("Reset")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            if isRunning {
                                pauseTimer()
                            } else {
                                startTimer()
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.2))
                                .frame(width: 37, height: 25)
                                .overlay {
                                    Text(isRunning ? "Pause" : "Start")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        if isInputMode {
            // 입력된 시간을 총 초로 변환 (시간과 분만)
            totalSeconds = hours * 3600 + minutes * 60
            remainingSeconds = totalSeconds
            
            if totalSeconds <= 0 {
                return // 시간이 설정되지 않으면 시작하지 않음
            }
            
            isInputMode = false
        }
        
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                // 타이머 완료
                timerCompleted()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isInputMode = true
        remainingSeconds = 0
        totalSeconds = 0
        hours = 0
        minutes = 0
    }
    
    private func timerCompleted() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        // 타이머 완료 알림
        print("Timer completed!")
        
        // 3초 후 자동으로 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            resetTimer()
        }
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d : %02d : %02d", hours, minutes, seconds)
    }
}

#Preview {
    TimerView()
        .frame(width: 480, height: 500)
}
//import SwiftUI
//
//struct TimerView: View {
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 8)
//                .fill(.black.opacity(0.1))
//            
//            HStack(spacing: 8) {
//                VStack(spacing: 8) {
//                    Image("Group 50")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 40, height: 40)
//                    
//                    Text("Timer")
//                        .font(.system(size: 10, weight: .bold))
//                        .foregroundColor(.white)
//                }
//                .frame(height: 80)
//                
//                // 오른쪽 - 시간과 버튼들
//                VStack(spacing: 12) {
//                    // 시간 표시
//                    RoundedRectangle(cornerRadius: 6)
//                        .fill(.white.opacity(0.2))
//                        .frame(width: 120, height: 34)
//                        .overlay {
//                            Text("00 : 00 : 00")
//                                .font(.system(size: 18, weight: .bold))
//                                .foregroundColor(.white)
//                        }
//                    
//                    // 버튼들
//                    HStack(spacing: 18) {
//                        Button(action: {
//                            
//                        }) {
//                            RoundedRectangle(cornerRadius: 4)
//                                .fill(.white.opacity(0.2))
//                                .frame(width: 45, height: 25)
//                                .overlay {
//                                    Text("Restart")
//                                        .font(.system(size: 10, weight: .semibold))
//                                        .foregroundColor(.white)
//                                }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        
//                        Button(action: {
//                            
//                        }) {
//                            RoundedRectangle(cornerRadius: 4)
//                                .fill(.white.opacity(0.2))
//                                .frame(width: 37, height: 25)
//                                .overlay {
//                                    Text("Start")
//                                        .font(.system(size: 10, weight: .semibold))
//                                        .foregroundColor(.white)
//                                }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//            }
//            .padding(.horizontal, 8)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//#Preview {
//    TimerView()
//        .frame(width: 480, height:  500)
//        
//}
