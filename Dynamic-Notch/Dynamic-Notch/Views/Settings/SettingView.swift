//
//  SettingView.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/25/25.
//

import SwiftUI
import Sparkle
import ServiceManagement

struct SettingsView: View {
    let updaterController: SPUStandardUpdaterController
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // 헤더
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            // Interface 섹션
            GroupBox("Interface") {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle("Show menu bar icon", isOn: $showMenuBarIcon)
                        .onChange(of: showMenuBarIcon) { _, newValue in
                            print("메뉴바 아이콘 설정: \(newValue)")
                            
                            if !newValue {
                                // 메뉴바 아이콘을 숨길 때 경고
                                showMenuBarWarning()
                            }
                        }
                    
                    Text("Show or hide the Dynamic Notch icon in the menu bar. Note: If you hide the icon, you can still access settings by reopening the app.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
            
            Spacer()
            
            // 하단 버튼들
            HStack {
                Button("GitHub") {
                    if let url = URL(string: "https://github.com/example/Dynamic-Notch") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Quit App") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
//                .controlProminence(.increased)
            }
        }
        .padding(30)
        .frame(minWidth: 400, minHeight: 300)
    }
    
    private func showMenuBarWarning() {
        let alert = NSAlert()
        alert.messageText = "Hide Menu Bar Icon"
        alert.informativeText = "If you hide the menu bar icon, you can still access settings by reopening the Dynamic Notch app from Applications folder or Spotlight."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Settings Window Controller

class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()
    
    private var updaterController: SPUStandardUpdaterController?
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.center()
        window.title = "Dynamic Notch Settings"
        window.isRestorable = false
        window.identifier = NSUserInterfaceItemIdentifier("SettingsWindow")
        window.isReleasedWhenClosed = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpdaterController(_ updaterController: SPUStandardUpdaterController) {
        self.updaterController = updaterController
        setupContentView()
    }
    
    private func setupContentView() {
        guard let updaterController = updaterController else { return }
        
        window?.contentView = NSHostingView(
            rootView: SettingsView(updaterController: updaterController)
        )
    }
    
    func showWindow() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
    }
}
#Preview {
}
