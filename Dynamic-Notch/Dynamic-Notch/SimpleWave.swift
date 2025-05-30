//
//  SimpleWave.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 5/30/25.
//

import SwiftUI

struct SimpleWave: View {
    @State private var waveOffset: CGFloat = 0
        
        var body: some View {
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    // 웨이브 시작점 (하단 기준선)
                    path.move(to: CGPoint(x: 0, y: height))
                    
                    // 웨이브 그리기 - 노치 하단 평행선을 물결로
                    for x in stride(from: 0, through: width, by: 1) {
                        let angle = (x / width) * 6 * .pi + (waveOffset * .pi)
                        let y = height - (sin(angle) * height * 0.8) // 아래에서 위로 웨이브
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.black, lineWidth: 1.5)
                .shadow(color: .black.opacity(0.6), radius: 3)
            }
            .onAppear {
                // 웨이브 애니메이션 시작
                withAnimation(
                    .linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
                ) {
                    waveOffset = 2
                }
            }
        }
}

#Preview {
    SimpleWave()
}
