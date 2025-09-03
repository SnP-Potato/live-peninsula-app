//
//  firstLaunch.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 9/2/25.
//

import SwiftUI
import AVFoundation

struct firstLaunchView: View {
    @State private var showRMG: Bool = true
    @State private var showHelloAnimation: Bool = false
    @State private var expandNotch: Bool = false
    @State private var notchWidth: CGFloat = 200
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // Ripple + Mesh Gradient 효과
            NotchShape(cornerRadius: showHelloAnimation ? 100 : 10)
                .fill(.black)
                .frame(
                    width: showHelloAnimation ? 300 : notchWidth,
                    height: showHelloAnimation ? 120 : 32
                )
                .background {
                    ZStack {
                        if showRMG {
                            GradientAnimation()
                                .frame(
                                    width: showHelloAnimation ? 300 : notchWidth,
                                    height: showHelloAnimation ? 100 : 32
                                )
                            ForEach(0..<4, id: \.self) { index in
                                GlowLayer(index: index, animationPhase: 10)
                            }
                        }
                    }
                }
                .overlay {
                    if showHelloAnimation {
                        HelloAnimation()
                            .frame(width: 210, height: 70)
                            .padding(.top, 30)
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                    removal: .opacity.combined(with: .scale(scale: 0.8))
                                )
                            )
                    }
                }
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3),
                    value: showHelloAnimation
                )
        }
        .onAppear {
            // 🔊 사운드 재생 시작
            playLaunchSound()
            
            // 초기 ripple + mesh gradient 표시 (3초)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // 노치 확장 + HelloAnimation 시작 & 전 애니메이션 종료
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showHelloAnimation = true
                    showRMG = false
                }
                
                // HelloAnimation 완료 후 원래 상태로 복귀
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        showHelloAnimation = false
                        notchWidth = 185
                    }
                }
            }
        }
        .onDisappear {
            // 뷰가 사라질 때 오디오 정리
            stopLaunchSound()
        }
    }
    
    // MARK: - 사운드 재생 함수들
    private func playLaunchSound() {
        guard let soundURL = Bundle.main.url(forResource: "launchSound", withExtension: "m4a") else {
            print("❌ launchSound.m4a 파일을 찾을 수 없습니다.")
            return
        }
        
        do {
            // AVAudioPlayer 초기화
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            
            // 볼륨 설정 (0.0 ~ 1.0)
            audioPlayer?.volume = 0.8
            
            // 사운드 재생
            audioPlayer?.play()
            print("🔊 런치 사운드 재생 시작")
            
        } catch {
            print("❌ 사운드 재생 실패: \(error.localizedDescription)")
        }
    }
    
    private func stopLaunchSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        print("🔇 런치 사운드 정지")
    }
}

#Preview {
    firstLaunchView()
        .frame(width: 400, height: 500)
}
#Preview {
    firstLaunchView()
        .frame(width: 180, height: 32)
}
