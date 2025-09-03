//
//  ripple+ mesh gradient.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/5/25.
//

import SwiftUI

// 분리된 글로우 레이어 컴포넌트 
struct GlowLayer: View {
    let index: Int
    let animationPhase: Int
    
    var body: some View {
        let layerWidth = 185 + CGFloat(index * 25)
        let layerHeight = 32 + CGFloat(index * 23)
        let cornerRadius = CGFloat(10 + index * 8)
        let opacity = 0.4 - Double(index) * 0.08
        let blurRadius = CGFloat(index * 4 + 2)
        let scaleEffect = animationPhase == 0 ? 0.8 : 1.0
        let animationDelay = Double(index) * 0.2
        
        ripple_mesh()
            .frame(width: layerWidth, height: layerHeight)
            .clipShape(NotchShape(cornerRadius: cornerRadius))
            .opacity(opacity)
            .blur(radius: blurRadius)
            .scaleEffect(scaleEffect)
            .animation(
                .easeOut(duration: 2.0 + animationDelay),
                value: animationPhase
            )
    }
}


struct ripple_mesh: View {
    @State var appear = false
    @State var appear2 = false
    @State var appear3 = false
    
    var body: some View {
        if #available(macOS 15.0, *) {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0, 0], [appear2 ? 0.5 : 1.0, 0.0], [1.0, 0.0],
                    [0, 0.5], appear ? [0.1, 0.5] : [0.8, 0.2], [1, appear3 ? -0.3 : -0.7],
                    [0, 1.0], [1.0, appear2 ? 1.8 : 1.2], [1.0, 1.0]
                ],
                colors: [
                    appear2 ? .purple : .cyan, appear2 ? .blue : .mint,
                    appear3 ? .orange : .yellow,
                    appear ? .blue : .red, appear ? .white : .cyan, appear ?
                        .purple : .red,
                    appear ? .cyan : .red, appear ? .mint : .purple, appear2 ?
                        .blue : .red
                ]
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    appear.toggle()
                }
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    appear2.toggle()
                }
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    appear3.toggle()
                }
            }
        } else {
            // macOS 15.0 미만에서의 대체 효과
            LinearGradient(
                colors: [.purple, .blue, .cyan, .mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
#Preview {
    VStack {
        ripple_mesh()
            .clipShape(NotchShape(cornerRadius: 100))
            
    }
}
