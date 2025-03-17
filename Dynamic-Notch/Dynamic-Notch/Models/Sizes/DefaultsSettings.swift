//
//  DefaultsSettings.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import SwiftUI
import Defaults

//비주얼라이저 구조체
struct visualizer: Codable, Hashable, Equatable, Defaults.Serializable {
    let uuid: UUID
    var style: String
    var speed: CGFloat = 1.0
    var url: URL
}

//갤린더 구조체
enum calendarSelect: Codable, Defaults.Serializable {
    case defaultCalendar
    case selected(Set<String>)
}

enum HideNotchOption: String, Defaults.Serializable {
    case always
    case nowPlayingOnly
    case never
}


extension Defaults.Keys {
    
    static let showOnAllDisplay = Key<Bool>("showOnAllDisplay", default: true)
    
    static let openNotchDuration = Key<TimeInterval>("openNotchDuration", default: 0.0)
    static let haptics = Key<Bool>("enableHaptics", default: true)
    static let autoOpenWithMouse = Key<Bool>("autoOpenWithMouse", default: true)
    
    static let heightMode = Key<notchHeightSize>("heightMode", default: notchHeightSize.realNotch)
    static let nonNotchHeightMode = Key<notchHeightSize>("nonNotchHeightMode",default: notchHeightSize.realNotch)
    static let notchHeight = Key<CGFloat>("notchHeight", default: 32)
    static let nonNotchHeight = Key<CGFloat>("nonNotchHeight", default: 32)
    
    //노치에 기능들 구현
    static let showSettingIcon = Key<Bool>("showSettingicon", default: true)
    static let albumColorEffect = Key<Bool>("AlbumColorEffect", default: true)
    static let accentColor = Key<Color>("accentColor", default: .blue)
    static let showShadow = Key<Bool>("showShadow", default: true)
    static let customCorner = Key<Bool>("CustomCornerRadius", default: true)
    static let showCalendar = Key<Bool>("showCalendar", default: true)
    
    static let playColor = Key<MusicSliderColor>("defaultPlayColor", default: MusicSliderColor.basic)
    static let customPlayColor = Key<Bool>("CustomPlayColor", default: true)
    static let showVisualizer = Key<Bool>("showVisualizer", default: true)
    
    static let colorSpectrogram = Key<Bool>("colorSpectrogram",default: true)
    
    //전체화면 감지
    static let mediaFullscreenCase = Key<Bool>("mediaFullscreenCase", default: true)
    static let tray = Key<Bool>("tray", default: true)
    static let calendar = Key<Bool>("calendar", default: true)
    static let alwaysHideInFullscreen = Key<Bool>("alwaysHideInFullscreen", default: false)
    static let hideNotchOption = Key<HideNotchOption>("hideNotchOption", default: .nowPlayingOnly)
}

