//
//  SystemHUDOverlayView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//

import SwiftUI

struct SystemHUDOverlayView: View {
    var body: some View {
        ZStack {
            // 화면 전체를 덮는 투명한 영역
            Color.clear
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // HUD 영역 (하단 중앙)
                VStack(spacing: 20) {
                    // 볼륨 HUD
                    VolumeHUDView()
                    
                    // 밝기 HUD
//                    BrightnessHUDView()
                }
                .padding(.bottom, 80) // 하단 여백
            }
        }
    }
}

#Preview {
    SystemHUDOverlayView()
}
