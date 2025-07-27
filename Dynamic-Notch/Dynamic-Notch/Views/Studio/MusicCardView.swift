//
//  MusicCardView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/25/25.
//

//import SwiftUI
//struct MusicCardView: View {
//    @Binding var musicCardclick: Bool
//    @State private var isPlaying: Bool = true
//    
//    var body: some View {
//        ZStack {
//            // 배경 이미지
//            Image("dirtywork")
//                .resizable()
//                .frame(width: 110, height: 110)
//                .scaledToFill()
//                .clipShape(RoundedRectangle(cornerRadius: 12))
////                .glassEffect()
//            
//            if musicCardclick {
//                ZStack {
//                    Image("dirtywork")
//                        .resizable()
//                        .frame(width: 110, height: 110)
//                        .scaledToFill()
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        
//                        
//                     
////
////                        
////                    
////                     //추가 glass 효과 (선택사항 - 더 강화하고 싶다면)
////                    RoundedRectangle(cornerRadius: 12)
////                        .fill(.black.opacity(0.1))
////                        .overlay {
////                            RoundedRectangle(cornerRadius: 12)
////                                .stroke(.white.opacity(0.08), lineWidth: 0.5)
////                        }
//                        
//                    Rectangle()
//                        .frame(width: 110, height: 110)
//                        .cornerRadius(12)
//                        .glassEffect(.regular, in: .rect)
//                    
//                    VStack(alignment: .center, spacing: 2) {
//                        Text("Dirty Work")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                            .lineLimit(1)
//                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
//                        
//                        Text("aespa")
//                            .font(.system(size: 11, weight: .regular))
//                            .foregroundColor(.white.opacity(0.9))
//                            .lineLimit(1)
//                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
//                        
//                        Spacer()
//                            .frame(height: 12)
//                        
//                        HStack(spacing: 18) {
//                            Button(action: {
//                                // 이전 곡
//                            }) {
//                                Image(systemName: "backward.fill")
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(.white)
//                                
//                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            .scaleEffect(musicCardclick ? 1.0 : 0.8)
//                            
//                            Button(action: {
//                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                                    isPlaying.toggle()
//                                }
//                            }) {
//                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                                    .font(.system(size: 16, weight: .medium))
//                                    .foregroundColor(.white)
//                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            .buttonStyle(.glass)
//                            .scaleEffect(musicCardclick ? 1.1 : 0.8)
//                            
//                            Button(action: {
//                                // 다음 곡
//                            }) {
//                                Image(systemName: "forward.fill")
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(.white)
//                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            .scaleEffect(musicCardclick ? 1.0 : 0.8)
//                        }
//                    }
//                    .padding(.horizontal, 8)
//                }
//                .frame(width: 110, height: 110)
//                .transition(.asymmetric(
//                    insertion: .scale(scale: 0.8).combined(with: .opacity),
//                    removal: .scale(scale: 1.1).combined(with: .opacity)
//                ))
//            }
//            
//            // 앨범 아트 위 작은 앱 아이콘 (옵션)
//            if !musicCardclick {
//                Image("musicApp")
//                    .resizable()
//                    .frame(width: 22, height: 22)
//                    .scaledToFill()
//                    .clipShape(RoundedRectangle(cornerRadius: 6))
//                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
//                    .offset(x: 34, y: 34)
//                    .transition(.scale.combined(with: .opacity))
//            }
//        }
//        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: musicCardclick)
//        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
//    }
//}
//
//// MARK: - iOS 18 Liquid Glass 스타일 확장
//extension View {
//    func liquidGlassEffect(cornerRadius: CGFloat = 12) -> some View {
//        self
//            .background {
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(.ultraThinMaterial)
//                    .overlay {
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .fill(.black.opacity(0.1))
//                            .blendMode(.overlay)
//                    }
//                    .overlay {
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .stroke(.white.opacity(0.1), lineWidth: 0.5)
//                    }
//            }
//    }
//}
//
//#Preview {
//    ZStack {
//        MusicCardView(musicCardclick: .constant(false))
//    }
//    .frame(width: 400, height: 300)
//}


