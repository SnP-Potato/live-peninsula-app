//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

//import SwiftUI
//
//struct StudioPlaceholder: View {
//    
//    @State private var isTimer: Bool = false
//    @State private var isMemo: Bool = false
//    @State private var currentActivity: ActivityFeatures = .none
//    @State private var isRecord: Bool = false
//    @State private var isHovered: Bool = false
//    
//    @State private var musicCardclick: Bool = false
//    @EnvironmentObject var focusManager: FocusManager // 상태 계속 유지ㅣ하기윟ㅎ
//    @EnvironmentObject var recordManager: RecordManager
//    @EnvironmentObject var timerManager: TimerManager
//    @EnvironmentObject var calendarManager: CalendarManager
//    @EnvironmentObject var musicManager: MusicManager
//    
//    enum ActivityFeatures {
//        case none
//        case memo
//        case timer
//    }
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            //도합 width: 462 height: 150
//            
//            // MARK: 음악제어
//            VStack(spacing: 6) {
//                Button(action: {
//                    musicCardclick.toggle()
//                }, label: {
//                    MusicCardView(musicCardclick: $musicCardclick)
//                })
//                .buttonStyle(PlainButtonStyle())
//                
////                Rectangle()
////                    .fill(.white.opacity(0.1))
////                    .frame(width: 100, height: 3)
////                    .overlay(alignment: .leading) {
////                        Rectangle()
////                            .fill(.white)
////                            .frame(width: 100 * 0.6) // 60%
////                    }
////                    .cornerRadius(1.5)
//                // 진행바
//                musicProgressBar
//            }
//            .frame(width: 110, height: 120)
//            
//            Spacer()
//                .frame(width: 18)
//            
//            // MARK: 캘린더
//            VStack(alignment: .leading, spacing: 0) { // alignment를 .leading으로, spacing을 0으로
//                CalendarView()
//                
//            }
//            .frame(width: 170, height: 130, alignment: .center)
//            
//            Spacer()
//                .frame(width: 18)
//            
//            // MARK: 단축어 모음
//            
//            Rectangle()
//                .fill(.white.opacity(0.1))
//                .opacity(0.5)
//                .frame(width:150, height: 110)
//                .cornerRadius(8)
//                .overlay {
//                    ShortcutWheelPicker()
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .clipped()
//                }
//        }
//        .frame(width: 500, height: 130)
//        .padding(.vertical, 8)
//    }
//    // MARK: - 음악 진행도 바 (개선된 버전)
//    @ViewBuilder
//    private var musicProgressBar: some View {
//        VStack(spacing: 2) {
//            // 디버깅을 위한 텍스트 (임시)
//            if musicManager.hasActiveMedia {
//                Text("\(formatTime(musicManager.currentTime)) / \(formatTime(musicManager.duration))")
//                    .font(.system(size: 8))
//                    .foregroundColor(.gray)
//            }
//            
//            TimelineView(.animation(minimumInterval: 0.5)) { timeline in
//                let progress = calculateProgress(currentDate: timeline.date)
//                
//                ZStack(alignment: .leading) {
//                    // 배경 바
//                    Rectangle()
//                        .fill(.white.opacity(0.2))
//                        .frame(width: 100, height: 4) // 높이를 4로 증가
//                        .cornerRadius(2)
//                    
//                    // 진행도 바
//                    Rectangle()
//                        .fill(getProgressBarColor())
//                        .frame(width: max(2, 100 * progress), height: 4) // 최소 2픽셀은 보이도록
//                        .cornerRadius(2)
//                        .animation(.easeInOut(duration: 0.3), value: progress)
//                }
//            }
//        }
//    }
//    
//    // 진행도 바 색상 결정
//    private func getProgressBarColor() -> Color {
//        if !musicManager.hasActiveMedia {
//            return .white.opacity(0.3)
//        } else if musicManager.isPlaying {
//            return .white
//        } else {
//            return .white.opacity(0.7)
//        }
//    }
//    
//    // 시간 포맷팅 함수
//    private func formatTime(_ seconds: Double) -> String {
//        let minutes = Int(seconds) / 60
//        let remainingSeconds = Int(seconds) % 60
//        return String(format: "%d:%02d", minutes, remainingSeconds)
//    }
//    
//    // 실시간 진행도 계산 (개선된 버전)
//    private func calculateProgress(currentDate: Date) -> Double {
//        // 음악이 없거나 길이가 0이면 진행도 0
//        guard musicManager.duration > 0 else {
//            return 0.0
//        }
//        
//        // 재생 중일 때는 실시간으로 시간 업데이트
//        let currentTime: Double
//        if musicManager.isPlaying && musicManager.hasActiveMedia {
//            let timeSinceLastUpdate = currentDate.timeIntervalSince(musicManager.lastUpdated)
//            currentTime = min(musicManager.currentTime + timeSinceLastUpdate, musicManager.duration)
//        } else {
//            currentTime = musicManager.currentTime
//        }
//        
//        let progress = currentTime / musicManager.duration
//        return min(max(progress, 0.0), 1.0)
//    }
//    
//    // MARK: 단축어 기본화면 보여주는 View(아직 아무 상태 없을때
//    @ViewBuilder
//    private var DefaultView: some View {
//        // 메모 영역
//        Button(action: {
//            isMemo = true
//            currentActivity = .memo
//        }) {
//            RoundedRectangle(cornerRadius: 8)
//                .frame(width: 180, height: 42)
//                .foregroundColor(Color("3buttonColor"))
//                .opacity(0.5)
//                .overlay {
//                    HStack(spacing: 8) {
//                        Image(systemName: "pencil.and.scribble")
//                            .font(.system(size: 11))
//                            .foregroundColor(.gray.opacity(0.7))
//                        
//                        Text("Start Writing...")
//                            .font(.system(size: 11))
//                            .foregroundColor(.gray.opacity(0.7))
//                        
//                        Spacer()
//                        
//                        Text("31")
//                            .font(.system(size: 11, weight: .medium))
//                            .foregroundColor(.gray.opacity(0.7))
//                    }
//                    .padding(.horizontal, 10)
//                }
//        }
//        .buttonStyle(PlainButtonStyle())
//        
//        // 집중모드
//        HStack(spacing: 20) {
//            // 집중모드 - 글로벌 상태 사용
//            Button(action: {
//                focusManager.toggleFocusMode()
//            }) {
//                Circle()
//                    .fill(focusManager.isFocused ? Color.blue.opacity(0.3) : Color("3buttonColor"))
//                    .opacity(0.3)
//                    .frame(width: 40, height: 40)
//                    .overlay {
//                        Image(systemName: "moon.fill")
//                            .foregroundStyle(focusManager.isFocused ? .blue : .blue)
//                            .font(.system(size: 16))
//                    }
//            }
//            .buttonStyle(PlainButtonStyle())
//            
//            //  타이머
//            Button(action: {
//                isTimer = true
//                currentActivity = .timer
//            }) {
//                Circle()
//                    .fill(isTimer ? Color.orange.opacity(0.3) : Color("3buttonColor"))
//                    .opacity(0.5)
//                    .frame(width: 40, height: 40)
//                    .overlay {
//                        Image(systemName: "timer")
//                            .foregroundStyle(.orange)
//                            .font(.system(size: 16))
//                    }
//            }
//            .buttonStyle(PlainButtonStyle())
//            
//            // 화면 녹화 - 간단한 토글
//            Button(action: {
//                recordManager.toggleRecordMode()
//            }) {
//                Circle()
//                    .fill(recordManager.isRecord ? Color.red.opacity(0.3) : Color("3buttonColor"))
//                    .opacity(0.5)
//                    .frame(width: 40, height: 40)
//                    .overlay {
//                        Image(systemName: isRecord ? "record.circle.fill" : "record.circle")
//                            .foregroundStyle(recordManager.isRecord ? .red : .red)
//                            .font(.system(size: 20))
//                    }
//            }
//            .buttonStyle(PlainButtonStyle())
//        }
//    }
//    
//    // MARK: 특정 단축어 기능이 활성화될떄 보여주는 View
//    @ViewBuilder
//    private var SelectedFeatureView: some View {
//        VStack {
//            
//            HStack {
//                Spacer()
//                
//                Button(action: {
//                    resetToDefaultView()
//                }, label: {
//                    Image(systemName: "x.circle")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.gray)
//                })
//                .buttonStyle(PlainButtonStyle())
//            }
//            
//            Group {
//                switch currentActivity {
//                case .none:
//                    EmptyView()
//                case .memo:
//                    MemoFeatureView()
//                case .timer:
//                    TimerFeatureView()
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            
//            Spacer()
//        }
//    }
//    
//    // MARK: 특정 단축어 기능을 비활성화 할때 다시 기본화면로 돌려주는 함수 (서로 독립적인 상태 관리하기 위해)
//    private func resetToDefaultView() {
//        withAnimation(.easeInOut(duration: 0.2)) {
//            currentActivity = .none
//            isMemo = false
//            isTimer = false
//        }
//    }
//}
//
//extension StudioPlaceholder {
//    // Replace the existing musicProgressBar with this:
//    @ViewBuilder
//    var enhancedMusicProgressBar: some View {
//        VStack(spacing: 6) {
//            // Music Card Button
//            Button(action: {
//                musicCardclick.toggle()
//            }, label: {
//                MusicCardView(musicCardclick: $musicCardclick)
//            })
//            .buttonStyle(PlainButtonStyle())
//            
//            // Enhanced Progress Bar
//            EnhancedMusicProgressBar()
//                .environmentObject(musicManager)
//        }
//        .frame(width: 110, height: 120)
//    }
//}
//
//// MARK: - 각 기능별 뷰들
//struct MemoFeatureView: View {
//    var body: some View {
//        VStack {
//            Text("메모")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.white)
//            Text("메모 기능이 여기에 표시됩니다")
//                .font(.system(size: 10))
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//        }
//    }
//}
//
//struct StudioPlaceholder_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(currentTab: .constant(.studio))
//            .environmentObject(NotchViewModel())
//            .environmentObject(FocusManager.shared)
//            .environmentObject(TimerManager.shared)
//            .environmentObject(RecordManager.shared)
//            .environmentObject(CalendarManager.shared)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .frame(width: onNotchSize.width, height: onNotchSize.height)
//            .background(Color.black)
//            .clipShape(NotchShape(cornerRadius: 20))
//    }
//}


