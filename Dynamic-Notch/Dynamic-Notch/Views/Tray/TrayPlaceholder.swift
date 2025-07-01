//
//  TrayPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct TrayPlaceholder: View {
    @State private var isDropTargeted = false
    @State private var droppedFiles: [String] = []
    var body: some View {
        HStack(spacing: 16) {
            
            //airdrop button
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
                .frame(width: 120)
                .overlay {
                    VStack(spacing: 9) {
                        Image(systemName: "airplay.audio")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("AirDrop")
                            .foregroundColor(.gray)
                            .bold()
                    }
                }
            
            
            //drag file tray
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10, 8]))
                .foregroundStyle(.white.opacity(0.17))
                .overlay {
                    if droppedFiles.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray.and.arrow.down.fill")
                            
                            Text("Drop files here")
                                .bold()
                        }
                        .foregroundColor(.gray)
                    }else {
                        ScrollView(.horizontal) {
                            
                        }
                    }
                }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    TrayPlaceholder()
        .frame(width: 400, height: 120)
        .background(.black)
        .padding()
}