//
//  MusicCardView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/25/25.
//

import SwiftUI

struct MusicCardView: View {
    @Binding var musicCardclick: Bool
    @State private var isPlaying: Bool = true
    
    var body: some View {
        ZStack {
            // 배경 앨범 이미지
            Image("dirtywork")
                .resizable()
                .frame(width: 110, height: 110)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if musicCardclick {
                // Liquid Glass로 앨범 아트를 완전히 덮기
                LiquidGlassBackground(
                    variant: .v11,
                    cornerRadius: 12
                ) {
                    ZStack {
                        // 배경을 더 어둡게 처리
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.4))
                        
                        musicControlInterface
                    }
                }
                .frame(width: 110, height: 110)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 1.1).combined(with: .opacity)
                ))
            }
            
            // 앨범 아트 위 작은 앱 아이콘
            if !musicCardclick {
                appIcon
            }
        }
        .frame(width: 110, height: 110) // 전체 컨테이너 크기 고정
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: musicCardclick)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
    }
    
    // MARK: - 음악 제어 인터페이스 (크기 축소)
    @ViewBuilder
    private var musicControlInterface: some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Dirty Work")
                .font(.system(size: 15, weight: .bold)) // 폰트 크기 축소
                .foregroundColor(.white)
                .lineLimit(1)
                .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 1)
            
            Text("aespa")
                .font(.system(size: 10, weight: .semibold)) // 폰트 크기 축소
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
            
            Spacer()
                .frame(height: 6) // 간격 축소
            
            HStack(spacing: 12) { // 버튼 간격 축소
                realGlassControlButton(icon: "backward.fill", size: 12) // 아이콘 크기 축소
                realGlassControlButton(icon: isPlaying ? "pause.fill" : "play.fill", size: 14, isMain: true) { // 메인 버튼도 축소
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPlaying.toggle()
                    }
                }
                realGlassControlButton(icon: "forward.fill", size: 12) // 아이콘 크기 축소
            }
        }
        .padding(.horizontal, 8) // 패딩 축소
        .padding(.vertical, 6)   // 패딩 축소
    }
    
    // MARK: - Real Glass 스타일 버튼 (크기 축소)
    private func realGlassControlButton(
        icon: String,
        size: CGFloat,
        isMain: Bool = false,
        action: @escaping () -> Void = {}
    ) -> some View {
        Button(action: action) {
            LiquidGlassBackground(
                variant: .v8,
                cornerRadius: isMain ? 15 : 12 // 모서리 반경 축소
            ) {
                Image(systemName: icon)
                    .font(.system(size: size, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.9), radius: 1, x: 0, y: 1)
                    .frame(width: isMain ? 28 : 24, height: isMain ? 28 : 24) // 버튼 크기 축소
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isMain ? 1.05 : 1.0) // 스케일 축소
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
    }
    
    // MARK: - 앱 아이콘
    @ViewBuilder
    private var appIcon: some View {
        Image("musicApp")
            .resizable()
            .frame(width: 22, height: 22)
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
            .offset(x: 34, y: 34)
            .transition(.scale.combined(with: .opacity))
    }
}

#Preview("Music Card - Fixed Size") {
    ZStack {
        LinearGradient(
            colors: [.blue, .purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        VStack(spacing: 30) {
            Text("Fixed Size Music Card")
                .foregroundColor(.white)
                .font(.title)
            
            HStack(spacing: 20) {
                // 클릭 안된 상태
                MusicCardView(musicCardclick: .constant(false))
                
                // 클릭된 상태
                MusicCardView(musicCardclick: .constant(true))
            }
            
            Text("Both cards are same size (110x110)")
                .foregroundColor(.white.opacity(0.8))
                .font(.caption)
        }
    }
    .frame(width: 600, height: 400)
}
