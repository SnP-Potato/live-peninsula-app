//
//  ContentView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 5/11/25.
//

import SwiftUI
import Combine
import AVFoundation
import Defaults
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var musicManager: MusicManager //
    @EnvironmentObject var vm: NotchViewModel
    
    // 호버 상태 관리를 위한 변수들
    @State private var isHovering: Bool = false
    @State private var hoverAnimation: Bool = false
    
    //파일 드롭앤드래그시 사용되는 변수
    @State private var currentTab : NotchMainFeaturesView = .studio
    @State private var isDropTargeted = false
    
    private var shouldOpenNotch: Bool {
        isHovering || isDropTargeted
    }
    
    // 첫 실행할 때 사용되는 변수들
    //    @State private var firstLaunch: Bool = true
    //    @State private var showNGlow: Bool = false
    //    @State private var showHelloAnimation: Bool = false
    //    @State private var helloAnimationCompleted: Bool = false
    
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
            
            //호버링존 + 그외에 관련된것들 -기본적인 NotchUI
            Rectangle()
                .fill(.black)
                .frame(width: vm.notchSize.width, height: vm.notchSize.height)
                .mask { NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10) }
                .overlay {
                    if vm.notchState == .on {
                        VStack {
                            HomeView(currentTab: $currentTab)
                        }
                        .padding()
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .onHover { hovering in
                    isHovering = hovering
                }
                .shadow(color: vm.notchState == .on ? .black.opacity(0.8) : .clear, radius: 3.2)
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
}

// onchange을 ZStack에 통합으로 관리하는 이유 -> 더 간단하기 때문 ㅋㅋㅋㅋ
// 원리 개별에 onChange을 구현햇는데 조건문이 복잡해져서 그냥 통합으로 관리
