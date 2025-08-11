//
//  TrayManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/28/25.
//

// DynamicNotch에 TrayView에 저장소 구현
// 파일 등 드래그시 복사해서 저장
//import SwiftUI
//import Foundation
//import QuickLookThumbnailing
//import QuickLook
//
//class TrayManager: ObservableObject {
//    
//    static let shared = TrayManager()
//    
//    @Published var files: [TrayFile] = []
//    
//    //    private let weStorageURL: URL
//    let trayStorage: URL
//    
//    private init() {
//        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        //        self.weStorageURL = directory.appendingPathComponent("Dynamic-Notch")
//        
//        //별도의 저장소 생성
//        self.trayStorage = directory.appendingPathComponent("TrayStorage")
//        
//        createDirectory()
//        
//        cleanDirectory()
//    }
//    
//    func createDirectory() {
//        do {
//            try FileManager.default.createDirectory(at: trayStorage, withIntermediateDirectories: true)
//            print("경로는 : \(trayStorage.path)")
//            
//            //NSWorkspace.shared.open(trayStorage)
//        } catch {
//            print("경로생성 실패")
//        }
//    }
//    
//    //앱 실행하면 TraySotrage를 다 비우는 함수
//    func cleanDirectory() {
//        
//        //먼저 디렉토리 여부 확인
//        if FileManager.default.fileExists(atPath: trayStorage.path) {
//            do {
//                let contents = try FileManager.default.contentsOfDirectory(at: trayStorage, includingPropertiesForKeys: nil)
//                for item in contents {
//                    try FileManager.default.removeItem(at: item)
//                }
//                print("TrayStorage 정리 완료")
//            } catch {
//                print("TrayStorage 정리 실패: \(error)")
//            }
//            
//            // 3. files 배열도 비우기
//            files.removeAll()
//            print("TrayFile배열도 정리 완료")
//            
//        } else {
//            print("디렉토리가 생성되지 않았습니다")
//            createDirectory()
//        }
//        
//    }
//    
//    func addFileToTray(source: URL) -> URL? {
//        let originalFileName = source.lastPathComponent
//        let uniqueFileName = modifyDuplicatefileName(fileName: originalFileName)
//        
//        do {
//            let copiedURL = trayStorage.appendingPathComponent(uniqueFileName)
//            try FileManager.default.copyItem(at: source, to: copiedURL)
//            print("\(uniqueFileName)가 trayStorage에 복사됨")
//            
//            // 썸네일 생성 호출 추가
//            generateThumbnail(for: copiedURL) { [weak self] thumbnailData in
//                let trayFile = TrayFile(
//                    id: UUID(),
//                    fileName: uniqueFileName,
//                    fileExtension: (uniqueFileName as NSString).pathExtension,
//                    thumbnailData: thumbnailData // 🎯 썸네일 데이터 설정!
//                )
//                
//                DispatchQueue.main.async {
//                    self?.files.append(trayFile)
//                    print("파일 + 썸네일 추가 완료: \(uniqueFileName)")
//                }
//            }
//            
//            return copiedURL
//            
//        } catch {
//            print("\(error.localizedDescription)")
//            return nil
//        }
//    }
//    
//    
//    // fileName에 "photo.png"형태로 이렇게 들어옴 그래서 여기서 확장자랑 파일이름을 분리해서 파일이름이 중복된 경우 (1)증가해서 저장
//    func modifyDuplicatefileName(fileName: String) -> String {
//        
//        let nsString = fileName as NSString // 문자열로 변환 그래야 deletingPathExtension사용가능
//        let nameOnly = nsString.deletingPathExtension
//        let fileExtension = nsString.pathExtension
//        
//        let originalPath = trayStorage.appendingPathComponent(fileName)
//        if !FileManager.default.fileExists(atPath: originalPath.path) {
//            return fileName  // 중복 없으면 원본 그대로
//        }
//        
//        var count = 1
//        var newFileName = ""
//        
//        while true {
//            if fileExtension.isEmpty {                      //확장자가 없는 경우 ex) README파일 등등
//                newFileName = "\(nameOnly)(\(count))"
//            } else {                                        //확장자가 있는 경우
//                newFileName = "\(nameOnly)(\(count)).\(fileExtension)"
//            }
//            
//            //만약에 중복된 파일에 네버링을 추가해서 복사했는데 또 같은 파일이 들어오는 경우
//            let newpath = trayStorage.appending(component: newFileName)
//            if !FileManager.default.fileExists(atPath: newpath.path) {
//                break
//            }
//            count += 1
//        }
//        return newFileName
//    }
//    
//    //저장된 파일을 삭제하는 함수(TrayFile배열이랑 TrayStorage에서도 삭제 하게끔)
//    func deleteFile(fileName: String) {
//        
//        let filePath = trayStorage.appendingPathComponent(fileName)
//        if !FileManager.default.fileExists(atPath: filePath.path) {
//            print("디렉토리에 저장되어있지않음")
//        } else {
//            
//            do {
//                //TraySotrage에서 삭제
//                try FileManager.default.removeItem(at: filePath)
//                print("디렉토리에 \(fileName)이 삭제 되었습니다.")
//                
//                //TrayFile배열도 삭제  [Point 매인스레드로 변경해서 삭제]
//                DispatchQueue.main.async {
//                    if let index = self.files.firstIndex(where: { $0.fileName == fileName }) {
//                        self.files.remove(at: index)
//                        print("배열에서 제거 완료: \(fileName)")
//                    }
//                }


