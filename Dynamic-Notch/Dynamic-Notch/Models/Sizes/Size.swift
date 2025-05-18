//
//  Size.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import Foundation
import Defaults
import AppKit

//에어팟 연결할때
let connectAirpods: CGSize = .init(width: 65, height: 65)
let connectAirpodspromax: CGSize = .init(width: 85, height: 85)
let bluetoothEarphone: CGSize = .init(width: 65, height: 65)


enum MusicImageSize {
    static let cornerRadius: (on: CGFloat, off: CGFloat) = (on: 18.0, off: 3.0)
    static let size = (on: CGSize(width: 85, height: 85), off: CGSize(width: 25, height: 25))
}

//노치가 활성화될떄 사이즈 초기화
let onNotchSize: CGSize = .init(width: 540, height: 200)

//노치가 비활성화일 때 사이즈
func offNotchSize(screenName: String? = nil) -> CGSize {
    var width: CGFloat = 185
    var height: CGFloat = Defaults[.notchHeight] //32
    
    var targetScreen = NSScreen.main
    
    if let customScreen = screenName {
        targetScreen = NSScreen.screens.first(where: { $0.localizedName == customScreen})
    }
    
    if let screenName = targetScreen {
        
        //너비 구하는 것
        if let leftPadding: CGFloat = screenName.auxiliaryTopLeftArea?.width, let rightPadding: CGFloat = screenName.auxiliaryTopRightArea?.width {
            width = screenName.frame.width - leftPadding - rightPadding + 25
        }
        
        //높이 구하는 것
        //노치가 있는 경우
        if screenName.safeAreaInsets.top > 0 {
            height = Defaults[.notchHeight]
            
            if Defaults[.heightMode] == .realNotch {
                height = screenName.safeAreaInsets.top
            } else if Defaults[.heightMode] == .menubar{
                height = screenName.frame.maxY - screenName.visibleFrame.maxY
            }
        }else { //없는 경우
            height = Defaults[.nonNotchHeight]
            
            if Defaults[.nonNotchHeightMode] == .menubar {
                height = screenName.frame.maxY - screenName.visibleFrame.maxY
            }
        }
    }
    
    //nil이면 기본 너비 높이 반환
    return .init(width: width, height: height)
}

//노치 활성화&비활성화 상태일 때 모서리 초기화
let cornerRadiusSet: (on: CGFloat, off: CGFloat) = (on: 24, off: 10)
