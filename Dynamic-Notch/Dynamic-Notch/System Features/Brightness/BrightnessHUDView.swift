//
//  BrightnessHUDView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//
import SwiftUI

struct BrightnessHUDView: View {
    @ObservedObject var brightnessManager = BrightnessManager.shared
    
    var body: some View {
        if brightnessManager.isBrightnessHUDVisible {
            HStack(spacing: 12) {
                // 밝기 아이콘
                Image(systemName: brightnessIconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                
                // 프로그레스 바
                ProgressView(value: brightnessManager.currentBrightness, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: 100, height: 4)
                    .scaleEffect(y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.8)).animation(.spring(response: 0.4, dampingFraction: 0.7)),
                removal: .opacity.animation(.easeInOut(duration: 0.3))
            ))
        }
    }
    
    private var brightnessIconName: String {
        if brightnessManager.currentBrightness == 0 {
            return "sun.min.fill"
        } else if brightnessManager.currentBrightness < 0.33 {
            return "sun.min.fill"
        } else if brightnessManager.currentBrightness < 0.66 {
            return "sun.max.fill"
        } else {
            return "sun.max.fill"
        }
    }
}

#Preview {
    BrightnessHUDView()
        .padding()
        .frame(width: 300, height: 300)
}
