//
//  TimerView.swift
//  Live Peninsula
//
//  Created by PeterPark on 9/14/25.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var timerManager = TimerManager.shared
    @State private var hapticFeedback = false
    
    var body: some View {
        VStack(spacing: 12) {
//            VStack(alignment: .leading) {
//                Text("Pomodoro")
//                    .font(.system(size: 12, weight: .bold, design: .rounded))
//            }
            // 시간 표시 (큰 글씨로)
            Text(timerManager.formattedTime)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
                .animation(.easeInOut(duration: 0.2), value: timerManager.timeRemaining)
            
            // 제어ㅓㅂ정튼
            HStack(spacing: 20) {
                // 재생/일시정지 버튼
                Button(action: {
                    if timerManager.isRunning {
                        timerManager.pause()
                    } else if timerManager.isPaused {
                        timerManager.resume()
                    } else {
                        timerManager.start()
                    }
                    hapticFeedback.toggle()
                }) {
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.1))
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 리셋 버튼
                Button(action: {
                    timerManager.reset()
                    hapticFeedback.toggle()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.1))
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 120, height: 110)
        .padding(.bottom, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(.orange.opacity(0.1))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .strokeBorder(.orange.opacity(0.3), lineWidth: 1)
//                )
//        )
        .sensoryFeedback(.impact(flexibility: .soft), trigger: hapticFeedback)
        .contextMenu {
            contextMenu
        }
    }
    
    // MARK: - Context Menu (시간 설정만)
    @ViewBuilder
    private var contextMenu: some View {
        Button("5분으로 설정") {
            timerManager.setCustomTime(minutes: 5)
            hapticFeedback.toggle()
        }
        
        Button("25분으로 설정") {
            timerManager.setCustomTime(minutes: 25)
            hapticFeedback.toggle()
        }
        
        Button("45분으로 설정") {
            timerManager.setCustomTime(minutes: 45)
            hapticFeedback.toggle()
        }
        
        Divider()
        
        Button("리셋", role: .destructive) {
            timerManager.reset()
        }
    }
}

// MARK: - Preview
#Preview {
    TimerView()
        .padding()
        .background(.black)
        .frame(width: 200, height: 200)
}
