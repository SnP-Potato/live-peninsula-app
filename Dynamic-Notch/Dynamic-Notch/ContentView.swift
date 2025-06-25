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
    
    //첫 실행할 때 사용되는 변수들
    @State private var firstLaunch: Bool = true
    @State private var showNGlow: Bool = false
    @State private var showHelloAnimation: Bool = false
    @State private var helloAnimationCompleted: Bool = false
    
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
                            .shadow(color: .white.opacity(0.8), radius: 20)
                            .shadow(color: .cyan.opacity(0.6), radius: 30)
                            .shadow(color: .blue.opacity(0.4), radius: 40)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                                value: showNGlow
                            )
                    }
                    
                }
            
                .overlay {
                    if vm.notchState == .on {
                        // 첫 실행 시 Hello Animation 표시
                        if firstLaunch && showHelloAnimation && !helloAnimationCompleted {
                            VStack {
                                Spacer()
                                
                                HelloAnimation(animationDuration: 4.0)
                                    .frame(width: min(vm.notchSize.width * 0.7, 300),
                                           height: min(vm.notchSize.height * 0.4, 80))
                                    .padding(.horizontal, 20)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity.combined(with: .scale))
                        } else {
                            // Hello 애니메이션 완료 후 또는 일반적인 호버 시 표시되는 확장된 뷰 콘텐츠
                            VStack() {
                                HomeView()
//                                Text("Dynamic Notch")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                
//                                Text("Expanded View")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                
//                                // 추가 콘텐츠들 (음악 재생, 캘린더 등)
//                                HStack(spacing: 20) {
//                                    // 음악 플레이어 영역
//                                    VStack {
//                                        Image(systemName: "music.note")
//                                            .font(.title2)
//                                            .foregroundColor(.white)
//                                        Text("Music")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                    }
//                                    
//                                    // 캘린더 영역
//                                    VStack {
//                                        Image(systemName: "calendar")
//                                            .font(.title2)
//                                            .foregroundColor(.white)
//                                        Text("Calendar")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                    }
//                                    
//                                    // 배터리 영역
//                                    VStack {
//                                        Image(systemName: "battery.100")
//                                            .font(.title2)
//                                            .foregroundColor(.white)
//                                        Text("Battery")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                                .padding(.top, 10)
                            }
                            .padding()
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                }
        }
        .onHover { hovering in
            guard !firstLaunch || helloAnimationCompleted else { return }
            
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
            guard firstLaunch else { return }
            
            // 1. 글로우 효과 시작 (3초간)
            withAnimation(.easeInOut(duration: 0.5)) {
                showNGlow = true
            }
            
            // 2. 3초 후 글로우 종료하면서 노치 열고 바로 Hello Animation 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showNGlow = false
                }
                
                // 노치 열기와 동시에 Hello Animation 시작
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    vm.open()
                    showHelloAnimation = true
                }
                
                // Hello Animation 완료 후 처리
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showHelloAnimation = false
                        helloAnimationCompleted = true
                    }
                    
                    // 노치 닫기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.6)) {
                            vm.close()
                        }
                        
                        // 첫 실행 완료 - 이제 정상적인 호버 인터랙션 가능
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            firstLaunch = false
                        }
                    }
                }
            }
        }
    }
}

