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
        let originalFileName = source.lastPathComponent
        let uniqueFileName = modifyDuplicatefileName(fileName: originalFileName)
        
        do {
            let copiedURL = trayStorage.appendingPathComponent(uniqueFileName)
            try FileManager.default.copyItem(at: source, to: copiedURL)
            print("\(uniqueFileName)가 trayStorage에 복사됨")
            
            let trayFile = TrayFile(
                id: UUID(),
                fileName: (uniqueFileName as NSString).deletingPathExtension,
                fileExtension: (uniqueFileName as NSString).pathExtension,
                thumbnailData: nil
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
    
    // fileName에 "photo.png"형태로 이렇게 들어옴 그래서 여기서 확장자랑 파일이름을 분리해서 파일이름이 중복된 경우 (1)증가해서 저장
    func modifyDuplicatefileName(fileName: String) -> String {
        let nsString = fileName as NSString // 문자열로 변환 그래야 deletingPathExtension사용가능
        let nameOnly = nsString.deletingPathExtension
        let fileExtension = nsString.pathExtension
        
        let originalPath = trayStorage.appendingPathComponent(fileName)
        if !FileManager.default.fileExists(atPath: originalPath.path) {
            return fileName  // 중복 없으면 원본 그대로
        }
        
        var count = 1
        var newFileName = ""
        
        while true {
            if fileExtension.isEmpty {                      //확장자가 없는 경우 ex) README파일 등등
                newFileName = "\(nameOnly)(\(count))"
            } else {                                        //확장자가 있는 경우
                newFileName = "\(nameOnly)(\(count)).\(fileExtension)"
            }
            
            //만약에 중복된 파일에 네버링을 추가해서 복사했는데 또 같은 파일이 들어오는 경우
            let newpath = trayStorage.appending(component: newFileName)
            if !FileManager.default.fileExists(atPath: newpath.path) {
                break
            }
            count += 1
        }
        return newFileName
    }
    
    //저장된 파일을 삭제하는 함수(TrayFile배열이랑 TrayStorage에서도 삭제 하게끔)
    func deleteFile(fileName: String) {
        
        let filePath = trayStorage.appendingPathComponent(fileName)
        if !FileManager.default.fileExists(atPath: filePath.path) {
            print("디렉토리에 저장되어있지않음")
        } else {
            
            do {
                //TraySotrage에서 삭제
                try FileManager.default.removeItem(at: filePath)
                print("디렉토리에 \(fileName)이 삭제 되었습니다.")
                
                //TrayFile배열도 삭제  [Point 매인스레드로 변경해서 삭제]
                DispatchQueue.main.async { [weak self] in
                    if let index = self?.files.firstIndex(where: { $0.fileName == fileName }) {
                        self?.files.remove(at: index)
                        print("배열에서 제거 완료: \(fileName)")
                    }
                }
                
            } catch {
                print("파일삭제 실패: \(error.localizedDescription)")
            }
        }
    }
    
    //파일의 썸네일(미리보기) 추출하는 함수
//    func extractfileThumbnail(source: URL) -> Data? {
//        
//    }
    
    //
}
