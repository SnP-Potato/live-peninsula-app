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
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            // 사이드바
            List {
                NavigationLink(destination: GeneralSettingsView()) {
                    Label("General", systemImage: "gearshape")
                }
                
                NavigationLink(destination: AboutView(updaterController: updaterController)) {
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
            .frame(minWidth: 200)
            
            // 기본 선택된 뷰
            GeneralSettingsView()
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("launchAtStartup") private var launchAtStartup: Bool = false
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon: Bool = true
    
    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at startup", isOn: $launchAtStartup)
                    .onChange(of: launchAtStartup) { _, newValue in
                        setLaunchAtStartup(enabled: newValue)
                    }
            }
            
            Section("Interface") {
                Toggle("Show menu bar icon", isOn: $showMenuBarIcon)
            }
        }
        .navigationTitle("General")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
    
    private func setLaunchAtStartup(enabled: Bool) {
        // 시스템 로그인 아이템 설정
        let identifier = Bundle.main.bundleIdentifier!
        
        if enabled {
            if SMAppService.mainApp.status == .notRegistered {
                do {
                    try SMAppService.mainApp.register()
                    print("Successfully registered launch at login")
                } catch {
                    print("Failed to register launch at login: \(error)")
                }
            }
        } else {
            do {
                try SMAppService.mainApp.unregister()
                print("Successfully unregistered launch at login")
            } catch {
                print("Failed to unregister launch at login: \(error)")
            }
        }
    }
}

struct AboutView: View {
    let updaterController: SPUStandardUpdaterController
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        
        VStack(spacing: 20) {
            // 앱 아이콘과 정보
            VStack(spacing: 12) {
                if let appIcon = NSApp.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 64, height: 64)
                }
                
                Text(Bundle.main.displayName ?? "Dynamic Notch")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Version \(Bundle.main.versionString)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // 업데이트 섹션
            VStack(spacing: 12) {
                Text("Updates")
                    .font(.headline)
                
                CheckForUpdatesView(updater: updaterController.updater)
                
                Text("Automatic updates keep your app secure and up to date.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
//            Divider()
            
//            // 링크 섹션
//            VStack(spacing: 8) {
//                Button("GitHub Repository") {
//                    if let url = URL(string: "https://github.com/yourusername/dynamic-notch") {
//                        openURL(url)
//                    }
//                }
//                .buttonStyle(.link)
//                
//                Button("Report Issue") {
//                    if let url = URL(string: "https://github.com/yourusername/dynamic-notch/issues") {
//                        openURL(url)
//                    }
//                }
//                .buttonStyle(.link)
//            }
            
            Spacer()
            
            // 앱 종료 버튼
            VStack(spacing: 12) {
                Divider()
                
                HStack {
                    Spacer()
                    
                    Button("Quit Dynamic Notch") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.bordered)
//                    .controlProminence(.increased)
                    
                    Spacer()
                }
            }
        }
        .padding(30)
        .navigationTitle("About")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func restartApp() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        
        let workspace = NSWorkspace.shared
        
        if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.createsNewApplicationInstance = true
            
            workspace.openApplication(at: appURL, configuration: configuration) { _, _ in
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

// MARK: - Extensions

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    var versionString: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Settings Window Controller

class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()
    
    private var updaterController: SPUStandardUpdaterController?
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.center()
        window.title = "Settings"
        window.titlebarAppearsTransparent = true
        window.isRestorable = false
        window.identifier = NSUserInterfaceItemIdentifier("SettingsWindow")
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
