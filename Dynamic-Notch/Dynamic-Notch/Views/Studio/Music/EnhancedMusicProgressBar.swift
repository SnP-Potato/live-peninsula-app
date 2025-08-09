//
//  EnhancedMusicProgressBar.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/9/25.
//



import SwiftUI

struct EnhancedMusicProgressBar: View {
    @EnvironmentObject var musicManager: MusicManager
    @State private var isDragging = false
    @State private var dragPosition: Double = 0
    @State private var dragStartTime: Date = Date()
    
    private let barHeight: CGFloat = 4
    private let barWidth: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 4) {
            // Progress Bar
            progressBarView
            
            // Time Labels
            if musicManager.hasActiveMedia {
                timeLabelsView
            }
        }
    }
    
    // MARK: - Progress Bar Visual
    private var progressBarView: some View {
        // 드래그 중이 아닐 때만 TimelineView 사용
        Group {
            if isDragging {
                staticProgressBar
            } else {
                animatedProgressBar
            }
        }
    }
    
    private var animatedProgressBar: some View {
        TimelineView(.animation(minimumInterval: musicManager.isPlaying ? 0.1 : 1.0)) { timeline in
            let currentProgress = calculateRealTimeProgress()
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    trackBackground
                    progressTrack(progress: currentProgress, width: geometry.size.width)
                }
            }
            .frame(height: barHeight)
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .gesture(progressDragGesture)
        }
        .frame(width: barWidth, height: barHeight)
    }
    
    private var staticProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                trackBackground
                progressTrack(progress: dragPosition, width: geometry.size.width)
            }
        }
        .frame(height: barHeight)
        .clipShape(Capsule())
        .contentShape(Rectangle())
        .gesture(progressDragGesture)
        .frame(width: barWidth, height: barHeight)
    }
    
    // MARK: - Background Track
    private var trackBackground: some View {
        Capsule()
            .fill(.white.opacity(musicManager.hasActiveMedia ? 0.3 : 0.1))
            .animation(.easeInOut(duration: 0.2), value: musicManager.hasActiveMedia)
    }
    
    // MARK: - Progress Track
    private func progressTrack(progress: Double, width: CGFloat) -> some View {
        let progressWidth = max(2, width * progress)
        
        return Capsule()
            .fill(progressTrackColor)
            .frame(width: progressWidth)
            .animation(isDragging ? .none : .easeOut(duration: 0.2), value: progress)
    }
    
    // MARK: - Progress Track Color
    private var progressTrackColor: Color {
        if !musicManager.hasActiveMedia {
            return .white.opacity(0.2)
        } else if musicManager.isPlaying {
            return .white
        } else {
            return .white.opacity(0.7)
        }
    }
    
    // MARK: - Time Labels
    private var timeLabelsView: some View {
        HStack {
            Text(isDragging ? formatDragTime() : musicManager.formattedCurrentTime)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
                .animation(.none, value: isDragging)
            
            Spacer()
            
            Text(musicManager.formattedDuration)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(width: barWidth)
    }
    
    // MARK: - Drag Gesture
    private var progressDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                handleDragChange(value)
            }
            .onEnded { value in
                handleDragEnd(value)
            }
    }
    
    // MARK: - Drag Handlers
    private func handleDragChange(_ value: DragGesture.Value) {
        if !isDragging {
            // 드래그 시작
            isDragging = true
            dragStartTime = Date()
            
            // 햅틱 피드백 (가능한 경우)
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif
        }
        
        let progress = max(0, min(value.location.x / barWidth, 1.0))
        dragPosition = progress
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        guard musicManager.duration > 0 else {
            isDragging = false
            return
        }
        
        let finalProgress = max(0, min(value.location.x / barWidth, 1.0))
        let seekTime = finalProgress * musicManager.duration
        
        // 시크 적용
        musicManager.seek(to: seekTime)
        
        // 드래그 상태 해제
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isDragging = false
        }
        
        print("🎯 드래그 시크: \(seekTime)초로 이동 (진행률: \(Int(finalProgress * 100))%)")
    }
    
    // MARK: - Helper Methods
    private func calculateRealTimeProgress() -> Double {
        guard musicManager.duration > 0 else { return 0 }
        return musicManager.playbackProgress
    }
    
    private func formatDragTime() -> String {
        let seekTime = dragPosition * musicManager.duration
        return TimeFormatter.format(seekTime)
    }
}

// MARK: - Time Formatting Utility (개선된 버전)
struct TimeFormatter {
    static func format(_ seconds: Double) -> String {
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
