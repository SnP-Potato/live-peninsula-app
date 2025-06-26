//
//  TrayPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct TrayPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.title)
                .foregroundColor(.white.opacity(0.6))
            
            Text("Tray")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("파일 드롭 영역")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.combined(with: .scale))
    }
}

#Preview {
    TrayPlaceholder()
}
