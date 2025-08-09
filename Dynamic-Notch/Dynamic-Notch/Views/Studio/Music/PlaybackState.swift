//
//  PlaybackState.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/5/25.
//

import Foundation

import Foundation

struct PlaybackState {
    let bundleIdentifier: String
    var isPlaying: Bool = false
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var currentTime: Double = 0
    var duration: Double = 0
    var playbackRate: Double = 1.0
    var isShuffled: Bool = false
    var repeatMode: RepeatMode = .off
    var lastUpdated: Date = Date()
    var artwork: Data? = nil
    
    init(bundleIdentifier: String, isPlaying: Bool = false) {
        self.bundleIdentifier = bundleIdentifier
        self.isPlaying = isPlaying
    }
}

enum RepeatMode: Int, CaseIterable {
    case off = 0      // kMRRepeatModeOff
    case one = 1      // kMRRepeatModeOne
    case all = 2      // kMRRepeatModeAll
    
    var displayName: String {
        switch self {
        case .off:
            return "Off"
        case .one:
            return "Repeat One"
        case .all:
            return "Repeat All"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .off:
            return "repeat"
        case .one:
            return "repeat.1"
        case .all:
            return "repeat"
        }
    }
    
    var isActive: Bool {
        return self != .off
    }
}
