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
    
    func copyfileToTrayStorage(source: URL) -> URL? {
        let fileName = source.lastPathComponent
        
        do {
            let copiedURL = trayStorage.appendingPathComponent(fileName)
            try FileManager.default.copyItem(at: source, to: copiedURL)
            print("\(fileName)가 trayStorage에 복사됨")
            addFile(source: copiedURL)
            return copiedURL
        } catch {
            print("\(error.localizedDescription)")
            return nil
        }
    }
    
    func addFile(source: URL) {
        let isfileExists = FileManager.default.fileExists(atPath: source.path)
        
        //파일의 데이터를 추출
        let fileName = source.lastPathComponent
        let fileExtension = source.pathExtension
        let fileThumnail: Data? = nil
        
        guard isfileExists else {
            print("파일이 없어요 다시 확인부탁 ")
            return
        }
        
        print("파일이 있어요 \(source.lastPathComponent)")
        let trayFile = TrayFile(
            id: UUID(),
            fileName: fileName,
            fileExtension: fileExtension,
            thumbnailData: fileThumnail
        )
        
        files.append(trayFile)
        print(files)
    }
    
}
