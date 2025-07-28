//
//  TimerFeatureView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/28/25.
//

//import SwiftUI
//
//struct TimerFeatureView: View {
//    @EnvironmentObject var timerManager: TimerManager
//    var body: some View {
//        HStack {
//            VStack {
//                //타이머 링
//                GeometryReader{ proxy in
//                    VStack(spacing: 15) {
//                        ZStack {
//                            Circle()
//                                .fill(.white.opacity(0.03))
//                                .padding(-10)
//                                
//                            
//                            Circle()
//                                .trim(from: 0, to: 0.5)
//                                .stroke(Color.orange.opacity(0.7), lineWidth: 8)
//                                .blur(radius: 15)
//                                .padding(1)
//                           
//                            Circle()
//                                .trim(from: 0, to: timerManager.process * 360 )
//                                .stroke(Color.orange.opacity(0.7), lineWidth: 8)
//                            
//                            Text(timerManager.value)
//                                .font(.system(size: 25, weight: .light))
//                                .rotationEffect(.init(degrees: -120))
//                                .animation(.none, value: timerManager.process)
//                        }
//                        .padding(30)
//                        .rotationEffect(.init(degrees: 120))
//                        .animation(.easeInOut, value: timerManager.process)
//                        
//                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                }
//            }
//            .frame(width: 180)
//            
//            VStack(spacing: 12) {
//                
//                Spacer()
//                
//                HStack {
//                    Button(action: {
//                        //
//                    }, label: {
//                        Text("\(timerManager.hour) hr")
//                            .font(.system(size: 17, weight: .medium))
//                        
//                    })
//                    
//                    
//                    Button(action: {
//                        //
//                    }, label: {
//                        Text("\(timerManager.min) min")
//                            .font(.system(size: 17, weight: .medium))
//                    })
//                    
//                    Button(action: {
//                        //
//                    }, label: {
//                        Text("\(timerManager.second) sec")
//                            .font(.system(size: 17, weight: .medium))
//                    })
//                    
//                }
//                
//                HStack {
//                    Button(action: {
//                        timerManager.isRun = true
//                    }, label: {
//                        Circle()
//                            .fill(.orange.opacity(0.3))
//                            .opacity(0.4)
//                            .frame(width: 50, height: 50)
//                            .overlay {
//                                Text("Reset")
//                                    .foregroundColor(.orange.opacity(0.3))
//                            }
//                    })
//                    .buttonStyle(PlainButtonStyle())
//                    .padding(.horizontal)
//                    
//                    Button(action: {
//                        timerManager.isRun = true
//                    }, label: {
//                        Circle()
//                            .fill(.green.opacity(0.3))
//                            .opacity(0.4)
//                            .frame(width: 50, height: 50)
//                            .overlay {
//                                Text("Start")
//                                    .foregroundColor(.green.opacity(0.3))
//                            }
//                    })
//                    .buttonStyle(PlainButtonStyle())
//                    .padding(.horizontal)
//                }
//                
//                Spacer()
//            }
//        }
//        
//    }
//}
//
//#Preview {
//    TimerFeatureView( )
//        .environmentObject(TimerManager())
//        .frame(width: onNotchSize.width, height: onNotchSize.height)
//        .background(Color.black)
//}

//
//  TimerFeatureView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/28/25.
//

import SwiftUI

struct TimerFeatureView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 20) {
            // 타이머 링
            VStack {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.03))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 6)
                        .blur(radius: 8)
                        .frame(width: 120, height: 120)
                   
                    Circle()
                        .trim(from: 0, to: timerManager.process)
                        .stroke(Color.orange, lineWidth: 6)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    Text(timerManager.value)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                }
                .animation(.easeInOut, value: timerManager.process)
            }
            
            // 컨트롤 패널
            VStack(spacing: 16) {
                // 시간 설정 피커들
                HStack(spacing: 12) {
                    // 시간 피커
                    VStack(spacing: 2) {
                        Text("hr")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(0..<24, id: \.self) { hour in
                                Button("\(hour) hr") {
                                    timerManager.hour = hour
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(timerManager.hour)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 20)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // 분 피커
                    VStack(spacing: 2) {
                        Text("min")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(0..<60, id: \.self) { minute in
                                Button("\(minute) min") {
                                    timerManager.min = minute
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(timerManager.min)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 20)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // 초 피커
                    VStack(spacing: 2) {
                        Text("sec")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(0..<60, id: \.self) { second in
                                Button("\(second) sec") {
                                    timerManager.second = second
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(timerManager.second)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 20)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // 컨트롤 버튼들
                HStack(spacing: 12) {
                    Button(action: {
                        resetTimer()
                    }) {
                        Circle()
                            .fill(.orange.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14))
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        if timerManager.isRun {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Circle()
                            .fill(.green.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: timerManager.isRun ? "pause.fill" : "play.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .onChange(of: timerManager.hour) { _, _ in updateTimerValue() }
        .onChange(of: timerManager.min) { _, _ in updateTimerValue() }
        .onChange(of: timerManager.second) { _, _ in updateTimerValue() }
        .onAppear {
            updateTimerValue()
        }
    }
    
    private func updateTimerValue() {
        let totalSeconds = timerManager.hour * 3600 + timerManager.min * 60 + timerManager.second
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            timerManager.value = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            timerManager.value = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func startTimer() {
        timerManager.startTimer()
    }
    
    private func pauseTimer() {
        timerManager.pauseTimer()
    }
    
    private func resetTimer() {
        timerManager.resetTimer()
    }
}

#Preview {
    TimerFeatureView()
        .environmentObject(TimerManager())
        .frame(width: 400, height: 200)
        .background(Color.black)
}
