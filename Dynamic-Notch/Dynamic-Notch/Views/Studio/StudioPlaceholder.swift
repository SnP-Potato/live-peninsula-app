//
//  StudioPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct StudioPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "widget.small")
                .font(.title)
                .foregroundColor(.white.opacity(0.6))
            
            Text("Studio")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("음악, 미디어 컨트롤")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.combined(with: .scale))
    }
}
#Preview {
    StudioPlaceholder()
}