import SwiftUI

struct StudioPlaceholder: View {
    
    @State private var isTimer: Bool = false
    @State private var isMemo: Bool = false
    @State private var currentActivity: ActivityFeatures = .none
    @State private var isRecord: Bool = false
    @State private var isHovered: Bool = false
    
    @State private var musicCardclick: Bool = false
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var recordManager: RecordManager
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var musicManager: MusicManager
    
    enum ActivityFeatures {
        case none
        case memo
        case timer
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: 음악 제어 (스마트 진행바 적용)
            VStack(spacing: 6) {
                Button(action: {
                    musicCardclick.toggle()
                }, label: {
                    MusicCardView(musicCardclick: $musicCardclick)
                })
                .buttonStyle(PlainButtonStyle())
                
                // 새로운 스마트 진행바
                smartMusicProgressBar
            }
            .frame(width: 110, height: 120)
            
            Spacer()
                .frame(width: 18)
            
            // MARK: 캘린더
            VStack(alignment: .leading, spacing: 0) {
                CalendarView()
            }
            .frame(width: 170, height: 130, alignment: .center)
            
            Spacer()
                .frame(width: 18)
            
            // MARK: 단축어 모음
//            Rectangle()
//                .fill(.white.opacity(0.1))
//                .opacity(0.5)
//                .frame(width:150, height: 110)
//                .cornerRadius(8)
//                .overlay {
//                    Group {
//                        if currentActivity == .none {
//                            DefaultView
//                        } else {
//                            SelectedFeatureView
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .clipped()
//                }
            
