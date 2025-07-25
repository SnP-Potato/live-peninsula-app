//
//  FocusManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/22/25.
//

import Foundation
import SwiftUI


class FocusManager: ObservableObject {
    
    static let shared = FocusManager()
    
    @Published var isFocused: Bool = false {
        didSet {
            UserDefaults.standard.set(isFocused, forKey: "isFocused")
            print("집중모드 상태 저장 완료")
        }
    }
    
    private init() {
        self.isFocused = UserDefaults.standard.bool(forKey: "isFocused")
    }
    
    func toggleFocusMode() {
        if isFocused {
            focusModeDeactivate()
        } else {
            focusModeActivation()
        }
    }
    
    
    func focusModeActivation() {
        executeShortcut()
        isFocused = true
        print("집중모드 활성화")
    }
    
    
    func focusModeDeactivate() {
        executeShortcut()
        isFocused = false
        print("집중모드 비활성화")
    }
    
    func executeShortcut() {
        let shortcutName = "Focus"
        
        if let encodeName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: "shortcuts://run-shortcut?name=\(encodeName)") {
                NSWorkspace.shared.open(url)
                print("Focus 단축어 실행함")
            }
        }
        
    }
}
