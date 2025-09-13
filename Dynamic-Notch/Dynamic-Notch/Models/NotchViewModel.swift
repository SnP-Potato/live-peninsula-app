//
//  NotchViewModel.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//sms


import Combine
import SwiftUI
import Foundation

//class NotchViewModel: NSObject, ObservableObject {
//    // 노치 상태 (열림/닫힘)
//    @Published private(set) var notchState: NotchStatus = .off
//    
//    // 노치 크기
//    @Published var notchSize: CGSize = offNotchSize()
//    @Published var closedNotchSize: CGSize = offNotchSize()
//    
//    
//    @Published var isScreenLocked: Bool = false
//    
//    weak var window: NSWindow?
//    
//    // 노치 열기
//    func open() {
//        withAnimation(.spring(response: 0.4)) {
//            self.notchSize = CGSize(width: onNotchSize.width, height: onNotchSize.height)
//            self.notchState = .on
//            
//            window?.hasShadow = true
//        }
//    }
//    
//    // 노치 닫기
//    func close() {
//        withAnimation(.spring(response: 0.4)) {
//            self.notchSize = offNotchSize()
//            closedNotchSize = notchSize
//            self.notchState = .off
//            
//            window?.hasShadow = false
//        }
//    }
//}

class NotchViewModel: NSObject, ObservableObject {
    // 노치 상태 (열림/닫힘)
    @Published private(set) var notchState: NotchStatus = .off
    
    // 노치 크기
    @Published var notchSize: CGSize = offNotchSize()
    @Published var closedNotchSize: CGSize = offNotchSize()
    
    @Published var isScreenLocked: Bool = false
    
    // ✅ AirDrop 상태 관리 추가
    @Published var dropEvent: Bool = false
    @Published var anyDropZoneTargeting: Bool = false
    @Published var isAirDropInProgress: Bool = false
    @Published var lastDropResult: AirDropResult = .none
    
    weak var window: NSWindow?
    
    // ✅ AirDrop 결과 열거형
    enum AirDropResult {
        case none
        case success
        case cancelled
        case failed
    }
    
    // 노치 열기
    func open() {
        withAnimation(.spring(response: 0.4)) {
            self.notchSize = CGSize(width: onNotchSize.width, height: onNotchSize.height)
            self.notchState = .on
            
            window?.hasShadow = true
        }
    }
    
    // ✅ 개선된 노치 닫기 - AirDrop 상태 고려
    func close() {
        // AirDrop이 진행 중이면 닫지 않음
        guard !isAirDropInProgress else {
            print("🚫 AirDrop 진행 중 - 노치 유지")
            return
        }
        
        withAnimation(.spring(response: 0.4)) {
            self.notchSize = offNotchSize()
            closedNotchSize = notchSize
            self.notchState = .off
            
            window?.hasShadow = false
        }
        
        // AirDrop 관련 상태 정리
        resetDropStates()
    }
    
    // ✅ AirDrop 상태 초기화
    private func resetDropStates() {
        dropEvent = false
        anyDropZoneTargeting = false
        lastDropResult = .none
    }
    
    // ✅ AirDrop 시작 알림
    func startAirDrop() {
        isAirDropInProgress = true
        dropEvent = true
        print("📤 AirDrop 시작")
    }
    
    // ✅ AirDrop 완료 알림
    func finishAirDrop(result: AirDropResult) {
        isAirDropInProgress = false
        lastDropResult = result
        
        switch result {
        case .success:
            print("✅ AirDrop 성공")
            // 성공 시 잠시 후 노치 닫기
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.close()
            }
            
        case .cancelled:
            print("❌ AirDrop 취소")
            // 취소 시 즉시 노치 닫기 (사용자가 의도적으로 취소)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.close()
            }
            
        case .failed:
            print("⚠️ AirDrop 실패")
            // 실패 시 약간의 지연 후 닫기 (에러 확인 시간 제공)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.close()
            }
            
        case .none:
            break
        }
    }
}
