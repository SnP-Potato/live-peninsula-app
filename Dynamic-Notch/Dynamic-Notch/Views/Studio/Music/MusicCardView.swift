//
//  MusicCardView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/25/25.
//


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
    @State private var avgColor: NSColor = .gray  // ✅ 기본 색상을 회색으로 변경
    
    var body: some View {
        ZStack {
            
            if musicManager.hasActiveMedia && musicManager.albumArt.size.width > 0 {
                backgroundBlurEffect
            }
            
            // 배경 앨범 이미지 - 실제 앨범 아트 사용
            Group {
                if musicManager.hasActiveMedia && musicManager.albumArt.size.width > 0 {
                    // 실제 앨범 아트가 있을 때
                    Image(nsImage: musicManager.albumArt)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 110)
                        .clipped()
                } else {
                    // 기본 이미지 또는 앨범 아트가 없을 때
                    Image("44")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 110)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .animation(.easeInOut(duration: 0.3), value: musicManager.albumArt)
            .onChange(of: musicManager.albumArt) { _, newAlbumArt in
                //
                extractAverageColorImmediately(from: newAlbumArt)
            }
            
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
                    .frame(width: 120, height: 110)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                    
                } else {
                    //
                    ZStack {
                        // 배경을 더 어둡게 처리
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.4))
                            .frame(width: 120, height: 110)
                        
                        musicControlInterface
                    
                    }
                    .frame(width: 120, height: 110)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                }
            }
            
            // 앨범 아트 위 작은 앱 아이콘
            if !musicCardclick {
                appIcon
            }
        }
        .frame(width: 120, height: 110)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: musicCardclick)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: musicManager.isPlaying)
        .onAppear {
            
            extractAverageColorImmediately(from: musicManager.albumArt)
        }
    }
    
    
    @ViewBuilder
    private var backgroundBlurEffect: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .background(
                Image(nsImage: musicManager.albumArt)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(x: 1.00, y: 0.90)
            .rotationEffect(.degrees(0))
            .blur(radius: 12)
            .opacity(min(0.3, 1 - max(getBrightness(from: musicManager.albumArt), 0.5)))  //
            .animation(.smooth, value: musicManager.albumArt)
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
            
            MusicProgressBar()
                .environmentObject(musicManager)
        }
        
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
    
    private func realGlassControlButton(
        icon: String,
        size: CGFloat,
        isMain: Bool = false,
        action: @escaping () -> Void = {}
    ) -> some View {
        Group {
            if #available(macOS 26.0, *) {
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
            } else {
                // ✅ Button 대신 직접 탭 제스처 사용
                ZStack {
                    RoundedRectangle(cornerRadius: isMain ? 15 : 12)
                        .fill(.white.opacity(0.2))
                    
                    Image(systemName: icon)
                        .font(.system(size: size, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.9), radius: 1, x: 0, y: 1)
                }
                .frame(width: isMain ? 28 : 24, height: isMain ? 28 : 24)
                .scaleEffect(isMain ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: musicManager.isPlaying)
                .onTapGesture {
                    action()
                }
            }
        }
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
            }
        }
        .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
        .offset(x: 44, y: 45)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: -
    private func extractAverageColorImmediately(from image: NSImage) {
        guard image.size.width > 0 else {
            // 이미지가 없을 때는 회색으로 설정
            avgColor = .gray
            return
        }
        
        //
        self.calculateAverageColor(from: image) { color in
            DispatchQueue.main.async {
                // 애니메이션 없이 즉시 적용
                self.avgColor = color ?? self.getDefaultColorFromImage(image)
            }
        }
    }
    
    //
    private func getDefaultColorFromImage(_ image: NSImage) -> NSColor {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return .gray
        }
        
        // 이미지 중앙의 픽셀 색상 추출
        let width = cgImage.width
        let height = cgImage.height
        let centerX = width / 2
        let centerY = height / 2
        
        guard let context = CGContext(data: nil,
                                      width: 1,
                                      height: 1,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return .gray
        }
        
        context.draw(cgImage, in: CGRect(x: -centerX, y: -centerY, width: width, height: height))
        
        guard let data = context.data else {
            return .gray
        }
        
        let pointer = data.bindMemory(to: UInt32.self, capacity: 1)
        let color = pointer[0]
        
        let red = CGFloat(color & 0xFF) / 255.0
        let green = CGFloat((color >> 8) & 0xFF) / 255.0
        let blue = CGFloat((color >> 16) & 0xFF) / 255.0
        
        return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    private func calculateAverageColor(from image: NSImage, completion: @escaping (NSColor?) -> Void) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(nil)
            return
        }
        
        
        let sampleWidth = min(cgImage.width, 100)
        let sampleHeight = min(cgImage.height, 100)
        let totalPixels = sampleWidth * sampleHeight
        
        guard let context = CGContext(data: nil,
                                      width: sampleWidth,
                                      height: sampleHeight,
                                      bitsPerComponent: 8,
                                      bytesPerRow: sampleWidth * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            completion(nil)
            return
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: sampleWidth, height: sampleHeight))
        
        guard let data = context.data else {
            completion(nil)
            return
        }
        
        let pointer = data.bindMemory(to: UInt32.self, capacity: totalPixels)
        
        var totalRed: UInt64 = 0
        var totalGreen: UInt64 = 0
        var totalBlue: UInt64 = 0
        
        for i in 0..<totalPixels {
            let color = pointer[i]
            totalRed += UInt64(color & 0xFF)
            totalGreen += UInt64((color >> 8) & 0xFF)
            totalBlue += UInt64((color >> 16) & 0xFF)
        }
        
        let averageRed = CGFloat(totalRed) / CGFloat(totalPixels) / 255.0
        let averageGreen = CGFloat(totalGreen) / CGFloat(totalPixels) / 255.0
        let averageBlue = CGFloat(totalBlue) / CGFloat(totalPixels) / 255.0
        
        
        let finalColor = NSColor(red: averageRed, green: averageGreen, blue: averageBlue, alpha: 1.0)
        completion(finalColor)
    }
    
    private func getBrightness(from image: NSImage) -> CGFloat {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return 0
        }
        
        
        let width = min(cgImage.width, 20)
        let height = min(cgImage.height, 20)
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return 0
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else {
            return 0
        }
        
        let pointer = data.bindMemory(to: UInt32.self, capacity: width * height)
        var totalBrightness: CGFloat = 0
        
        for i in 0..<(width * height) {
            let color = pointer[i]
            let red = CGFloat(color & 0xFF) / 255.0
            let green = CGFloat((color >> 8) & 0xFF) / 255.0
            let blue = CGFloat((color >> 16) & 0xFF) / 255.0
            
            // 인지 밝기 공식
            let brightness = (0.2126 * red + 0.7152 * green + 0.0722 * blue)
            totalBrightness += brightness
        }
        
        return totalBrightness / CGFloat(width * height)
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
                        .frame(width: 25, height: 25)
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

extension View {
    func backdrop(blur radius: CGFloat) -> some View {
        self.background(.ultraThinMaterial)
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



