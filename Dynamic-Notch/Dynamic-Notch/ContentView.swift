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

//struct ContentView: View {
//    @EnvironmentObject var musicManager: MusicManager
//    @EnvironmentObject var vm: NotchViewModel
//    
//    // 호버 상태 관리를 위한 변수들
//    @State private var isHovering: Bool = false
//    @State private var hoverAnimation: Bool = false
//    
//    //파일 드롭앤드래그시 사용되는 변수
//    @State private var currentTab : NotchMainFeaturesView = .studio
//    @State private var isDropTargeted = false
//    
//    private var shouldOpenNotch: Bool {
//        isHovering || isDropTargeted
//    }
//    
//    // 첫 실행할 때 사용되는 변수들
//    //    @State private var firstLaunch: Bool = true
//    //    @State private var showNGlow: Bool = false
//    //    @State private var showHelloAnimation: Bool = false
//    //    @State private var helloAnimationCompleted: Bool = false
//    
//    var body: some View {
//        ZStack(alignment: .top) {
//            
//            //드롭존 - 드론 변환만 관리하는 영역
//            Color.clear
//                .frame(width: vm.notchSize.width, height: vm.notchSize.height)
//                .contentShape(Rectangle())
//                .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
//                    
//                    print("드롭 감지됨")
//                    for provider in providers {
//                        _ = provider.loadObject(ofClass: URL.self) { url ,error in
//                            DispatchQueue.main.async {
//                                if let fileURL = url, error == nil {
//                                    let successLoad = TrayManager.shared.addFileToTray(source: fileURL)
//                                    print((successLoad != nil) ? "✅ 파일 추가 성공: \(fileURL.lastPathComponent)" : "❌ 파일 추가 실패")
//                                } else {
//                                    print(" 파일 로드 실패: \(error?.localizedDescription ?? "Unknown error")")
//                                }
//                            }
//                        }
//                    }
//                    
//                    return true
//                }
//            
//            if musicManager.hasActiveMedia {
//                Rectangle()
//                    .fill(.black)
//                    .frame(width: vm.notchSize.width + 50, height: vm.notchSize.height)
//                    .mask { NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10) }
//                    .overlay {
//                        if vm.notchState == .on {
//                            VStack {
//                                HomeView(currentTab: $currentTab)
//                            }
//                            .padding()
//                            .transition(.opacity.combined(with: .scale))
//                        }
//                    }
//                    .onHover { hovering in
//                        isHovering = hovering
//                    }
//                    .shadow(color: vm.notchState == .on ? .black.opacity(0.8) : .clear, radius: 3.2)
//            } else {
//                //호버링존 + 그외에 관련된것들 -기본적인 NotchUI
//                Rectangle()
//                    .fill(.black)
//                    .frame(width: vm.notchSize.width, height: vm.notchSize.height)
//                    .mask { NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10) }
//                    .overlay {
//                        if vm.notchState == .on {
//                            VStack {
//                                HomeView(currentTab: $currentTab)
//                            }
//                            .padding()
//                            .transition(.opacity.combined(with: .scale))
//                        }
//                    }
//                    .onHover { hovering in
//                        isHovering = hovering
//                    }
//                    .shadow(color: vm.notchState == .on ? .black.opacity(0.8) : .clear, radius: 3.2)
//            }
//        }
//        .frame(maxWidth: onNotchSize.width, maxHeight: onNotchSize.height, alignment: .top)
//        .onChange(of: shouldOpenNotch) { _, shouldOpen in
//            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
//                if shouldOpen {
//                    if vm.notchState == .off {
//                        vm.open()
//                        print("노치 열기")
//                    }
//                } else {
//                    if vm.notchState == .on {
//                        vm.close()
//                        print("노치 닫기")
//                    }
//                }
//            }
//        }
//        // 드래그 시 탭 전환
//        .onChange(of: isDropTargeted) { _, isDragging in
//            if isDragging {
//                print(" 드래그 시작 - Tray 탭으로 전환")
//                currentTab = .tray
//            }
//        }
//    }
//}
//
//// onchange을 ZStack에 통합으로 관리하는 이유 -> 더 간단하기 때문 ㅋㅋㅋㅋ
//// 원리 개별에 onChange을 구현햇는데 조건문이 복잡해져서 그냥 통합으로 관리
//
//#Preview {
//    ContentView()
//        .environmentObject(NotchViewModel())
//}

//
//  QuickFixContentView.swift
//  Dynamic-Notch
//
//  기존 ContentView에 바로 적용할 수 있는 수정 버전
//

import SwiftUI
import Combine
import AVFoundation
import UniformTypeIdentifiers
import Defaults

struct ContentView: View {
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var vm: NotchViewModel
    @Namespace private var albumArtNamespace
    
    // 호버 상태 관리를 위한 변수들
    @State private var isHovering: Bool = false
    @State private var hoverAnimation: Bool = false
    
    //파일 드롭앤드래그시 사용되는 변수
    @State private var currentTab : NotchMainFeaturesView = .studio
    @State private var isDropTargeted = false
    
    private var shouldOpenNotch: Bool {
        isHovering || isDropTargeted
    }
    
