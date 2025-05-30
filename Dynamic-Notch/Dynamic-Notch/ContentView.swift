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

struct ContentView: View {
    @EnvironmentObject var vm: NotchViewModel
    
    // 호버 상태 관리를 위한 변수들
    @State private var isHovering: Bool = false
    @State private var hoverAnimation: Bool = false
    
    @State private var firstLaunch: Bool = true
    @State private var showNGlow: Bool = false
    
    @State private var showWave: Bool = false
    @State private var wavePhase: Double = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // 노치 레이아웃과 콘텐츠
            Rectangle()
                .fill(.black)
                .frame(width: vm.notchSize.width, height: vm.notchSize.height)
                .mask {
                    NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10)
                }
                .background {
                    //glow효과 구현
                    if firstLaunch && vm.notchState == .off && showNGlow {
                        NotchShape(cornerRadius: 10)
                            .fill(.white)
                            .shadow(color: .white.opacity(0.8), radius: 10)
                            .shadow(color: .cyan.opacity(0.6), radius: 20)
                            .shadow(color: .blue.opacity(0.4), radius: 30)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                                value: showNGlow
                            )
                    }
                }
                .overlay {
                    if vm.notchState == .on {
                        // 노치가 열렸을 때 보여줄 내용 (캘린더, 상세 정보 등)
                        VStack {
                            Text("Dynamic Notch")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Expanded View")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
        }
        .onHover { hovering in
            if hovering {
                // 마우스가 올라갔을 때
                withAnimation(.spring(response: 0.3)) {
                    hoverAnimation = true
                    isHovering = true
                }
                
                // 노치가 닫혀있다면 열기
                if vm.notchState == .off {
                    withAnimation(.spring(response: 0.5)) {
                        vm.open()
                    }
                }
            } else {
                // 마우스가 벗어났을 때
                withAnimation(.spring(response: 0.3)) {
                    hoverAnimation = false
                    isHovering = false
                }
                
                // 노치가 열려있다면 닫기
                if vm.notchState == .on {
                    withAnimation(.spring(response: 0.5)) {
                        vm.close()
                    }
                }
            }
        }
        .frame(maxWidth: onNotchSize.width, maxHeight: onNotchSize.height, alignment: .top)
        .shadow(color: (vm.notchState == .on || vm.notchState == .off) ? .black.opacity(0.8) : .clear, radius: 3.2)
        .onAppear {
            // 간단하게 글로우만!
            if firstLaunch {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showNGlow = true
                }
                
                // 3초 후 글로우 종료
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.spring(response: 0.5)) {
                        showNGlow = false
                        firstLaunch = false
                    }
                }
            }
        }
    }
}
