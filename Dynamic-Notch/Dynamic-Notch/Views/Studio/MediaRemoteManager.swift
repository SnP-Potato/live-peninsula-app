//
//  MusicRemoteManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 6/23/25.
//

import Foundation

class MediaRemoteManager: ObservableObject {
    private let mediaRemoteBundle: CFBundle
    private let getPlayingInfo: @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private let sendCommand: @convention(c) (Int, AnyObject?) -> Void
    private let getPlayingState: @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
    private let setElapsedTime: @convention(c) (Double) -> Void
    private let registerNotifications: @convention(c) (DispatchQueue) -> Void
    
    @Published var songTitle = ""
    @Published var artistName = ""
    @Published var albumArt: Data?
    @Published var isPlaying = false
    @Published var duration: Double = 0
    @Published var elapsedTime: Double = 0
    
    init?() {
        guard let bundle = CFBundleCreate(
            kCFAllocatorDefault,
            NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")
        ) else { return nil }
        
        // 함수 포인터들 가져오기
        guard let getInfoPtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString),
              let sendCmdPtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString),
              let getStatePtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString),
              let setTimePtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSetElapsedTime" as CFString),
              let registerPtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString)
        else { return nil }
        
        self.mediaRemoteBundle = bundle
        self.getPlayingInfo = unsafeBitCast(getInfoPtr, to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)
        self.sendCommand = unsafeBitCast(sendCmdPtr, to: (@convention(c) (Int, AnyObject?) -> Void).self)
        self.getPlayingState = unsafeBitCast(getStatePtr, to: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void).self)
        self.setElapsedTime = unsafeBitCast(setTimePtr, to: (@convention(c) (Double) -> Void).self)
        self.registerNotifications = unsafeBitCast(registerPtr, to: (@convention(c) (DispatchQueue) -> Void).self)
        
        setupNotifications()
        updateNowPlaying()
    }
}


extension MediaRemoteManager {
    func updateNowPlaying() {
        getPlayingInfo(DispatchQueue.main) { [weak self] info in
            self?.songTitle = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? ""
            self?.artistName = info["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
            self?.albumArt = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data
            self?.duration = info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double ?? 0
            self?.elapsedTime = info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double ?? 0
        }
        
        getPlayingState(DispatchQueue.main) { [weak self] playing in
            self?.isPlaying = playing
        }
    }
    
    private func setupNotifications() {
        registerNotifications(DispatchQueue.main)
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateNowPlaying()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateNowPlaying()
        }
    }
}


extension MediaRemoteManager {
    func playPause() {
        sendCommand(isPlaying ? 2 : 0, nil) // 2: pause, 0: play
    }
    
    func nextTrack() {
        sendCommand(4, nil)
    }
    
    func previousTrack() {
        sendCommand(5, nil)
    }
    
    func seek(to time: Double) {
        setElapsedTime(time)
    }
}