            ShortcutWheelPicker()
        }
        .frame(width: 500, height: 130)
        .padding(.vertical, 8)
    }
    
    // MARK: - 스마트 진행바 (우리만의 독특한 방식)
    @ViewBuilder
    var smartMusicProgressBar: some View {
        VStack(spacing: 4) {
            // 메인 스마트 진행바
            CompactMusicProgressBar()
                .environmentObject(musicManager)
        }
    }
    
    // MARK: 단축어 기본화면
    @ViewBuilder
    private var DefaultView: some View {
        VStack(spacing: 12) {
            // 메모 영역
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isMemo = true
                    currentActivity = .memo
                }
            }) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 130, height: 32)
                    .foregroundColor(Color("3buttonColor"))
                    .opacity(0.5)
                    .overlay {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.and.scribble")
                                .font(.system(size: 10))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Text("Start Writing...")
                                .font(.system(size: 10))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Spacer()
                            
                            Text("31")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.horizontal, 8)
                    }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 버튼들
            HStack(spacing: 15) {
                // 집중모드
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        focusManager.toggleFocusMode()
                    }
                }) {
                    Circle()
                        .fill(focusManager.isFocused ? Color.blue.opacity(0.3) : Color("3buttonColor"))
                        .opacity(0.3)
                        .frame(width: 35, height: 35)
                        .overlay {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(focusManager.isFocused ? .blue : .blue)
                                .font(.system(size: 14))
                        }
                        .scaleEffect(focusManager.isFocused ? 1.1 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                
                // 타이머
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isTimer = true
                        currentActivity = .timer
                    }
                }) {
                    Circle()
                        .fill(isTimer ? Color.orange.opacity(0.3) : Color("3buttonColor"))
                        .opacity(0.5)
                        .frame(width: 35, height: 35)
                        .overlay {
                            Image(systemName: "timer")
                                .foregroundStyle(.orange)
                                .font(.system(size: 14))
                        }
                }
                .buttonStyle(PlainButtonStyle())
                
                // 화면 녹화
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        recordManager.toggleRecordMode()
                    }
                }) {
                    Circle()
                        .fill(recordManager.isRecord ? Color.red.opacity(0.3) : Color("3buttonColor"))
                        .opacity(0.5)
                        .frame(width: 35, height: 35)
                        .overlay {
                            Image(systemName: recordManager.isRecord ? "record.circle.fill" : "record.circle")
                                .foregroundStyle(recordManager.isRecord ? .red : .red)
                                .font(.system(size: 18))
                        }
                        .scaleEffect(recordManager.isRecord ? 1.1 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: 선택된 기능 화면
    @ViewBuilder
    private var SelectedFeatureView: some View {
        VStack(spacing: 8) {
            // 닫기 버튼
            HStack {
                Spacer()
                
                Button(action: {
                    resetToDefaultView()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray.opacity(0.8))
                })
                .buttonStyle(PlainButtonStyle())
            }
            
            // 기능별 컨텐츠
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
        .padding(.horizontal, 8)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: 기본 화면으로 돌아가기
    private func resetToDefaultView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentActivity = .none
            isMemo = false
            isTimer = false
        }
    }
}

