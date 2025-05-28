//
//  HelloAnimationView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 5/27/25.
//

import SwiftUI

struct HelloAnimationView: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack {
            HellowAnimation()
                .trim(from: 0.0, to: progress)
                .stroke(Self.gradient, style: StrokeStyle(lineWidth: 13, lineCap: .round, lineJoin: .round))
                .aspectRatio(contentMode: .fit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .onAppear(perform: animate)
        .onTapGesture {
            progress = 0
            animate()
        }
    }
}

private extension HelloAnimationView {
    static let gradient = LinearGradient(
        gradient:
            Gradient(colors: [
                .white
            ] 
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    func animate() {
        withAnimation(.easeInOut(duration: 3)) {
            progress = 1
        }
    }
}


#Preview {
    HelloAnimationView()
}
