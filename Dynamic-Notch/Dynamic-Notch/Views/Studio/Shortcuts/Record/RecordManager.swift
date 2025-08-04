//
//  RecordManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/28/25.
//

import Foundation
import AppKit

class RecordManager: ObservableObject {
    static let shared = RecordManager()
    
    @Published var isRecord: Bool = false {
        didSet {
            UserDefaults.standard.set(isRecord, forKey: "isRecord")
            print("녹음모드 상태 저장 완료")
        }
    }
    
    private init() {
        self.isRecord = UserDefaults.standard.bool(forKey: "isRecord")
    }
    
    func toggleRecordMode() {
        if isRecord {
            recordModeDeactivate()
        } else {
            recordModeActivation()
        }
    }
    
    
    func recordModeActivation() {
        executeShortcut()
        isRecord = true
        print("녹음모드 활성화")
    }
    
    
    func recordModeDeactivate() {
        executeShortcut()
        isRecord = false
        print("녹음모드 비활성화")
    }
    
    func executeShortcut() {
        let shortcutName = "Record"
        
        if let encodeName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: "shortcuts://run-shortcut?name=\(encodeName)") {
                NSWorkspace.shared.open(url)
                print("Record 단축어 실행함")
            }
        }
        
    }
}
