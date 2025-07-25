//
//  MusicCardView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/25/25.
//

import SwiftUI

//struct MusicCardView: View {
//    @Binding var musicCardclick: Bool
//    @State private var isPlaying: Bool = true
//    
//    var body: some View {
//        ZStack {
//            // 배경 이미지
//            Image("musicImage 1")
//                .resizable()
//                .frame(width: 110, height: 110)
//                .scaledToFill()
//                .cornerRadius(12)
//            
//            if musicCardclick {
//                ZStack {
//                    // 나중에 liquid glass로 대체할 예정
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(.ultraThinMaterial)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(.black.opacity(0.2))
//                                .blendMode(.overlay)
//                        }
//                        .overlay {
//                            // 추가적인 glass 효과
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(.white.opacity(0.1), lineWidth: 1)
//                        }
//                        .background {
//                            // 뒷배경 블러 효과
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(.black.opacity(0.3))
//                                .blur(radius: 8)
//                        }
//                    VStack(alignment: .center, spacing: 2) {
//                        Text("Heat Waves")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                            .lineLimit(1)
//                        
//                        Text("Grass Animals")
//                            .font(.system(size: 11, weight: .regular))
//                            .foregroundColor(.white.opacity(0.5))
//                            .lineLimit(1)
//                        
//                        Spacer()
//                            .frame(height: 12)
//                        
//                        HStack(spacing: 18) {
//                            Button(action: {
//                                //
//                            }) {
//                                Image(systemName: "backward.fill")
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(.white)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            
//                            Button(action: {
//                                //
//                            }) {
//                                Image(systemName: "pause.fill")
//                                    .font(.system(size: 16, weight: .medium))
//                                    .foregroundColor(.white)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            
//                            Button(action: {
//                                //
//                            }) {
//                                Image(systemName: "forward.fill")
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(.white)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                    }
//                }
//                .frame(width: 110, height: 110)
//            }
//        }
//    }
//}
//
//
//
//
//
//#Preview {
//    MusicCardView(musicCardclick: .constant(true))
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
            // 배경 이미지
            Image("dirtywork")
                .resizable()
                .frame(width: 110, height: 110)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if musicCardclick {
                ZStack {
                    // 연한 Liquid Glass 효과 배경
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.black.opacity(0.05))
                                .blendMode(.overlay)
                        }
                        .overlay {
                            // 매우 연한 glass 효과
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.05), lineWidth: 0.5)
                        }
                        .background {
                            // 뒷배경 블러 효과 (더 연하게)
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.black.opacity(0.1))
                                .blur(radius: 6)
                        }
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Dirty Work")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        
                        Text("aspa")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        
                        Spacer()
                            .frame(height: 12)
                        
                        HStack(spacing: 18) {
                            Button(action: {
                                // 이전 곡
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(musicCardclick ? 1.0 : 0.8)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isPlaying.toggle()
                                }
                            }) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(musicCardclick ? 1.1 : 0.8)
                            
                            Button(action: {
                                // 다음 곡
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(musicCardclick ? 1.0 : 0.8)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(width: 110, height: 110)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 1.1).combined(with: .opacity)
                ))
            }
            
            // 앨범 아트 위 작은 앱 아이콘 (옵션)
            if !musicCardclick {
                Image("musicApp")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .offset(x: 34, y: 34)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: musicCardclick)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
    }
}

// MARK: - iOS 18 Liquid Glass 스타일 확장
extension View {
    func liquidGlassEffect(cornerRadius: CGFloat = 12) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.black.opacity(0.1))
                            .blendMode(.overlay)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.white.opacity(0.1), lineWidth: 0.5)
                    }
            }
    }
}

#Preview {
    ZStack {
        // 테스트용 배경
        LinearGradient(
            colors: [.blue, .purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            Text("Liquid Glass Music Card")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // 클릭되지 않은 상태
                MusicCardView(musicCardclick: .constant(false))
                
                // 클릭된 상태
                MusicCardView(musicCardclick: .constant(true))
            }
        }
    }
    .frame(width: 400, height: 300)
}
