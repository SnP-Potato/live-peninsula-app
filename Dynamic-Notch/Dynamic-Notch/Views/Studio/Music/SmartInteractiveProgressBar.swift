//
//  SmartInteractiveProgressBar.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/9/25.
//

import SwiftUI

struct SmartInteractiveProgressBar: View {
    @EnvironmentObject var musicManager: MusicManager
    
    // 인터랙션 상태들
    @State private var isHovering = false
    @State private var mousePosition: CGFloat = 0
    @State private var previewPosition: Double = 0
    @State private var showPreview = false
    @State private var isCommittingSeek = false
    @State private var magneticEffect = false
    @State private var quickSeekMode = false
    
    // 설정값들
    private let barHeight: CGFloat = 4
    private let expandedHeight: CGFloat = 8
    private let barWidth: CGFloat = 100
    private let magneticThreshold: CGFloat = 15
    private let quickSeekThreshold: CGFloat = 5
    
    var body: some View {
        VStack(spacing: 4) {
            // 메인 진행바
            mainProgressBar
            
            // 시간 라벨
            if musicManager.hasActiveMedia {
                timeLabels
            }
        }
    }
    
    // MARK: - 메인 진행바
    private var mainProgressBar: some View {
        ZStack {
            // 배경 트랙
            backgroundTrack
            
            // 진행 트랙
            progressTrack
            
            // 마그네틱 포인터 (호버 시)
            if showPreview {
                magneticPointer
            }
            
            // 인터랙션 오버레이
            interactionOverlay
        }
        .frame(width: barWidth, height: isHovering ? expandedHeight : barHeight)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovering)
        .animation(.spring(response: 0.2, dampingFraction: 0.9), value: magneticEffect)
    }
    
    // MARK: - 배경 트랙
    private var backgroundTrack: some View {
        Capsule()
            .fill(.white.opacity(musicManager.hasActiveMedia ? 0.25 : 0.1))
            .overlay {
                // 호버 시 그라데이션 효과
                if isHovering {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.1),
                                    .white.opacity(0.05),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isHovering)
                }
            }
    }
    
    // MARK: - 진행 트랙
    private var progressTrack: some View {
        GeometryReader { geometry in
            let currentProgress = musicManager.playbackProgress
            let progressWidth = max(2, geometry.size.width * currentProgress)
            
            HStack(spacing: 0) {
                // 실제 진행된 부분
                Capsule()
                    .fill(progressColor)
                    .frame(width: progressWidth)
                
                Spacer(minLength: 0)
            }
        }
        .animation(.easeOut(duration: isCommittingSeek ? 0.1 : 0.3), value: musicManager.playbackProgress)
    }
    
    // MARK: - 마그네틱 포인터
    private var magneticPointer: some View {
        GeometryReader { geometry in
            let pointerX = geometry.size.width * previewPosition
            
            VStack(spacing: 2) {
                // 시간 미리보기 툴팁
                timePreviewTooltip
                
                // 포인터 라인
                Rectangle()
                    .fill(.white)
                    .frame(width: 2, height: expandedHeight + 4)
                    .opacity(0.9)
                    .shadow(color: .white, radius: magneticEffect ? 3 : 1)
                    .scaleEffect(y: magneticEffect ? 1.2 : 1.0)
            }
            .position(x: pointerX, y: expandedHeight / 2)
        }
    }
    
    // MARK: - 시간 미리보기 툴팁
    private var timePreviewTooltip: some View {
        let previewTime = previewPosition * musicManager.duration
        
        return Text(TimeFormatter.format(previewTime))
            .font(.system(size: 9, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(.black.opacity(0.8))
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .offset(y: -20)
            .scaleEffect(magneticEffect ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: magneticEffect)
    }
    
    // MARK: - 인터랙션 오버레이
    private var interactionOverlay: some View {
        Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .frame(height: max(20, expandedHeight)) // 터치 영역 확장
            .onHover { hovering in
                handleHover(hovering)
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        handleInteraction(at: value.location.x, isClick: false)
                    }
                    .onEnded { value in
                        handleInteractionEnd(at: value.location.x)
                    }
            )
            .onTapGesture { location in
                handleInteraction(at: location.x, isClick: true)
                handleInteractionEnd(at: location.x)
            }
    }
    
    // MARK: - 시간 라벨
    private var timeLabels: some View {
        HStack {
            Text(musicManager.formattedCurrentTime)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
            
            Spacer()
            
            // 호버 시 남은 시간 표시
            if isHovering && showPreview {
                let remainingTime = musicManager.duration - (previewPosition * musicManager.duration)
                Text("-\(TimeFormatter.format(remainingTime))")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.gray.opacity(0.7))
                    .transition(.opacity)
            } else {
                Text(musicManager.formattedDuration)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: barWidth)
        .animation(.easeInOut(duration: 0.2), value: isHovering && showPreview)
    }
    
    // MARK: - 진행 색상
    private var progressColor: Color {
        if !musicManager.hasActiveMedia {
            return .white.opacity(0.3)
        } else if musicManager.isPlaying {
            return .white
        } else {
            return .white.opacity(0.8)
        }
    }
    
    // MARK: - 이벤트 핸들러들
    private func handleHover(_ hovering: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isHovering = hovering
            
            if !hovering {
                showPreview = false
                quickSeekMode = false
                magneticEffect = false
            }
        }
    }
    
    private func handleInteraction(at x: CGFloat, isClick: Bool) {
        guard musicManager.hasActiveMedia && musicManager.duration > 0 else { return }
        
        let position = max(0, min(x / barWidth, 1.0))
        mousePosition = x
        
        // 스마트 마그네틱 효과
        let currentProgress = musicManager.playbackProgress
        let distanceFromCurrent = abs(position - currentProgress)
        
        if distanceFromCurrent < 0.05 { // 5% 이내면 현재 위치에 자석 효과
            previewPosition = currentProgress
            magneticEffect = true
        } else {
            previewPosition = position
            magneticEffect = false
        }
        
        // 퀵 시크 모드 (현재 위치 근처에서는 더 민감하게)
        if distanceFromCurrent < 0.1 {
            quickSeekMode = true
        }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
            showPreview = true
        }
        
        // 클릭이면 즉시 시크
        if isClick {
            commitSeek()
        }
    }
    
    private func handleInteractionEnd(at x: CGFloat) {
        guard showPreview else { return }
        
        // 드래그 종료 시 시크 실행
        commitSeek()
        
        // 상태 초기화
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                showPreview = false
                magneticEffect = false
                quickSeekMode = false
            }
        }
    }
    
    private func commitSeek() {
        guard musicManager.duration > 0 else { return }
        
        let seekTime = previewPosition * musicManager.duration
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isCommittingSeek = true
        }
        
        // 햅틱 피드백 (macOS에서는 제한적)
        NSSound.beep()
        
        // 시크 실행
        musicManager.seek(to: seekTime)
        
        print("🎯 스마트 시크: \(seekTime)초로 이동 (진행률: \(Int(previewPosition * 100))%)")
        
        // 커밋 상태 해제
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isCommittingSeek = false
        }
    }
}