// MARK: - 기능별 뷰들
struct MemoFeatureView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "pencil.and.scribble")
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.8))
            
            Text("메모")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
            
            Text("메모 기능 활성화")
                .font(.system(size: 9))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

//struct TimerFeatureView: View {
//    var body: some View {
//        VStack(spacing: 6) {
//            Image(systemName: "timer")
//                .font(.system(size: 20))
//                .foregroundStyle(.orange)
//            
//            Text("타이머")
//                .font(.system(size: 12, weight: .semibold))
//                .foregroundStyle(.white)
//            
//            Text("25:00")
//                .font(.system(size: 11, weight: .medium, design: .monospaced))
//                .foregroundStyle(.orange)
//        }
//    }
//}

// MARK: - 컴팩트 스마트 진행바 (대안)
struct CompactMusicProgressBar: View {
    @EnvironmentObject var musicManager: MusicManager
    @State private var isHovering = false
    @State private var previewPosition: Double = 0
    
    var body: some View {
        VStack(spacing: 3) {
            // 진행바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경
                    Capsule()
                        .fill(.white.opacity(0.2))
                    
                    // 진행 트랙
                    Capsule()
                        .fill(.white)
                        .frame(width: max(2, geometry.size.width * musicManager.playbackProgress))
                    
                    // 호버 포인터
                    if isHovering {
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                            .position(
                                x: geometry.size.width * previewPosition,
                                y: geometry.size.height / 2
                            )
                            .shadow(color: .white, radius: 1)
                    }
                }
            }
            .frame(height: isHovering ? 6 : 4)
            .contentShape(Rectangle())
            .onHover { hovering in
                withAnimation(.spring(response: 0.3)) {
                    isHovering = hovering
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let position = max(0, min(value.location.x / 100, 1.0))
                        previewPosition = position
                        isHovering = true
                    }
                    .onEnded { value in
                        let position = max(0, min(value.location.x / 100, 1.0))
                        let seekTime = position * musicManager.duration
                        musicManager.seek(to: seekTime)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isHovering = false
                        }
                    }
            )
            
            // 시간 표시
//            if musicManager.hasActiveMedia {
//                HStack {
//                    Text(musicManager.formattedCurrentTime)
//                        .font(.system(size: 7, weight: .medium))
//                        .foregroundColor(.gray)
//                    
//                    Spacer()
//                    
//                    Text(musicManager.formattedDuration)
//                        .font(.system(size: 7, weight: .medium))
//                        .foregroundColor(.gray)
//                }
//                .frame(width: 100)
//            }
        }
    }
}

struct StudioPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        StudioPlaceholder()
            .environmentObject(FocusManager.shared)
            .environmentObject(TimerManager.shared)
            .environmentObject(RecordManager.shared)
            .environmentObject(CalendarManager.shared)
            .environmentObject(MusicManager.shared)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: 500, height: 130)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
