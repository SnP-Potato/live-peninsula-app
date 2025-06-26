//
//  fileDropArea.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/24/25.
//

import SwiftUI

struct FileDropArea: View {
    @State private var droppedFiles: [URL] = []
    @State private var isTargeted = false
    
    var body: some View {
        Rectangle()
            .fill(isTargeted ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
            .frame(width: 300, height: 200)
            .overlay(
                Text(droppedFiles.isEmpty ? "파일을 여기에 드롭하세요" : "\(droppedFiles.count)개 파일")
            )
            .onDrop(of: [.fileURL, .image], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
                return true
            }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (data, error) in
                DispatchQueue.main.async {
                    if let url = data as? URL {
                        self.droppedFiles.append(url)
                        self.copyFileToDocuments(url: url)
                    }
                }
            }
        }
    }
    
    private func copyFileToDocuments(url: URL) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
            print("파일 복사 완료: \(destinationURL)")
        } catch {
            print("파일 복사 실패: \(error)")
        }
    }
}

#Preview {
    FileDropArea()
}
