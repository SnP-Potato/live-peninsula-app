//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct StudioPlaceholder: View {
    
    @State private var isTimer: Bool = false
    @State private var isMemo: Bool = false
    @State private var currentActivity: ActivityFeatures = .none
    @State private var isRecord: Bool = false
    @State private var isHovered: Bool = false
    
    @State private var musicCardclick: Bool = false
    @EnvironmentObject var focusManager: FocusManager // 상태 계속 유지ㅣ하기윟ㅎ
    @EnvironmentObject var recordManager: RecordManager
    @EnvironmentObject var timerManager: TimerManager
    
    enum ActivityFeatures {
        case none
        case memo
        case timer
    }
    
    var body: some View {
        HStack(spacing: 0) {
            //도합 width: 462 height: 150
            Spacer()
                .frame(width: 20)
            
            HStack(spacing: 12) {
                // MARK: 음악제어
                VStack {
                    Button(action: {
                        musicCardclick.toggle()
                    }, label: {
                        MusicCardView(musicCardclick: $musicCardclick)
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 100, height: 3)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(.white)
                                .frame(width: 100 * 0.6) // 60%
                        }
                        .cornerRadius(1.5)
                }
                    
                
                // MARK: 캘린더
                HStack(alignment: .center, spacing: 12) {
                    
                    VStack {
                        Text("Jal")
                            .font(.system(size: 20, weight: .heavy))
                        
                        Circle()
                            .fill(.blue)
                            
                            .frame(width: 35, height: 35)
                            .overlay {
                                Text("4")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                    }
                    
                    HStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            Circle()
                                .fill(.green.opacity(0.2))
                                .opacity(0.5)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .light))
                                }
                        }
                    }
                }
                .frame(width: 140)
            }
            .frame(width: 242)
            
            Spacer()
                
            
            // MARK: 단축어 모음
            VStack(alignment: .trailing, spacing: 10) {
                Circle()
                    .fill(.white.opacity(0.1))
                    .opacity(0.5)
                    .onHover { hovered in
                        isHovered = hovered
                    }
                    .frame(width: isHovered ? 180 : 70, height: isHovered ? 130 : 70)
                    .animation(.bouncy(duration: 0.4, extraBounce: 0.2), value: isHovered)
            }
            .frame(width: 200, height: 150)
            
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var DefaultView: some View {
        // 메모 영역
        Button(action: {
            isMemo = true
            currentActivity = .memo
        }) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 180, height: 42)
                .foregroundColor(Color("3buttonColor"))
                .opacity(0.5)
                .overlay {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil.and.scribble")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Text("Start Writing...")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Spacer()
                        
                        Text("31")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.horizontal, 10)
                }
        }
        .buttonStyle(PlainButtonStyle())
        
        // 집중모드
        HStack(spacing: 20) {
            // 집중모드 - 글로벌 상태 사용
            Button(action: {
                focusManager.toggleFocusMode()
            }) {
                Circle()
                    .fill(focusManager.isFocused ? Color.blue.opacity(0.3) : Color("3buttonColor"))
                    .opacity(0.3)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(focusManager.isFocused ? .blue : .blue)
                            .font(.system(size: 16))
                    }
            }
            .buttonStyle(PlainButtonStyle())
            
            //  타이머
            Button(action: {
                isTimer = true
                currentActivity = .timer
            }) {
                Circle()
                    .fill(isTimer ? Color.orange.opacity(0.3) : Color("3buttonColor"))
                    .opacity(0.5)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "timer")
                            .foregroundStyle(.orange)
                            .font(.system(size: 16))
                    }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 화면 녹화 - 간단한 토글
            Button(action: {
                recordManager.toggleRecordMode()
            }) {
                Circle()
                    .fill(recordManager.isRecord ? Color.red.opacity(0.3) : Color("3buttonColor"))
                    .opacity(0.5)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: isRecord ? "record.circle.fill" : "record.circle")
                            .foregroundStyle(recordManager.isRecord ? .red : .red)
                            .font(.system(size: 20))
                    }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @ViewBuilder
    private var SelectedFeatureView: some View {
        VStack {
            
            HStack {
                Spacer()
                
                Button(action: {
                    resetToDefaultView()
                }, label: {
                    Image(systemName: "x.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                })
                .buttonStyle(PlainButtonStyle())
            }
            
            Group {
                switch currentActivity {
                case .none:
                    EmptyView()
                case .memo:
                    MemoFeatureView()
                case .timer:
                    TimerFeatureView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
        }
    }
    
    private func resetToDefaultView() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentActivity = .none
            isMemo = false
            isTimer = false
        }
    }
}

// MARK: - 각 기능별 뷰들
struct MemoFeatureView: View {
    var body: some View {
        VStack {
            Text("메모")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Text("메모 기능이 여기에 표시됩니다")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}



struct StudioPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(currentTab: .constant(.studio))
            .environmentObject(NotchViewModel())
            .environmentObject(FocusManager.shared)
            .environmentObject(TimerManager.shared)
            .environmentObject(RecordManager.shared)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: onNotchSize.width, height: onNotchSize.height)
            .background(Color.black)
            .clipShape(NotchShape(cornerRadius: 20))
    }
}

