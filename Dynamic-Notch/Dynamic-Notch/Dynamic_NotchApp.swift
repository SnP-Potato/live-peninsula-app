//
//  Dynamic_NotchApp.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import SwiftUI

@main
struct Dynamic_NotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let vm: NotchViewModel = .init()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 화면 변경 감지 설정
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenConfigurationDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        
        // 노치 창 생성
        window = NotchAreaWindow(
            contentRect: NSRect(x: 0, y: 0, width: onNotchSize.width, height: onNotchSize.height),
            styleMask: [.borderless, .nonactivatingPanel, .utilityWindow, .hudWindow],
            backing: .buffered,
            defer: false
        )
        
        // ContentView 설정
        window.contentView = NSHostingView(rootView:
            ContentView()
                .environmentObject(vm)
        )
        
        // 창 위치 조정 및 표시
        adjustWindowPosition()
        window.orderFrontRegardless()
    }
    
    @objc func screenConfigurationDidChange() {
        adjustWindowPosition()
    }
    
    @objc func adjustWindowPosition() {
        // 화면 중앙 상단에 노치 위치시키기
        if let screenFrame = NSScreen.main {
            window.setFrameOrigin(
                NSPoint(
                    x: screenFrame.frame.width / 2 - window.frame.width / 2,
                    y: screenFrame.frame.height - window.frame.height
                )
            )
        }
    }
}
