//
//  TrayPlaceholder.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/26/25.
//

import SwiftUI
import QuickLook //파일 미리보기(썸네일)
import UniformTypeIdentifiers

struct TrayPlaceholder: View {
    @State private var isDropTargeted = false
    @ObservedObject var trayManager = TrayManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            
            //airdrop
            RoundedRectangle(cornerRadius: 12)
                .fill(isDropTargeted ? .blue.opacity(0.2) : .white.opacity(0.1))
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
                .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                    var fileURLs: [URL] = []
                    
                    for provider in providers {
                        _ = provider.loadObject(ofClass: URL.self) { url, error in
                            if let fileURL = url, error == nil {
                                fileURLs.append(fileURL)
                                
                                // 모든 파일 로드 완료 후 AirDrop 실행
                                if fileURLs.count == providers.count {
                                    DispatchQueue.main.async {
                                        TrayManager.shared.openAirDrop(with: fileURLs)
                                    }
                                }
                            }
                        }
                    }
                    return true
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
                            HStack(spacing: 12) {
                                ForEach(trayManager.files) { file in
                                    ZStack(alignment: .topTrailing) {
                                        // 파일 카드
                                        VStack(spacing: 6) {
                                            // 파일 아이콘
                                            ThumbnailImage(file: file)
                                            
                                            // 파일명 (확장자 제거)
                                            Text((file.fileName as NSString).deletingPathExtension)
                                                .font(.caption)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                                .foregroundColor(.white)
                                            
                                            // 확장자 (있을 때만)
                                            if !file.fileExtension.isEmpty {
                                                Text(file.fileExtension.uppercased())
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 1)
                                                    .background(Color.gray.opacity(0.2))
                                                    .cornerRadius(3)
                                            }
                                        }
                                        .frame(width: 70, height: 80)
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(8)
                                        .onDrag {
                                            let fileURL = TrayManager.shared.trayStorage.appendingPathComponent(file.fileName)
                                            return NSItemProvider(object: fileURL as NSURL)
                                        }
                                        
                                        // 삭제 버튼 (우측 상단)
                                        Button(action: {
                                            TrayManager.shared.deleteFile(fileName: file.fileName)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 14))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .offset(x: 4, y: -4) 
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                    }
                }
        }
        .padding(.horizontal, 8)
    }
}


struct ThumbnailImage: View {
    let file: TrayFile
    @State private var thumbnailImage: NSImage?
    
    var body: some View {
        Group {
            if let thumbnailImage = thumbnailImage {
                Image(nsImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "doc.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            if let data = file.thumbnailData {
                thumbnailImage = NSImage(data: data)
            }
        }
    }
}



#Preview {
    TrayPlaceholder()
        .frame(width: 400, height: 120)
        .background(.black)
        .padding()
}
