//
//  Dynamic_NotchApp.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import SwiftUI
import Defaults

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
    var windows: [NSScreen: NSWindow] = [:] // 모든 화면을 위한 창 저장
    var viewModels: [NSScreen: NotchViewModel] = [:] // 화면별 뷰모델
    var window: NSWindow! // 기존 창 (메인 화면용)
    let vm: NotchViewModel = .init()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 화면 변경 감지 설정
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenConfigurationDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        
        // 노치 창 생성 (기존 방식)
        if !Defaults[.showOnAllDisplay] {
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
        } else {
            // 모든 화면에 노치 창 생성
            adjustWindowPosition()
        }
    }
    
    @objc func screenConfigurationDidChange() {
        adjustWindowPosition()
    }
    
    @objc func adjustWindowPosition() {
        if Defaults[.showOnAllDisplay] {
            // 모든 화면에 노치 표시
            
            /// MASK
            /// 기존에는 맥북 화면만 노치를 표시했으나 외부 모니터와 연결했을때도 notch표시하도록 수정함
        
            for screen in NSScreen.screens {
                if windows[screen] == nil {
                    // 새 화면용 뷰모델과 창 생성
                    let viewModel = NotchViewModel()
                    let window = NotchAreaWindow(
                        contentRect: NSRect(x: 0, y: 0, width: onNotchSize.width, height: onNotchSize.height),
                        styleMask: [.borderless, .nonactivatingPanel, .utilityWindow, .hudWindow],
                        backing: .buffered,
                        defer: false
                    )
                    
                    window.contentView = NSHostingView(
                        rootView: ContentView()
                            .environmentObject(viewModel)
                    )
                    
                    windows[screen] = window
                    viewModels[screen] = viewModel
                    window.orderFrontRegardless()
                }
                
                // 각 창의 위치 조정
                if let window = windows[screen] {
                    window.setFrameOrigin(
                        NSPoint(
                            x: screen.frame.origin.x + (screen.frame.width / 2) - window.frame.width / 2,
                            y: screen.frame.origin.y + screen.frame.height - window.frame.height
                        )
                    )
                }
            }
        } else {
            // 메인 화면에만 노치 표시 [기존크드]
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
}
