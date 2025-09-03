//
//  ContentView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 5/11/25.
//

import SwiftUI
import Combine
import AVFoundation
import UniformTypeIdentifiers
import Defaults


struct ContentView: View {
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var vm: NotchViewModel
    @EnvironmentObject var volumeManager: VolumeManager
//    @EnvironmentObject var brightnessManager: BrightnessManager
    
    // 호버 상태 관리를 위한 변수들
    @State private var isHovering: Bool = false
    @State private var hoverAnimation: Bool = false
    
    // 파일 드롭앤드래그시 사용되는 변수
    @State private var currentTab: NotchMainFeaturesView = .studio
    @State private var isDropTargeted = false
    @State private var albumArtColor: NSColor = .white
    
    // Volume Icon 계산
    private var volumeIconName: String {
        if volumeManager.isMuted {
            return "speaker.slash.fill"
        } else if volumeManager.currentVolume == 0 {
            return "speaker.fill"
        } else if volumeManager.currentVolume < 0.33 {
            return "speaker.wave.1.fill"
        } else if volumeManager.currentVolume < 0.66 {
            return "speaker.wave.2.fill"
        } else {
            return "speaker.wave.3.fill"
        }
    }
    
    // first launch
    @State private var firstLaunch: Bool = true
//    @State private var transitionNotchWidth: CGFloat = 200
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: 첫 실행시
            if firstLaunch {
                firstLaunchView()
                    .onAppear {
                        // firstLaunchView 애니메이션이 완료된 후 점진적 전환 시작
                        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
                            // 1단계: 노치 크기를 점진적으로 줄이기 (200 -> 185)
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
//                                transitionNotchWidth = 185
                            }
                            
                            // 2단계: 크기 변경 완료 후 firstLaunch를 false로 변경
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    firstLaunch = false
                                }
                            }
                        }
                    }
            } else {
                DefaultView()
            }
        }
        .frame(maxWidth: onNotchSize.width, maxHeight: onNotchSize.height, alignment: .top)
        .onChange(of: musicManager.albumArt) { _, newAlbumArt in
            extractColor(from: newAlbumArt)
        }
        .onAppear {
            extractColor(from: musicManager.albumArt)
        }
    }
    
    @ViewBuilder
    private func DefaultView() -> some View {
        ZStack {
            Rectangle()
                .fill(.black)
            
            // MARK: Live Activity 구현부분 (Notch가 off일때)
            if vm.notchState == .off {
                Group {
                    if volumeManager.isVolumeHUDVisible {
                        // 볼륨 우선 표시 (볼륨 조절 중일 때)
                        volumeLiveActivity
                    } else if musicManager.isPlaying {
                        // 음악 재생 중
                        musicLiveActivity
                    }
//                    } else if brightnessManager.isBrightnessHUDVisible {
//                        brightnessLiveActivity
//                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)).animation(.spring(response: 0.4, dampingFraction: 0.7)),
                    removal: .opacity.animation(.linear(duration: 0.2))
                ))
            }
            
            // MARK: HomeView
            if vm.notchState == .on {
                VStack {
                    HomeView(currentTab: $currentTab)
                }
                .padding()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.9)).animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)),
                    removal: .opacity.animation(.linear(duration: 0.05))
                ))
            }
        }
        .frame(width: calculateNotchWidth(), height: vm.notchSize.height)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: calculateNotchWidth())
        .clipShape(NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10))
        .onHover { hovering in
            isHovering = hovering
        }
        .shadow(color: vm.notchState == .on ? .black.opacity(0.8) : .clear, radius: 3.2)
        .background(dragDetector)
        .onChange(of: isHovering) { _, hovering in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                if hovering {
                    if vm.notchState == .off {
                        vm.open()
                        print("호버로 노치 열기")
                    }
                } else {
                    if vm.notchState == .on && !isDropTargeted {
                        vm.close()
                        print("호버 해제로 노치 닫기")
                    }
                }
            }
        }
        .onChange(of: isDropTargeted) { _, isDragging in
            if isDragging {
                print("드래그 시작 - Tray 탭으로 전환")
                currentTab = .tray
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    if vm.notchState == .off {
                        vm.open()
                        print("드래그로 노치 열기")
                    }
                }
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    if vm.notchState == .on && !isHovering {
                        vm.close()
                        print("드래그 해제로 노치 닫기")
                    }
                }
            }
        }
    }
    
    // MARK: - Live Activity 레이아웃들
    @ViewBuilder
    private var musicLiveActivity: some View {
        HStack(spacing: 0) {
            // 왼쪽: 앨범 아트
            Image(nsImage: musicManager.albumArt)
                .resizable()
                .scaledToFill()
                .frame(width: 23, height: 23)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .padding(.bottom, 3)
                .padding(.trailing, 8)
            
            // 중앙: 노치 기본 영역
            Rectangle()
                .fill(.black)
                .frame(width: vm.notchSize.width - 20)
            
            // 오른쪽: 비주얼라이저
            Rectangle()
                .fill(Color(nsColor: albumArtColor).gradient)
                .frame(width: 37, alignment: .center)
                .mask {
                    AudioSpectrumView(isPlaying: .constant(true))
                        .frame(width: 16, height: 12)
                }
                .frame(width: 23, height: 23)
        }
    }
    
    @ViewBuilder
    private var volumeLiveActivity: some View {
        HStack(spacing: 0) {
            // 왼쪽: 볼륨 아이콘
            Image(systemName: volumeIconName)
                .animation(.easeInOut(duration: 0.3), value: volumeIconName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 30, height: 20, alignment: .leading)
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .padding(.bottom, 4)
            
            // 중앙: 노치 기본 영역
            Rectangle()
                .fill(.black)
                .frame(width: vm.notchSize.width - 10)
                .padding(.trailing, 7)
            
            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.3))
                    .frame(width: 48, height: 3)
                
                // 진행
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .frame(width: 48 * CGFloat(volumeManager.currentVolume), height: 3)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: volumeManager.currentVolume)
            }
            .padding(.trailing, 2)
            .scaleEffect(y: 1.7)
        }
    }
    
