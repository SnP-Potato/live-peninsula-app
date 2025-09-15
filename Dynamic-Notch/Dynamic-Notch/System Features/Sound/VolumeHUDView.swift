//
//  VolumeHUDView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//

// MARK: - VolumeHUDView.swift
import SwiftUI

struct VolumeHUDView: View {
    @ObservedObject var volumeManager = VolumeManager.shared
    
    var body: some View {
        if volumeManager.isVolumeHUDVisible {
            HStack(spacing: 12) {
                // 볼륨 아이콘
                Image(systemName: volumeIconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                
                // 프로그레스 바
                ProgressView(value: volumeManager.currentVolume, total: 1.0)
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
}

#Preview {
    VolumeHUDView()
        .padding()
        .frame(width: 300, height: 300)
}
