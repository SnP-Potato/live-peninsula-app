//
//  Gradient.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 9/2/25.
//

import SwiftUI

struct GradientAnimation: View {
    @State var rotation: CGFloat = 0.0
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width:500, height: 200)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(
                        colors:[.yellow.opacity(0.1), .mint.opacity(0.2), .yellow.opacity(0.1),
                                .purple, .orange, .pink, .purple, .cyan, .purple, .pink, .orange,
                                .yellow.opacity(0.1), .mint.opacity(0.2), .yellow.opacity(0.1),]),
                        startPoint: .top,
                        endPoint: .bottom
                ))
                .rotationEffect(.degrees(rotation))
                .mask {
                    NotchShape(cornerRadius: 10)
    
                        .stroke(lineWidth: 9)
                        .frame(width:200, height: 32)
                }
            
                
            Rectangle()
                .clipShape(NotchShape(cornerRadius: 10))
                .frame(width: 200, height: 32)
                .foregroundColor(.black)
                
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width:500, height: 200)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(
                        colors:[.red, .orange,.yellow,.green,.blue,.purple,.pink]),
                        startPoint: .top,
                        endPoint: .bottom
                ))
                .rotationEffect(.degrees(rotation))
                .mask {
                    NotchShape(cornerRadius: 10)
    
                        .stroke(lineWidth: 6)
                        .frame(width:200, height: 32)
                }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    GradientAnimation ()
        .frame(width: 500, height: 600)
}
