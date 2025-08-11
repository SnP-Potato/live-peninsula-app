
//  NotchType.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.


import Foundation
import Defaults

//notch 기본형태 정의
public enum NotchStyle {
    //m자 노치모양 , i자 노치모양
    case notch //iNotch 보류
}

//노치안에 표시될 주요 화면 종류
public enum NotchMainFeaturesView {
    case studio
    case tray
    //case setting
    
    
    //25/06/24 update 각 주요 화면에 아이콘, 타이틀 추가함
    var title: String {
        switch self {  //switch self 추가안할 시 에러 --분류 에러
        case .studio: return "Studio"
        case .tray: return "Tray"
        }
    }
    
    var icon: String {
        switch self {
        case .studio: return "widget.small"
        case .tray: return "tray.fill"
        }
    }
}

//노치의 상태
public enum NotchStatus {
    case off
    case on
}

enum MusicSliderColor: String, Defaults.Serializable {
    case basic = "white"
    case albumColor = "match albumColor"
}

enum notchHeightSize: String, Defaults.Serializable {
    case menubar = "menubar Height" //구형 맥북 사용자는 노치 높이를 메뉴바 높이와 동일하게
    case realNotch = "realNotch Height"
    case custom = "Custom Notch Height"
}


