//
//  BrightnessKeyObserver.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/27/25.
//

//
//  BrightnessKeyMonitor.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/26/25.
//

import Cocoa

class BrightnessKeyMonitor {
    static let shared = BrightnessKeyMonitor()
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    
    private init() {}
    
    func startMonitoring() {
        // 글로벌 키 이벤트 모니터 (다른 앱이 활성화되어 있을 때)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        // 로컬 키 이벤트 모니터 (내 앱이 활성화되어 있을 때)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
        
        print("밝기 키 모니터링 시작")
    }
    
    func stopMonitoring() {
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
        
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
        
        print("밝기 키 모니터링 중지")
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        // F1, F2 키 (밝기 조절)를 감지
        // F1 = 122 (밝기 다운), F2 = 120 (밝기 업)
        switch event.keyCode {
        case 122, 120: // F1, F2
            print("밝기 키 감지: keyCode \(event.keyCode)")
            
            NotificationCenter.default.post(
                name: NSNotification.Name("BrightnessKeyPressed"),
                object: nil,
                userInfo: ["keyCode": event.keyCode]
            )
            
        default:
            break
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
