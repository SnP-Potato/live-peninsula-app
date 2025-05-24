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
    
    var body: some View {
        ZStack(alignment: .top) {
            // 노치 레이아웃과 콘텐츠
            Rectangle()
                .fill(.black)
                .frame(width: vm.notchSize.width, height: vm.notchSize.height)
                .mask {
                    NotchShape(cornerRadius: vm.notchState == .on ? 100 : 10)
                }
            /// MASK:  마우스 호버 감지 및 처리
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
        }
        .frame(maxWidth: onNotchSize.width, maxHeight: onNotchSize.height, alignment: .top)
    }
}

