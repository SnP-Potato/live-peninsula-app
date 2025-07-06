//
//  TrayManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/28/25.
//

// DynamicNotch에 TrayView에 저장소 구현
// 파일 등 드래그시 복사해서 저장
import SwiftUI
import Foundation

class TrayManager: ObservableObject {
   
    static let shared = TrayManager()
    
    @Published var files: [TrayFile] = []
    
//    private let weStorageURL: URL
    private let trayStorage: URL
    
    private init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        self.weStorageURL = directory.appendingPathComponent("Dynamic-Notch")
        
        //별도의 저장소 생성
        self.trayStorage = directory.appendingPathComponent("TrayStorage")
        
        createDirectory()
        
    }
    
    func createDirectory() {
        do {
            try FileManager.default.createDirectory(at: trayStorage, withIntermediateDirectories: true)
            print("경로는 : \(trayStorage.path)")
            
            NSWorkspace.shared.open(trayStorage)
        } catch {
            print("경로생성 실패")
        }
    }
    
    func addFileToTray(source: URL) -> URL? {
        //TrayFile에 맞게 파일 데이터 추출하는 변수
        let fileName = source.lastPathComponent
        let fileExtension = source.pathExtension
        let fileThumbnail: Data? = nil
        
        
        do {
            let copiedURL = trayStorage.appendingPathComponent(fileName)
            try FileManager.default.copyItem(at: source, to: copiedURL)
            print("\(fileName)가 trayStorage에 복사됨")
            
            let trayFile = TrayFile(
                id: UUID(),
                fileName: fileName,
                fileExtension: fileExtension,
                thumbnailData: fileThumbnail
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.files.append(trayFile)
                print(self?.files ?? [])
            }
            return copiedURL
            
        } catch {
            print("\(error.localizedDescription)")
            return nil
        }
    }
}
