//
//  MusicProgressBar.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/15/25.
//

//
//  MusicProgressBar.swift - boringNotch 스타일 개선 버전
//  Dynamic-Notch
//
//  Created by PeterPark on 8/15/25.
//

//
//  MusicProgressBar.swift - boringNotch 스타일 개선 버전 + 부드러운 진행
//  Dynamic-Notch
//
//  Created by PeterPark on 8/15/25.
//

import SwiftUI

struct MusicProgressBar: View {
    @EnvironmentObject var musicManager: MusicManager
    @State private var sliderValue: Double = 0
    @State private var isDragging: Bool = false
    @State private var isHovering: Bool = false
    @State private var lastDragged: Date = .distantPast
    
    // ✅ 부드러운 애니메이션을 위한 타이머 속성
    @State private var lastUpdateTime: Date = Date()
    @State private var smoothSliderValue: Double = 0  // 부드러운 애니메이션용
    
    private let barHeight: CGFloat = 4
    private let hoveringBarHeight: CGFloat = 6
    private let draggingBarHeight: CGFloat = 8
    private let barWidth: CGFloat = 100
    
    // 현재 바 높이 계산
    private var currentBarHeight: CGFloat {
        if isDragging {
            return draggingBarHeight
        } else if isHovering {
            return hoveringBarHeight
        } else {
            return barHeight
        }
    }
    