//    @ViewBuilder
//    private var brightnessLiveActivity: some View {
//        HStack(spacing: 0) {
//            // 왼쪽: 밝기 아이콘
//            Image(systemName: "sun.max.fill")
//                .font(.system(size: 15, weight: .medium))
//                .foregroundColor(.white)
//                .frame(width: 30, height: 20, alignment: .leading)
//                .padding(.leading, 8)
//                .padding(.trailing, 8)
//                .padding(.bottom, 4)
//            
//            // 중앙: 노치 기본 영역
//            Rectangle()
//                .fill(.black)
//                .frame(width: vm.notchSize.width - 19)
//                .padding(.trailing, 7)
//            
//            ZStack(alignment: .leading) {
//                // 배경
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(.white.opacity(0.3))
//                    .frame(width: 48, height: 3)
//                
//                // 진행 (밝기 매니저가 있다면 해당 값 사용)
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(.white)
//                    .frame(width: 48 * CGFloat(brightnessManager.currentBrightness ?? 0.5), height: 3)
//                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: brightnessManager.currentBrightness)
//            }
//            .padding(.trailing, 2)
//            .scaleEffect(y: 1.7)
//        }
//    }
    
    // MARK: - Helper Functions
    private func calculateNotchWidth() -> CGFloat {
        if vm.notchState == .off {
            if volumeManager.isVolumeHUDVisible {
                return vm.notchSize.width + 110  // 볼륨 우선
            } else if musicManager.isPlaying {
                return vm.notchSize.width + 60   // 음악 차순위
            }
//            } else if brightnessManager.isBrightnessHUDVisible {
//                return vm.notchSize.width + 90
//            }
        }
        return vm.notchSize.width // 기본 크기
    }
    
    private func extractColor(from image: NSImage) {
        guard image.size.width > 0 else {
            albumArtColor = .white
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 이미지를 작은 크기로 리사이즈해서 성능 향상
            let smallSize = NSSize(width: 50, height: 50)
            let smallImage = NSImage(size: smallSize)
            
            smallImage.lockFocus()
            image.draw(in: NSRect(origin: .zero, size: smallSize))
            smallImage.unlockFocus()
            
            guard let cgImage = smallImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                DispatchQueue.main.async {
                    self.albumArtColor = .white
                }
                return
            }
            
            // 픽셀 데이터 읽기
            let width = cgImage.width
            let height = cgImage.height
            let totalPixels = width * height
            
            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                DispatchQueue.main.async {
                    self.albumArtColor = .white
                }
                return
            }
            
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            guard let data = context.data else {
                DispatchQueue.main.async {
                    self.albumArtColor = .white
                }
                return
            }
            
            let pointer = data.bindMemory(to: UInt32.self, capacity: totalPixels)
            
            var totalRed: UInt64 = 0
            var totalGreen: UInt64 = 0
            var totalBlue: UInt64 = 0
            
            // 모든 픽셀의 평균 색상 계산
            for i in 0..<totalPixels {
                let color = pointer[i]
                totalRed += UInt64(color & 0xFF)
                totalGreen += UInt64((color >> 8) & 0xFF)
                totalBlue += UInt64((color >> 16) & 0xFF)
            }
            
            let avgRed = CGFloat(totalRed) / CGFloat(totalPixels) / 255.0
            let avgGreen = CGFloat(totalGreen) / CGFloat(totalPixels) / 255.0
            let avgBlue = CGFloat(totalBlue) / CGFloat(totalPixels) / 255.0
            
            // 너무 어두운 색은 밝게 조정
            let brightness = (avgRed + avgGreen + avgBlue) / 3.0
            let minBrightness: CGFloat = 0.4
            
            let finalColor: NSColor
            if brightness < minBrightness {
                let scale = minBrightness / max(brightness, 0.1)
                finalColor = NSColor(
                    red: min(avgRed * scale, 1.0),
                    green: min(avgGreen * scale, 1.0),
                    blue: min(avgBlue * scale, 1.0),
                    alpha: 1.0
                )
            } else {
                finalColor = NSColor(red: avgRed, green: avgGreen, blue: avgBlue, alpha: 1.0)
            }
            
            DispatchQueue.main.async {
                withAnimation(.smooth(duration: 0.5)) {
                    self.albumArtColor = finalColor
                }
                print("🎨 앨범 색상 추출 완료: \(finalColor)")
            }
        }
    }
    
    // MARK: - 드래그 감지기 (분리된 컴포넌트)
    @ViewBuilder
    private var dragDetector: some View {
        Color.clear
            .contentShape(Rectangle())
            .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                print("드롭 감지됨")
                handleFileDrop(providers)
                return true
            }
    }
    
    // MARK: - 파일 드롭 처리 함수
    private func handleFileDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                DispatchQueue.main.async {
                    if let fileURL = url, error == nil {
                        let successLoad = TrayManager.shared.addFileToTray(source: fileURL)
                        print((successLoad != nil) ? "파일 추가 성공: \(fileURL.lastPathComponent)" : "⚠️ 파일 추가 실패")
                    } else {
                        print("파일 로드 실패: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
}
