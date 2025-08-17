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
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

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

    let calenarManager = CalendarManager.shared
    let musicManager = MusicManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        NSApp.setActivationPolicy(.regular)
        //  디버깅: 연결된 모든 모니터 정보 출력
        printAllScreensInfo()


        //trayStorage 폴더 생성 확인
        _ = TrayManager.shared

        _ = CalendarManager.shared


        Task {
            await CalendarManager.shared.requestCalendarAccess()
        }

        // 화면 변경 감지 설정
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenConfigurationDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        // 노치 창 생성 (기존 방식)
        if !Defaults[.showOnAllDisplay] { //false일 때
            window = NotchAreaWindow(
                //x,y가 0으로 설정 임시 위치 실제 의치 계산은 setFramOrigin에서!
                contentRect: NSRect(x: 0, y: 0, width: onNotchSize.width, height: onNotchSize.height),
                styleMask: [.borderless, .nonactivatingPanel, .utilityWindow, .hudWindow],
                backing: .buffered,
                defer: false
            )

            // ContentView 설정
            window.contentView = NSHostingView(rootView:
                ContentView()
                    .environmentObject(vm)
                    .environmentObject(calenarManager)
                    .environmentObject(musicManager)

            )

            // 창 위치 조정 및 표시
            adjustWindowPosition()
            window.orderFrontRegardless()
        } else {
            // 모든 화면에 노치 창 생성
            adjustWindowPosition()
        }
    }

    //notification이 Objective-C 기반이라 필요
    @objc func screenConfigurationDidChange() {
        print("\n🔄 화면 구성이 변경되었습니다!")
        printAllScreensInfo()
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
                            .environmentObject(calenarManager)
                            .environmentObject(musicManager)

                    )

                    windows[screen] = window
                    viewModels[screen] = viewModel
                    window.hasShadow = false
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
                window.hasShadow = false
                window.setFrameOrigin(
                    NSPoint(
                        x: screenFrame.frame.width / 2 - window.frame.width / 2,
                        y: screenFrame.frame.height - window.frame.height
                    )
                )
            }
        }
    }

    // 디버깅용 함수 추가
    func printAllScreensInfo() {
        print("\n🖥️ === 연결된 모니터 정보 ===")
        print("총 모니터 개수: \(NSScreen.screens.count)")

        for (index, screen) in NSScreen.screens.enumerated() {
            print("\n📺 모니터 \(index + 1):")
            print("  이름: \(screen.localizedName)")
            print("  해상도: \(Int(screen.frame.width)) x \(Int(screen.frame.height))")
            print("  위치: (\(Int(screen.frame.origin.x)), \(Int(screen.frame.origin.y)))")
            print("  배율: \(screen.backingScaleFactor)x")

            // 노치 여부 확인
            if screen.safeAreaInsets.top > 0 {
                print("  노치: 있음 (\(screen.safeAreaInsets.top)pt)")
            } else {
                print("  노치: 없음")
            }

            // 메인 화면 여부
            if screen == NSScreen.main {
                print("  타입: 🌟 메인 화면")
            } else {
                print("  타입: 외부 모니터")
            }
        }
        print("================================\n")
    }
}

