//
//  AnimationManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 4/3/25.
//

import SwiftUI

class AnimationManager {
    private var currentStyle: NotchStyle = .notch
    
    init(style: NotchStyle = .notch) {
        self.currentStyle = style
    }
    
    // 스타일 설정 함수
    func setStyle(_ style: NotchStyle) {
        self.currentStyle = style
    }
    
    // 적절한 애니메이션 반환
    var currentAnimation: Animation {
        // OS 버전 확인
        let isNewMacOS = ProcessInfo().isOperatingSystemAtLeast(
            OperatingSystemVersion(majorVersion: 14, minorVersion: 0, patchVersion: 0)
        )
        
        // OS 버전에 따라 다른 애니메이션 반환
        if isNewMacOS {
            return Animation.spring(duration: 0.4, bounce: 0.3)
        } else {
            return Animation.spring(response: 0.4, dampingFraction: 0.7)
        }
    }
    
    // 노치 열기 애니메이션
    var openAnimation: Animation {
        let isNewMacOS = ProcessInfo().isOperatingSystemAtLeast(
            OperatingSystemVersion(majorVersion: 14, minorVersion: 0, patchVersion: 0)
        )
        
        if isNewMacOS {
            return Animation.spring(duration: 0.5, bounce: 0.4)
        } else {
            return Animation.spring(response: 0.5, dampingFraction: 0.6)
        }
    }
    
    // 노치 닫기 애니메이션
    var closeAnimation: Animation {
        return Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
}