    // ✅ 더 정확한 현재 경과 시간 계산
    private var currentElapsedTime: Double {
        // 드래그 중일 때는 드래그 값 사용
        guard !isDragging else {
            return sliderValue
        }
        
        // 최근에 드래그했다면 그 값 사용
        guard Date().timeIntervalSince(lastDragged) > 1.0 else {
            return sliderValue
        }
        
        // 재생 중일 때만 실시간 계산
        guard musicManager.isPlaying && musicManager.duration > 0 else {
            return musicManager.currentTime
        }
        
        // 부드러운 실시간 계산
        let now = Date()
        let timeDifference = now.timeIntervalSince(musicManager.lastUpdated)
        let calculatedTime = musicManager.currentTime + timeDifference
        
        return min(max(calculatedTime, 0), musicManager.duration)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // ✅ 더 자주 업데이트하는 TimelineView (60fps 대신 30fps로 부드럽게)
            TimelineView(.animation(minimumInterval: 0.033)) { timeline in  // ~30fps
                progressBarView
                    .onChange(of: timeline.date) { _, currentTime in
                        updateProgressSmooth(currentTime: currentTime)
                    }
            }
        }
        .onAppear {
            initializeProgress()
        }
        .onChange(of: musicManager.currentTime) { _, newTime in
            handleMusicTimeChange(newTime)
        }
        .onChange(of: musicManager.duration) { _, _ in
            handleSongChange()
        }
        .onChange(of: musicManager.isPlaying) { _, _ in
            handlePlayStateChange()
        }
    }
    
    // MARK: - Progress Update Logic
    
    private func updateProgressSmooth(currentTime: Date) {
        guard !isDragging else { return }
        
        let targetTime = currentElapsedTime
        let timeDelta = currentTime.timeIntervalSince(lastUpdateTime)
        lastUpdateTime = currentTime
        
        // ✅ 부드러운 보간 (linear interpolation)
        if musicManager.isPlaying && abs(targetTime - smoothSliderValue) < 5.0 {
            // 재생 중이고 시간 차이가 크지 않을 때 부드럽게 보간
            let lerpSpeed: Double = 8.0  // 보간 속도 (높을수록 빠르게)
            let difference = targetTime - smoothSliderValue
            smoothSliderValue += difference * min(timeDelta * lerpSpeed, 1.0)
        } else {
            // 큰 시간 점프나 정지 상태일 때는 즉시 동기화
            smoothSliderValue = targetTime
        }
        
        // sliderValue를 부드럽게 업데이트
        withAnimation(.linear(duration: 0.033)) {  // 다음 프레임까지의 시간
            sliderValue = smoothSliderValue
        }
    }
    
    private func initializeProgress() {
        sliderValue = musicManager.currentTime
        smoothSliderValue = musicManager.currentTime
        lastUpdateTime = Date()
        print("🔍 MusicProgressBar 로드됨 - 초기 시간: \(formatTime(musicManager.currentTime))")
    }
    
    private func handleMusicTimeChange(_ newTime: Double) {
        // 큰 시간 변화가 있을 때만 강제 동기화 (seek, 곡 변경 등)
        if !isDragging && abs(newTime - sliderValue) > 2.0 {
            print("🔄 시간 동기화: \(formatTime(sliderValue)) -> \(formatTime(newTime))")
            withAnimation(.easeOut(duration: 0.5)) {  // ✅ 부드러운 동기화 애니메이션
                sliderValue = newTime
                smoothSliderValue = newTime
            }
        }
    }
    
    private func handleSongChange() {
        // 새 곡으로 변경 시 리셋
        if musicManager.currentTime == 0 {
            withAnimation(.easeOut(duration: 0.3)) {
                sliderValue = 0
                smoothSliderValue = 0
            }
        }
    }
    
    private func handlePlayStateChange() {
        // 재생 상태 변경 시 즉시 동기화
        smoothSliderValue = currentElapsedTime
        lastUpdateTime = Date()
    }
    
    // MARK: - Progress Bar Visual
    private var progressBarView: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = currentBarHeight
            let progress = musicManager.duration > 0 ? (sliderValue / musicManager.duration) : 0
            let filledWidth = min(max(progress * width, 0), width)
            
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(.white.opacity(musicManager.hasActiveMedia ? 0.3 : 0.1))
                    .frame(height: height)
                
                // Progress track - ✅ 더 부드러운 애니메이션
                Capsule()
                    .fill(progressTrackColor)
                    .frame(width: max(2, filledWidth), height: height)
                    .shadow(
                        color: musicManager.isPlaying ? .white.opacity(0.5) : .clear,
                        radius: isDragging ? 4 : isHovering ? 3 : 2
                    )
                    // ✅ 부드러운 진행 애니메이션
                    .animation(.linear(duration: musicManager.isPlaying ? 0.033 : 0.2), value: filledWidth)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isHovering)
            .contentShape(Rectangle())
            .onHover { hovering in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    isHovering = hovering
                }
            }
            .gesture(progressDragGesture(geometry: geometry))
        }
        .frame(width: barWidth, height: max(barHeight, hoveringBarHeight, draggingBarHeight))
    }
    
    // MARK: - Progress Track Color
    private var progressTrackColor: Color {
        if !musicManager.hasActiveMedia {
            return .white.opacity(0.2)
        } else if musicManager.isPlaying {
            return .white.opacity(isHovering ? 1.0 : 0.9)
        } else {
            return .white.opacity(isHovering ? 0.8 : 0.7)
        }
    }
    
    // MARK: - Drag Gesture
    private func progressDragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                handleDragChange(gesture, geometry: geometry)
            }
            .onEnded { gesture in
                handleDragEnd(gesture, geometry: geometry)
            }
    }
    
    // MARK: - Drag Handlers
    private func handleDragChange(_ gesture: DragGesture.Value, geometry: GeometryProxy) {
        // 드래그 시작
        if !isDragging {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isDragging = true
            }
            print("🎯 Progress bar 드래그 시작")
        }
        
        // 위치 계산
        let progress = max(0, min(gesture.location.x / geometry.size.width, 1.0))
        let newTime = progress * musicManager.duration
        
        // ✅ 드래그 중에는 즉시 반영 (애니메이션 없이)
        withAnimation(.none) {
            sliderValue = newTime
            smoothSliderValue = newTime
        }
    }
    
    private func handleDragEnd(_ gesture: DragGesture.Value, geometry: GeometryProxy) {
        guard musicManager.duration > 0 else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isDragging = false
            }
            return
        }
        
        let finalProgress = max(0, min(gesture.location.x / geometry.size.width, 1.0))
        let seekTime = finalProgress * musicManager.duration
        
        print("🎯 Progress bar 드래그 완료 - 최종 seek: \(formatTime(seekTime))")
        
        // 실제 seek 실행
        musicManager.seek(to: seekTime)
        lastDragged = Date()
        lastUpdateTime = Date()
        
        // 드래그 상태 해제
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isDragging = false
        }
    }
    
    // MARK: - Helper Functions
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return String(format: "%d:%02d:%02d", hours, remainingMinutes, remainingSeconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 재생 중 상태
        MusicProgressBar()
            .environmentObject({
                let manager = MusicManager.shared
                manager.songTitle = "Heat Waves"
                manager.artistName = "Glass Animals"
                manager.isPlaying = true
                manager.currentTime = 125
                manager.duration = 240
                return manager
            }())
        
        // 정지 상태
        MusicProgressBar()
            .environmentObject({
                let manager = MusicManager.shared
                manager.songTitle = "Blinding Lights"
                manager.artistName = "The Weeknd"
                manager.isPlaying = false
                manager.currentTime = 60
                manager.duration = 200
                return manager
            }())
    }
    .padding()
    .background(.black)
    .frame(width: 200, height: 150)
}
