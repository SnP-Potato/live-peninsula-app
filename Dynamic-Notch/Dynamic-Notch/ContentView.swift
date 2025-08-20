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
////            Rectangle()
////                .fill(.black)
////                .frame(width: vm.notchSize.width, height: vm.notchSize.height)
////                .mask { NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10) }
////                .overlay {
////                    if vm.notchState == .on {
////                        VStack {
////                            HomeView(currentTab: $currentTab)
////                        }
////                        .padding()
////                        .transition(.scale)
////                    }
////                }
//            ZStack {
//                            Rectangle()
//                                .fill(.black)
//            
//                            if vm.notchState == .on {
//                                VStack {
//                                    HomeView(currentTab: $currentTab)
//                                }
//                                .padding()
//                                .transition(.asymmetric(
//                                    insertion: .opacity.combined(with: .scale(scale: 0.9)).animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)),
//                                    removal: .opacity.animation(.linear(duration: 0.05))
//                                ))
//                            }
//                        }
//                        .frame(width: vm.notchSize.width, height: vm.notchSize.height)
//                        // 전체 애니메이션 제거 - blur 효과 간섭 방지
//                        .clipShape(NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10))
//                .onHover { hovering in
//                    isHovering = hovering
//                }
//                .shadow(color: vm.notchState == .on ? .black.opacity(0.8) : .clear, radius: 3.2)
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
//            
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



// MARK: - 방법 1: ViewBuilder를 활용한 깔끔한 구조
struct ContentView: View {
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var vm: NotchViewModel
    
    @State private var isHovering: Bool = false
    @State private var currentTab: NotchMainFeaturesView = .studio
    @State private var isDropTargeted = false
    
    private var shouldOpenNotch: Bool {
        isHovering || isDropTargeted
    }
    
    var body: some View {
        notchContainer
            .frame(maxWidth: onNotchSize.width, maxHeight: onNotchSize.height, alignment: .top)
            .onChange(of: shouldOpenNotch) { _, shouldOpen in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    if shouldOpen && vm.notchState == .off {
                        vm.open()
                    } else if !shouldOpen && vm.notchState == .on {
                        vm.close()
                    }
                }
            }
            .onChange(of: isDropTargeted) { _, isDragging in
                if isDragging {
                    currentTab = .tray
                }
            }
    }
    
    @ViewBuilder
    private var notchContainer: some View {
        ZStack(alignment: .top) {
            // 드롭존
            dropZone
            
            // 메인 노치
            mainNotch
        }
    }
    
    @ViewBuilder
    private var dropZone: some View {
        Color.clear
            .frame(width: vm.notchSize.width, height: vm.notchSize.height)
            .contentShape(Rectangle())
            .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                handleFileDrop(providers)
                return true
            }
    }
    
    @ViewBuilder
    private var mainNotch: some View {
        notchBackground
            .overlay(alignment: .center) {
                notchContent
            }
            .clipShape(NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10))
            .onHover { isHovering = $0 }
            .shadow(color: vm.notchState == .on ? .black.opacity(0.8) : .clear, radius: 3.2)
    }
    
    @ViewBuilder
    private var notchBackground: some View {
        Rectangle()
            .fill(.black)
            .frame(width: vm.notchSize.width, height: vm.notchSize.height)
    }
    
    @ViewBuilder
    private var notchContent: some View {
        if vm.notchState == .on {
            HomeView(currentTab: $currentTab)
                .padding()
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)),
                    removal: .opacity
                        .animation(.spring(response: 0.2, dampingFraction: 0.9))
                ))
        }
    }
    
    private func handleFileDrop(_ providers: [NSItemProvider]) {
        print("드롭 감지됨")
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                DispatchQueue.main.async {
                    if let fileURL = url, error == nil {
                        let successLoad = TrayManager.shared.addFileToTray(source: fileURL)
                        print((successLoad != nil) ? "✅ 파일 추가 성공: \(fileURL.lastPathComponent)" : "❌ 파일 추가 실패")
                    }
                }
            }
        }
    }
}
