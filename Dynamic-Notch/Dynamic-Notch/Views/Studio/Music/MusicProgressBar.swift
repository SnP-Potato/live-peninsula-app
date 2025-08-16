//
//  MusicProgressBar.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/15/25.
//

import SwiftUI

struct MusicProgressBar: View {
    @EnvironmentObject var musicManager: MusicManager
        @State private var isDragging = false
        @State private var dragPosition: Double = 0
        
        private let barHeight: CGFloat = 4
        private let barWidth: CGFloat = 100
        
        var body: some View {
            VStack(spacing: 4) {
                // Progress Bar
                progressBarView
            }
        }
        
        // MARK: - Progress Bar Visual
        private var progressBarView: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경 트랙
                    Capsule()
                        .fill(.white.opacity(musicManager.hasActiveMedia ? 0.3 : 0.1))
                    
                    // 진행 트랙
                    Capsule()
                        .fill(progressTrackColor)
                        .frame(width: max(2, geometry.size.width * currentProgress))
                }
            }
            .frame(width: barWidth, height: barHeight)
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .gesture(progressDragGesture)
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
        
        // MARK: - Current Progress
        private var currentProgress: Double {
            return isDragging ? dragPosition : musicManager.playbackProgress
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
                isDragging = true
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isDragging = false
            }
            
            print("🎯 기본 시크: \(seekTime)초로 이동 (진행률: \(Int(finalProgress * 100))%)")
        }
}

#Preview {
    MusicProgressBar()
        .environmentObject(MusicManager.shared)
}
