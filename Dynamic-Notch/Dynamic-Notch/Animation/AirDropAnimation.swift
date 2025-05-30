//
//  AirDropAnimation.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 5/30/25.
//

import SwiftUI

struct AirDropAnimation: View {
    @State private var ripples: [RippleData] = []
        @State private var isActive: Bool = false
        
        let isPlaying: Bool
        
        var body: some View {
            ZStack {
                ForEach(ripples, id: \.id) { ripple in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .cyan.opacity(0.8),
                                    .blue.opacity(0.6),
                                    .purple.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .scaleEffect(ripple.scale)
                        .opacity(ripple.opacity)
                        .frame(width: 40, height: 40)
                        .animation(.easeOut(duration: 2.5), value: ripple.scale)
                        .animation(.easeOut(duration: 2.5), value: ripple.opacity)
                }
            }
            .onChange(of: isPlaying) { _, newValue in
                if newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
        }
        
        private func startAnimation() {
            isActive = true
            
            // 즉시 첫 번째 리플 생성
            createRipple()
            
            // 1.2초마다 새로운 리플 생성
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { timer in
                guard isActive else {
                    timer.invalidate()
                    return
                }
                createRipple()
            }
        }
        
        private func stopAnimation() {
            isActive = false
            
            // 모든 리플 페이드아웃
            withAnimation(.easeOut(duration: 0.5)) {
                ripples.removeAll()
            }
        }
        
        private func createRipple() {
            let newRipple = RippleData()
            ripples.append(newRipple)
            
            // 리플 애니메이션 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let index = ripples.firstIndex(where: { $0.id == newRipple.id }) {
                    ripples[index].scale = 5.0  // 5배까지 확대
                    ripples[index].opacity = 0.0  // 완전 투명
                }
            }
            
            // 2.5초 후 리플 제거
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                ripples.removeAll { $0.id == newRipple.id }
            }
        }
    }

    // MARK: - RippleData
    struct RippleData {
        let id = UUID()
        var scale: CGFloat = 0.2
        var opacity: Double = 0.9
    }

    // MARK: - Preview
    #Preview {
        VStack(spacing: 30) {
            Text("AirDrop Animation")
                .foregroundColor(.white)
                .font(.headline)
            
            AirDropAnimation(isPlaying: true)
                .frame(width: 100, height: 100)
            
            AirDropAnimation(isPlaying: false)
                .frame(width: 100, height: 100)
        }
        .padding()
        .background(.black)
    }