// MARK: - 개선된 컴팩트 버전
struct CompactSmartProgressBar: View {
    @EnvironmentObject var musicManager: MusicManager
    @State private var isInteracting = false
    @State private var hoverPosition: Double = 0
    
    private let barWidth: CGFloat = 100
    private let barHeight: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                Capsule()
                    .fill(.white.opacity(0.2))
                
                // 진행 트랙
                Capsule()
                    .fill(.white)
                    .frame(width: max(2, geometry.size.width * musicManager.playbackProgress))
                
                // 호버 표시기
                if isInteracting {
                    Circle()
                        .fill(.white)
                        .frame(width: 8, height: 8)
                        .position(x: geometry.size.width * hoverPosition, y: geometry.size.height / 2)
                        .shadow(color: .white, radius: 2)
                }
            }
        }
        .frame(width: barWidth, height: barHeight)
        .contentShape(Rectangle())
        .scaleEffect(y: isInteracting ? 1.5 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isInteracting = hovering
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let position = max(0, min(value.location.x / barWidth, 1.0))
                    hoverPosition = position
                    isInteracting = true
                }
                .onEnded { value in
                    let position = max(0, min(value.location.x / barWidth, 1.0))
                    let seekTime = position * musicManager.duration
                    musicManager.seek(to: seekTime)
                    
                    withAnimation(.easeOut(duration: 0.3)) {
                        isInteracting = false
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isInteracting)
    }
}

// MARK: - 사용 예시
struct ProgressBarShowcase: View {
    @StateObject private var musicManager = MusicManager.shared
    
    var body: some View {
        VStack(spacing: 30) {
            Text("스마트 인터랙티브 진행바")
                .font(.headline)
                .foregroundColor(.white)
            
            // 풀 기능 버전
            SmartInteractiveProgressBar()
                .environmentObject(musicManager)
            
            Divider()
                .background(.white.opacity(0.3))
            
            Text("컴팩트 버전")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 컴팩트 버전
            CompactSmartProgressBar()
                .environmentObject(musicManager)
            
            // 디버그 정보
//            if musicManager.hasActiveMedia {
//                VStack(spacing: 4) {
//                    Text("곡: \(musicManager.songTitle)")
//                    Text("진행률: \(Int(musicManager.playbackProgress * 100))%")
//                    Text("재생 중: \(musicManager.isPlaying ? "예" : "아니오")")
//                }
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding()
//                .background(.black.opacity(0.5))
//                .cornerRadius(8)
//            }
        }
        .padding()
        .background(.black)
    }
}

#Preview("스마트 진행바") {
    ProgressBarShowcase()
        .frame(width: 400, height: 300)
}