// DynamicNotch에 TrayView에 저장소 구현
// 파일 등 드래그시 복사해서 저장
import SwiftUI
import Foundation
import AppKit
import UniformTypeIdentifiers

class TrayManager: ObservableObject {
    
    static let shared = TrayManager()
    
    @Published var files: [TrayFile] = []
    
    //    private let weStorageURL: URL
    let trayStorage: URL
    
    private init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //        self.weStorageURL = directory.appendingPathComponent("Dynamic-Notch")
        
        //별도의 저장소 생성
        self.trayStorage = directory.appendingPathComponent("TrayStorage")
        
        createDirectory()
        
        cleanDirectory()
    }
    
    func createDirectory() {
        do {
            try FileManager.default.createDirectory(at: trayStorage, withIntermediateDirectories: true)
            print("경로는 : \(trayStorage.path)")
            
            //NSWorkspace.shared.open(trayStorage)
        } catch {
            print("경로생성 실패")
        }
    }
    
    //앱 실행하면 TraySotrage를 다 비우는 함수
    func cleanDirectory() {
        
        //먼저 디렉토리 여부 확인
        if FileManager.default.fileExists(atPath: trayStorage.path) {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: trayStorage, includingPropertiesForKeys: nil)
                for item in contents {
                    try FileManager.default.removeItem(at: item)
                }
                print("TrayStorage 정리 완료")
            } catch {
                print("TrayStorage 정리 실패: \(error)")
            }
            
            // 3. files 배열도 비우기
            files.removeAll()
            print("TrayFile배열도 정리 완료")
            
        } else {
            print("디렉토리가 생성되지 않았습니다")
            createDirectory()
        }
        
    }
    
    func addFileToTray(source: URL) -> URL? {
        let originalFileName = source.lastPathComponent
        let uniqueFileName = modifyDuplicatefileName(fileName: originalFileName)
        
        do {
            let copiedURL = trayStorage.appendingPathComponent(uniqueFileName)
            try FileManager.default.copyItem(at: source, to: copiedURL)
            print("\(uniqueFileName)가 trayStorage에 복사됨")
            
            // 썸네일 생성 호출 추가 (macOS 15 Beta 호환)
            generateThumbnail(for: copiedURL) { [weak self] thumbnailData in
                let trayFile = TrayFile(
                    id: UUID(),
                    fileName: uniqueFileName,
                    fileExtension: (uniqueFileName as NSString).pathExtension,
                    thumbnailData: thumbnailData // 🎯 썸네일 데이터 설정!
                )
                
                DispatchQueue.main.async {
                    self?.files.append(trayFile)
                    print("파일 + 썸네일 추가 완료: \(uniqueFileName)")
                }
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
                DispatchQueue.main.async {
                    if let index = self.files.firstIndex(where: { $0.fileName == fileName }) {
                        self.files.remove(at: index)
                        print("배열에서 제거 완료: \(fileName)")
                    }
                }
                
            } catch {
                print("파일삭제 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // macOS 15 Beta 호환 썸네일 생성 함수
    func generateThumbnail(for fileURL: URL, completion: @escaping (Data?) -> Void) {
        // QuickLook API가 베타에서 문제가 있을 수 있으므로 NSWorkspace를 사용한 대안
        DispatchQueue.global(qos: .userInitiated).async {
            let thumbnailData = self.createThumbnailUsingNSWorkspace(for: fileURL)
            DispatchQueue.main.async {
                completion(thumbnailData)
            }
        }
    }
    
    // NSWorkspace를 사용한 안전한 썸네일 생성
    private func createThumbnailUsingNSWorkspace(for fileURL: URL) -> Data? {
        let targetSize = CGSize(width: 100, height: 100)
        
        // 1. 파일 아이콘 얻기
        let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
        
        // 2. 이미지 크기 조정
        let resizedIcon = NSImage(size: targetSize)
        resizedIcon.lockFocus()
        icon.draw(in: NSRect(origin: .zero, size: targetSize))
        resizedIcon.unlockFocus()
        
        // 3. NSImage를 Data로 변환
        guard let cgImage = resizedIcon.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .png, properties: [:])
    }
    
    // QuickLook을 사용한 고급 썸네일 생성 (macOS 15에서 작동할 경우)
    @available(macOS 10.15, *)
    private func generateAdvancedThumbnail(for fileURL: URL, completion: @escaping (Data?) -> Void) {
        // QuickLookThumbnailing이 가능한 경우에만 사용
        guard Bundle(identifier: "com.apple.QuickLookThumbnailing") != nil else {
            // QuickLook이 없으면 기본 방법 사용
            completion(createThumbnailUsingNSWorkspace(for: fileURL))
            return
        }
        
        // 동적으로 QuickLook 클래스 로드 시도
        if #available(macOS 10.15, *) {
            // 런타임에 클래스 존재 여부 확인
            if let qlGeneratorClass = NSClassFromString("QLThumbnailGenerator") {
                // QuickLook 사용 가능
                useQuickLookThumbnailing(for: fileURL, completion: completion)
            } else {
                // QuickLook 사용 불가, 대안 사용
                completion(createThumbnailUsingNSWorkspace(for: fileURL))
            }
        } else {
            completion(createThumbnailUsingNSWorkspace(for: fileURL))
        }
    }
    
    // QuickLook API 사용 (조건부)
    @available(macOS 10.15, *)
    private func useQuickLookThumbnailing(for fileURL: URL, completion: @escaping (Data?) -> Void) {
        // 이 함수는 QuickLook이 정상 작동할 때만 호출됨
        // 실제 구현은 import가 성공할 때만 활성화
        completion(createThumbnailUsingNSWorkspace(for: fileURL))
    }
    
    func openAirDrop(with fileURLs: [URL]) {
        guard let sharingService = NSSharingService(named: .sendViaAirDrop) else {
            print("AirDrop을 사용할 수 없습니다")
            return
        }
        
        guard sharingService.canPerform(withItems: fileURLs) else {
            print("선택한 파일들은 AirDrop으로 공유할 수 없습니다")
            return
        }
        
        sharingService.perform(withItems: fileURLs)
    }
}

// TrayFile은 별도 파일에 정의되어 있음