    // Live Activity 표시 조건
    private var shouldShowMusicLiveActivity: Bool {
        return musicManager.hasActiveMedia &&
               vm.notchState == .off &&
               (musicManager.isPlaying || recentlyActive)
    }
    
    // 최근 활성 상태 확인 (30초 이내)
    private var recentlyActive: Bool {
        Date().timeIntervalSince(musicManager.lastUpdated) < 30
    }
    
    // 동적 노치 크기
    private var dynamicNotchWidth: CGFloat {
        if shouldShowMusicLiveActivity {
            return vm.notchSize.width + 60 // Live Activity를 위한 추가 공간
        } else {
            return vm.notchSize.width
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            //드롭존 - 드론 변환만 관리하는 영역
            Color.clear
                .frame(width: vm.notchSize.width, height: vm.notchSize.height)
                .contentShape(Rectangle())
                .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                    
                    print("드롭 감지됨")
                    for provider in providers {
                        _ = provider.loadObject(ofClass: URL.self) { url ,error in
                            DispatchQueue.main.async {
                                if let fileURL = url, error == nil {
                                    let successLoad = TrayManager.shared.addFileToTray(source: fileURL)
                                    print((successLoad != nil) ? "✅ 파일 추가 성공: \(fileURL.lastPathComponent)" : "❌ 파일 추가 실패")
                                } else {
                                    print(" 파일 로드 실패: \(error?.localizedDescription ?? "Unknown error")")
                                }
                            }
                        }
                    }
                    
                    return true
                }
            
            // 메인 노치 뷰 (통합된 버전)
            Rectangle()
                .fill(.black)
                .frame(width: dynamicNotchWidth, height: vm.notchSize.height)
                .mask { NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10) }
                .overlay {
                    Group {
                        if vm.notchState == .on {
                            // 열린 상태
                            VStack {
                                HomeView(currentTab: $currentTab)
                            }
                            .padding()
                            .transition(.opacity.combined(with: .scale))
                        } else {
                            // 닫힌 상태
                            closedNotchContent
                        }
                    }
                }
                .onHover { hovering in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isHovering = hovering
                    }
                }
                .shadow(color: vm.notchState == .on ? .black.opacity(0.8) : .clear, radius: 3.2)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dynamicNotchWidth)
        }
        .frame(maxWidth: onNotchSize.width, maxHeight: onNotchSize.height, alignment: .top)
        .onChange(of: shouldOpenNotch) { _, shouldOpen in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                if shouldOpen {
                    if vm.notchState == .off {
                        vm.open()
                        print("노치 열기")
                    }
                } else {
                    if vm.notchState == .on {
                        vm.close()
                        print("노치 닫기")
                    }
                }
            }
        }
        // 드래그 시 탭 전환
        .onChange(of: isDropTargeted) { _, isDragging in
            if isDragging {
                print(" 드래그 시작 - Tray 탭으로 전환")
                currentTab = .tray
            }
        }
    }
    
    // MARK: - 닫힌 상태 컨텐츠
    @ViewBuilder
    private var closedNotchContent: some View {
        HStack {
            if shouldShowMusicLiveActivity {
                // 음악 Live Activity
                musicLiveActivityView
            } else {
                // 기본 상태 (시계 등)
                defaultClosedView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 음악 Live Activity (인라인 구현)
    @ViewBuilder
    private var musicLiveActivityView: some View {
        HStack(spacing: 8) {
            // 앨범 아트
            Image(nsImage: musicManager.albumArt)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 24, height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .matchedGeometryEffect(id: "albumArt", in: albumArtNamespace)
                .opacity(musicManager.isPlaying ? 1.0 : 0.7)
                .scaleEffect(musicManager.isPlaying ? 1.0 : 0.95)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: musicManager.isPlaying)
            
            // 중간 공간
            Rectangle()
                .fill(.black)
                .frame(width: 160)
            
            // 음악 정보
            VStack(alignment: .trailing, spacing: 2) {
                if musicManager.isPlaying {
                    // 재생 중: 간단한 스펙트럼
                    HStack(spacing: 1) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 0.5)
                                .fill(.white)
                                .frame(width: 1.5, height: CGFloat.random(in: 4...12))
                                .animation(.easeInOut(duration: 0.3).repeatForever(), value: musicManager.isPlaying)
                        }
                    }
                    .frame(height: 12)
                } else {
                    // 정지: 진행률 표시
                    HStack(spacing: 4) {
                        Text("\(Int(musicManager.playbackProgress * 100))%")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Circle()
                            .fill(.white.opacity(0.5))
                            .frame(width: 2, height: 2)
                    }
                }
            }
            .frame(width: 40, alignment: .trailing)
        }
        .frame(height: 28)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                musicManager.togglePlayPause()
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        ))
    }
    
    // MARK: - 기본 닫힌 상태 뷰
    @ViewBuilder
    private var defaultClosedView: some View {
        HStack {
            Spacer()
            
            // 현재 시간
            Text(currentTimeString)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
            
            Spacer()
        }
    }
    
    // MARK: - 헬퍼 프로퍼티
    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

#Preview {
    ContentView()
        .environmentObject(NotchViewModel())
        .environmentObject(MusicManager.shared)
}
