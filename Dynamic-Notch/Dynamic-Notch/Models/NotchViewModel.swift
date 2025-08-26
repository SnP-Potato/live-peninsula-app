//
//  NotchViewModel.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//sms


import Combine
import SwiftUI
import Foundation

class NotchViewModel: NSObject, ObservableObject {
    // 노치 상태 (열림/닫힘)
    @Published private(set) var notchState: NotchStatus = .off
    
    // 노치 크기
    @Published var notchSize: CGSize = offNotchSize()
    @Published var closedNotchSize: CGSize = offNotchSize()
    
    
    @Published var isScreenLocked: Bool = false
    
    weak var window: NSWindow?
    
    // 노치 열기
    func open() {
        withAnimation(.spring(response: 0.4)) {
            self.notchSize = CGSize(width: onNotchSize.width, height: onNotchSize.height)
            self.notchState = .on
            
            window?.hasShadow = true
        }
    }
    
    // 노치 닫기
    func close() {
        withAnimation(.spring(response: 0.4)) {
            self.notchSize = offNotchSize()
            closedNotchSize = notchSize
            self.notchState = .off
            
            window?.hasShadow = false
        }
    }
}
