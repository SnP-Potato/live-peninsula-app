//
//  AnimationMeshGradient.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/5/25.
//

import SwiftUI

struct AnimationMeshGradient: View {
    @State var appear = false
    @State var appear2 = false
    
    var body: some View {
        if #available(macOS 15.0, *) {
            MeshGradient(
                width: 3,
                height: 4,
                points: [ //colors들의 좌표 설정
                    [0.0, 0.0], [appear2 ? 0.5 : 1.0, 0.0], [1.0, 0.0],
                    [0.0, 0.5], appear ? [0.1, 0.5] :[0.8, 0.2], [1.0, -0.5],
                    [0.0, 1.0], [appear2 ? 0.5 : 1.0, 0.0], [1.0, 1.0],
                    
                        ],
                colors: [
                    appear2 ? .red : .mint, appear2 ? .yellow : .cyan, .orange,
                    appear ? .blue : .red, appear ? .cyan : .white, appear ? .red : .purple,
                    appear ? .red : .cyan, appear ? .mint : .blue, appear2 ? .red : .blue
                ]
            )
            .ignoresSafeArea()
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    AnimationMeshGradient()
}
