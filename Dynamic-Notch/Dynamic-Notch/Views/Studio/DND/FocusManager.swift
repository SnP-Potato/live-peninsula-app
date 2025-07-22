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
            focusModedeactivate()
        } else {
            focusModeactivation()
        }
    }
    
    
    func focusModeactivation() {
        executeShortcut()
        isFocused = true
        print("집중모드 비활성화")
    }
    
    
    func focusModedeactivate() {
        executeShortcut()
        isFocused = false
        print("집중모드 활성화")
    }
    
    func executeShortcut() {
        let shortcutName = "Toggle DND"
        
        if let encodeName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: "shortcuts://run-shortcut?name=\(encodeName)") {
                NSWorkspace.shared.open(url)
                print("Toggle DND 실행함")
            }
        }
        
    }
}
