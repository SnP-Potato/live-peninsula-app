//
//  TrayPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI

struct TrayPlaceholder: View {
    @State private var isDropTargeted = false
    @ObservedObject var trayManager = TrayManager.shared
    
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
                    if trayManager.files.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray.and.arrow.down.fill")
                            
                            Text("Drop files here")
                                .bold()
                        }
                        .foregroundColor(.gray)
                    }else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {  // 이걸 추가해야 함!
                                ForEach(trayManager.files) { file in
                                    VStack {
                                        // 파일 정보 표시
                                        Text(file.fileName)
                                            .font(.caption)
                                        Text(file.fileExtension)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 60, height: 60)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 8)
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
