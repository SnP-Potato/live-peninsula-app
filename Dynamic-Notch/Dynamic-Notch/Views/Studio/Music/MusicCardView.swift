//
//  MusicCardView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/25/25.
//

import SwiftUI

struct MusicCardView: View {
    @Binding var musicCardclick: Bool
    @EnvironmentObject var musicManager: MusicManager
    
    var body: some View {
        ZStack {
            // 배경 앨범 이미지 - 실제 앨범 아트 사용
            Group {
                if musicManager.hasActiveMedia && musicManager.albumArt.size.width > 0 {
                    // 실제 앨범 아트가 있을 때
                    Image(nsImage: musicManager.albumArt)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipped()
                } else {
                    // 기본 이미지 또는 앨범 아트가 없을 때
                    Image("44")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
//                        .clipped()
                        
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .animation(.easeInOut(duration: 0.3), value: musicManager.albumArt)
            
            if musicCardclick {
                if #available(macOS 26.0, *) {
                    // Liquid Glass로 앨범 아트를 완전히 덮기
                    LiquidGlassBackground(
                        variant: .v11,
                        cornerRadius: 12
                    ) {
                        ZStack {
                            // 배경을 더 어둡게 처리
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.black.opacity(0.4))
                            
                            musicControlInterface
                        }
                    }
                    .frame(width: 110, height: 110)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                    
                }else {
                    musicControlInterface
                }
                
            }
            
            
            // 앨범 아트 위 작은 앱 아이콘
            if !musicCardclick {
                appIcon
            }
        }
        .frame(width: 110, height: 110)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: musicCardclick)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: musicManager.isPlaying)
    }
    
    // MARK: - 음악 제어 인터페이스 (실제 데이터 사용)
    @ViewBuilder
    private var musicControlInterface: some View {
        VStack(alignment: .center, spacing: 2) {
            Spacer()
            
            Text(musicManager.hasActiveMedia ? musicManager.songTitle : "No Song Playing")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 1)
            
            Text(musicManager.hasActiveMedia ? musicManager.artistName : "Unknown Artist")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
            
            Spacer()
                .frame(height: 6)
            
            HStack(spacing: 12) {
                realGlassControlButton(icon: "backward.fill", size: 12) {
                    musicManager.previousTrack()
                }
                realGlassControlButton(
                    icon: musicManager.isPlaying ? "pause.fill" : "play.fill",
                    size: 14,
                    isMain: true
                ) {
                    musicManager.togglePlayPause()
                }
                realGlassControlButton(icon: "forward.fill", size: 12) {
                    musicManager.nextTrack()
                }
            }
            
            Spacer()

            
            MusicProgressBar(musicManager: _musicManager)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
    
    // MARK: - Real Glass 스타일 버튼
    private func realGlassControlButton(
        icon: String,
        size: CGFloat,
        isMain: Bool = false,
        action: @escaping () -> Void = {}
    ) -> some View {
        Button(action: action) {
            LiquidGlassBackground(
                variant: .v18,
                cornerRadius: isMain ? 15 : 12
            ) {
                Image(systemName: icon)
                    .font(.system(size: size, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.9), radius: 1, x: 0, y: 1)
                    .frame(width: isMain ? 28 : 24, height: isMain ? 28 : 24)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isMain ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: musicManager.isPlaying)
    }
    
    // MARK: - 앱 아이콘 (실제 앱 아이콘 표시)
    @ViewBuilder
    private var appIcon: some View {
        Group {
            if !musicManager.bundleIdentifier.isEmpty {
                // 실제 앱 아이콘 사용
                AppIconView(bundleIdentifier: musicManager.bundleIdentifier)
            } else {
                // 기본 음악 아이콘
//                Image(systemName: "app.fill")
//                    .font(.system(size: 12, weight: .bold))
//                    .foregroundColor(.white)
//                    .frame(width: 22, height: 22)
//                    .background(Circle().fill(.black.opacity(0.7)))
            }
        }
        .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
        .offset(x: 40, y: 40)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - 실제 앱 아이콘을 가져오는 헬퍼 뷰
struct AppIconView: View {
    let bundleIdentifier: String
    @State private var appIcon: NSImage?
    
    var body: some View {
        if #available(macOS 14.0, *) {
            Group {
                if let icon = appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 22, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    // 로딩 중이거나 아이콘을 찾을 수 없을 때
                    Image(systemName: "music.note")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(.black.opacity(0.7)))
                }
            }
            .onAppear {
                loadAppIcon()
            }
            .onChange(of: bundleIdentifier) { _, _ in
                loadAppIcon()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func loadAppIcon() {
        guard !bundleIdentifier.isEmpty else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let workspace = NSWorkspace.shared
            
            // 번들 식별자로 앱 URL 찾기
            if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) {
                let icon = workspace.icon(forFile: appURL.path)
                
                DispatchQueue.main.async {
                    self.appIcon = icon
                }
            } else {
                // 앱을 찾을 수 없는 경우 기본 아이콘 설정
                DispatchQueue.main.async {
                    self.appIcon = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Music") ?? NSImage()
                }
            }
        }
    }
}

#Preview("Music Card with MediaRemote") {
    ZStack {
        VStack(spacing: 30) {
            HStack(spacing: 20) {
                // 클릭 안된 상태
                MusicCardView(musicCardclick: .constant(false))
                    .environmentObject(MusicManager.shared)
                
                // 클릭된 상태
                MusicCardView(musicCardclick: .constant(true))
                    .environmentObject(MusicManager.shared)
            }
        }
    }
    .frame(width: 600, height: 400)
    .background(.black)
}
