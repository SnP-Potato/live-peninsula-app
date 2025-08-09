//
//  MusicManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/14/25.
//

/// MARK  MediaRemote에서 가져와야 할 필요한 함수들
///
// 1. 현재 재생 정보 가져오기
//   "MRMediaRemoteGetNowPlayingInfo"
//   역할: 현재 재생 중인 곡 제목, 아티스트, 앨범 아트 등 정보 가져오기

// 2. 재생 상태 확인
//   "MRMediaRemoteGetNowPlayingApplicationIsPlaying"
//   역할: 음악이 재생 중인지 정지 중인지 확인

//  3. 미디어 제어 명령
//   "MRMediaRemoteSendCommand"
//   역할: 재생/정지, 다음곡, 이전곡 등 제어 명령 보내기

//  4. 알림 등록
//   "MRMediaRemoteRegisterForNowPlayingNotifications"
//   역할: 음악 정보가 변경될 때 알림 받기


//  ##MusicManager에 필요한 기능별 함수##

//  [1]. songTitle, artistName 업데이트용
//  "MRMediaRemoteGetNowPlayingInfo" 이 함수로 곡 정보 가져오기


//  [2]. isPlaying 업데이트용
//  "MRMediaRemoteGetNowPlayingApplicationIsPlaying" 이 함수로 재생 상태 확인

//  [3]. playPause(), nextTrack(), previousTrack() 구현용
//  "MRMediaRemoteSendCommand" 이 함수로 음악 제어


// MARK: MediaRemote가 이제 사용못해서 그냥 MusicKit으로 구현 **애플뮤직만 제어 가능**

//class MusicManager: ObservableObject {
//    static let shared = MusicManager()
//    
//    // MARK: - Published Properties
////    @Published var songName: String = "Heat Waves"
////    @Published var artistName: String = "Glass Animals"
////    @Published var albumThumbnail: NSImage? = nil
////    @Published var hasPermission: Bool = true
////    @Published var currentPlaybackTime: TimeInterval = 45
////    @Published var totalDuration: TimeInterval = 180
////    @Published var playbackProgress: Double = 0.25
////    @Published var isPlaying: Bool = true
////    @Published var searchResults: [TestSong] = []
////    @Published var selectedSong: TestSong? = nil
//    
//}


//import Foundation
//import SwiftUI
//import Combine
//
//class MusicManager: ObservableObject {
//    static let shared = MusicManager()
//    
//    // MARK: - Published Properties
//    @Published var songTitle: String = ""
//    @Published var artistName: String = ""
//    @Published var albumName: String = ""
//    @Published var albumArt: NSImage = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Album Art") ?? NSImage()
//    @Published var isPlaying: Bool = false
//    @Published var currentTime: Double = 0
//    @Published var duration: Double = 0
//    @Published var bundleIdentifier: String = ""
//    @Published var lastUpdated: Date = Date()
//    
//    // MARK: - Private Properties
//    private var mediaController: SimpleMediaRemoteController?
//    private var cancellables = Set<AnyCancellable>()
//    private var updateTimer: Timer?
//    
//    private init() {
//        setupMediaRemote()
//        startPeriodicUpdates()
//    }
//    
//    private func startPeriodicUpdates() {
//        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
//            self?.mediaController?.updateNowPlayingInfo()
//            self?.mediaController?.updatePlayingState()
//        }
//    }
//    
//    deinit {
//        updateTimer?.invalidate()
//        cancellables.forEach { $0.cancel() }
//    }
//    
//    private func setupMediaRemote() {
//        guard let controller = SimpleMediaRemoteController() else {
//            print(" MediaRemote를 초기화할 수 없습니다")
//            return
//        }
//        
//        self.mediaController = controller
//        
//        // 상태 관찰 설정
//        controller.$songTitle
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] title in
//                self?.songTitle = title
//                if !title.isEmpty {
//                    self?.lastUpdated = Date()
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$artistName
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] artist in
//                self?.artistName = artist
//                if !artist.isEmpty {
//                    self?.lastUpdated = Date()
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$albumName
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.albumName, on: self)
//            .store(in: &cancellables)
//            
//        controller.$isPlaying
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isPlaying in
//                self?.isPlaying = isPlaying
//                self?.lastUpdated = Date()
//            }
//            .store(in: &cancellables)
//            
//        controller.$currentTime
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] currentTime in
//                self?.currentTime = currentTime
//                self?.lastUpdated = Date()
//            }
//            .store(in: &cancellables)
//            
//        controller.$duration
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.duration, on: self)
//            .store(in: &cancellables)
//            
//        controller.$bundleIdentifier
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.bundleIdentifier, on: self)
//            .store(in: &cancellables)
//            
//        // 앨범 아트 업데이트
//        controller.$albumArtwork
//            .receive(on: DispatchQueue.main)
//            .compactMap { $0 }
//            .map { NSImage(data: $0) ?? NSImage(systemSymbolName: "music.note", accessibilityDescription: "Album Art") ?? NSImage() }
//            .assign(to: \.albumArt, on: self)
//            .store(in: &cancellables)
//            
//        print(" MusicManager 초기화 성공")
//    }
//    
//    // MARK: - Public Methods
//    func play() {
//        mediaController?.play()
//        lastUpdated = Date()
//    }
//    
//    func pause() {
//        mediaController?.pause()
//        lastUpdated = Date()
//    }
//    
//    func togglePlayPause() {
//        mediaController?.togglePlayPause()
//        lastUpdated = Date()
//    }
//    
//    func nextTrack() {
//        mediaController?.nextTrack()
//        lastUpdated = Date()
//    }
//    
//    func previousTrack() {
//        mediaController?.previousTrack()
//        lastUpdated = Date()
//    }
//    
//    // MARK: - Computed Properties
//    var hasActiveMedia: Bool {
//        return !songTitle.isEmpty && !artistName.isEmpty
//    }
//    
//    var playbackProgress: Double {
//        guard duration > 0 else { return 0 }
//        return currentTime / duration
//    }
//    
//    // 현재 재생 중인 앱 이름 반환
//    var currentAppName: String {
//        switch bundleIdentifier {
//        case "com.apple.Music":
//            return "Apple Music"
//        case "com.spotify.client":
//            return "Spotify"
//        default:
//            return "Music"
//        }
//    }
//}


//
//  MusicManager.swift
//  Dynamic-Notch
//
//  Updated to use EnhancedMediaRemoteController
//

//import Foundation
//import SwiftUI
//import Combine
//
//class MusicManager: ObservableObject {
//    static let shared = MusicManager()
//    
//    // MARK: - Published Properties
//    @Published var songTitle: String = ""
//    @Published var artistName: String = ""
//    @Published var albumName: String = ""
//    @Published var albumArt: NSImage = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Album Art") ?? NSImage()
//    @Published var isPlaying: Bool = false
//    @Published var currentTime: Double = 0
//    @Published var duration: Double = 0
//    @Published var bundleIdentifier: String = ""
//    @Published var lastUpdated: Date = Date()
//    @Published var playbackRate: Double = 1.0
//    @Published var isShuffled: Bool = false
//    @Published var repeatMode: RepeatMode = .off
//    
//    // MARK: - Private Properties
//    private var mediaController: SimpleMediaRemoteController?
//    private var cancellables = Set<AnyCancellable>()
//    private var updateTimer: Timer?
//    
//    private init() {
//        setupMediaRemote()
//        startPeriodicUpdates()
//    }
//    
//    private func startPeriodicUpdates() {
//        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
//            // 재생 상태를 더 자주 확인
//            self?.mediaController?.updatePlayingState()
//            
//            // 재생 중일 때만 시간 업데이트
//            if self?.isPlaying == true {
//                self?.updateCurrentTime()
//            }
//        }
//    }
//    
//    private func updateCurrentTime() {
//        // 실시간으로 현재 시간 증가 (더 부드러운 UI를 위해)
//        if isPlaying && duration > 0 {
//            let newTime = currentTime + playbackRate
//            if newTime <= duration {
//                currentTime = newTime
//            }
//        }
//    }
//    
//    deinit {
//        updateTimer?.invalidate()
//        cancellables.forEach { $0.cancel() }
//    }
//    
//    private func setupMediaRemote() {
//        guard let controller = SimpleMediaRemoteController() else {
//            print("❌ Enhanced MediaRemote를 초기화할 수 없습니다")
//            return
//        }
//        
//        self.mediaController = controller
//        
//        // 상태 관찰 설정
//        controller.$songTitle
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] title in
//                if title != self?.songTitle {
//                    self?.songTitle = title
//                    self?.updateLastUpdated()
//                    print("🎵 곡 제목 업데이트: \(title)")
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$artistName
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] artist in
//                if artist != self?.artistName {
//                    self?.artistName = artist
//                    self?.updateLastUpdated()
//                    print("👤 아티스트 업데이트: \(artist)")
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$albumName
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] album in
//                if album != self?.albumName {
//                    self?.albumName = album
//                    self?.updateLastUpdated()
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$isPlaying
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isPlaying in
//                if isPlaying != self?.isPlaying {
//                    self?.isPlaying = isPlaying
//                    self?.updateLastUpdated()
//                    print("⏯️ 재생 상태 업데이트: \(isPlaying ? "재생" : "정지")")
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$currentTime
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] currentTime in
//                // MediaRemote에서 시간이 업데이트되면 우리 시간도 동기화
//                self?.currentTime = currentTime
//                self?.updateLastUpdated()
//            }
//            .store(in: &cancellables)
//            
//        controller.$duration
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] duration in
//                if duration != self?.duration {
//                    self?.duration = duration
//                    self?.updateLastUpdated()
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$bundleIdentifier
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] bundleId in
//                if bundleId != self?.bundleIdentifier {
//                    self?.bundleIdentifier = bundleId
//                    self?.updateLastUpdated()
//                    print("📱 앱 업데이트: \(bundleId)")
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$playbackRate
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] rate in
//                if rate != self?.playbackRate {
//                    self?.playbackRate = rate
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$isShuffled
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] shuffled in
//                if shuffled != self?.isShuffled {
//                    self?.isShuffled = shuffled
//                }
//            }
//            .store(in: &cancellables)
//            
//        controller.$repeatMode
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] mode in
//                let newRepeatMode = RepeatMode(rawValue: mode) ?? .off
//                if newRepeatMode != self?.repeatMode {
//                    self?.repeatMode = newRepeatMode
//                }
//            }
//            .store(in: &cancellables)
//            
//        // 앨범 아트 업데이트
//        controller.$albumArtwork
//            .receive(on: DispatchQueue.main)
//            .compactMap { $0 }
//            .map { data -> NSImage in
//                if let image = NSImage(data: data) {
//                    return image
//                } else {
//                    return NSImage(systemSymbolName: "music.note", accessibilityDescription: "Album Art") ?? NSImage()
//                }
//            }
//            .sink { [weak self] image in
//                self?.albumArt = image
//                self?.updateLastUpdated()
//            }
//            .store(in: &cancellables)
//            
//        print("✅ Enhanced MusicManager 초기화 성공")
//    }
//    
//    private func updateLastUpdated() {
//        lastUpdated = Date()
//    }
//    
//    // MARK: - Public Methods
//    func play() {
//        mediaController?.play()
//        updateLastUpdated()
//    }
//    
//    func pause() {
//        mediaController?.pause()
//        updateLastUpdated()
//    }
//    
//    func togglePlayPause() {
//        mediaController?.togglePlayPause()
//        updateLastUpdated()
//    }
//    
//    func nextTrack() {
//        mediaController?.nextTrack()
//        updateLastUpdated()
//    }
//    
//    func previousTrack() {
//        mediaController?.previousTrack()
//        updateLastUpdated()
//    }
//    
//    func seek(to time: TimeInterval) {
//        mediaController?.seek(to: time)
//        currentTime = time  // 즉시 UI 업데이트
//        updateLastUpdated()
//    }
//    
//    func toggleShuffle() {
//        mediaController?.toggleShuffle()
//        updateLastUpdated()
//    }
//    
//    func toggleRepeat() {
//        mediaController?.toggleRepeat()
//        updateLastUpdated()
//    }
//    
//    func fastForward15() {
//        mediaController?.fastForward15()
//        updateLastUpdated()
//    }
//    
//    func rewind15() {
//        mediaController?.rewind15()
//        updateLastUpdated()
//    }
//    
//    func setPlaybackRate(_ rate: Float) {
//        mediaController?.setPlaybackRate(rate)
//        updateLastUpdated()
//    }
//    
//    // MARK: - Computed Properties
//    var hasActiveMedia: Bool {
//        return !songTitle.isEmpty && !artistName.isEmpty
//    }
//    
//    var playbackProgress: Double {
//        guard duration > 0 else { return 0 }
//        return min(currentTime / duration, 1.0)
//    }
//    
//    // 현재 재생 중인 앱 이름 반환
//    var currentAppName: String {
//        switch bundleIdentifier {
//        case "com.apple.Music":
//            return "Apple Music"
//        case "com.spotify.client":
//            return "Spotify"
//        case "com.apple.WebKit.WebContent":
//            return "Safari"
//        case "com.google.Chrome":
//            return "Chrome"
//        case "com.apple.QuickTimePlayerX":
//            return "QuickTime Player"
//        case "com.apple.TV":
//            return "Apple TV"
//        default:
//            return bundleIdentifier.isEmpty ? "Music" : bundleIdentifier.components(separatedBy: ".").last ?? "Music"
//        }
//    }
//    
//    // 포맷된 시간 문자열
//    var formattedCurrentTime: String {
//        return formatTime(currentTime)
//    }
//    
//    var formattedDuration: String {
//        return formatTime(duration)
//    }
//    
//    private func formatTime(_ seconds: Double) -> String {
//        let totalSeconds = Int(seconds)
//        let minutes = totalSeconds / 60
//        let remainingSeconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, remainingSeconds)
//    }
//}



//
//  MusicManager.swift
//  Dynamic-Notch
//
//  Fixed version with proper progress tracking
//

import Foundation
import SwiftUI
import Combine

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    
    // MARK: - Published Properties
    @Published var songTitle: String = ""
    @Published var artistName: String = ""
    @Published var albumName: String = ""
    @Published var albumArt: NSImage = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Album Art") ?? NSImage()
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var bundleIdentifier: String = ""
    @Published var lastUpdated: Date = Date()
    @Published var playbackRate: Double = 1.0
    @Published var isShuffled: Bool = false
    @Published var repeatMode: RepeatMode = .off
    
    // MARK: - Private Properties
    private var mediaController: SimpleMediaRemoteController?
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    private var lastArtworkData: Data? = nil
    
    // 시간 추적을 위한 새로운 속성들
    private var playStartTime: Date = Date()
    private var pausedTime: Double = 0
    private var isTimerBasedUpdate = false
    
    private init() {
        setupMediaRemote()
        startPeriodicUpdates()
    }
    
    private func startPeriodicUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // MediaRemote에서 정보 업데이트 (5초마다)
            let timeSinceLastUpdate = Date().timeIntervalSince(self.lastUpdated)
            if timeSinceLastUpdate > 5.0 {
                self.mediaController?.updatePlayingState()
            }
            
            // 재생 중일 때만 내부 시간 업데이트
            if self.isPlaying {
                self.updateInternalTime()
            }
        }
    }
    
    private func updateInternalTime() {
        guard isPlaying && duration > 0 else { return }
        
        // 재생 시작 시간부터 경과된 시간 계산
        let elapsed = Date().timeIntervalSince(playStartTime) * playbackRate
        let newTime = pausedTime + elapsed
        
        // 범위 체크 및 업데이트
        if newTime <= duration && newTime >= 0 {
            isTimerBasedUpdate = true
            currentTime = newTime
            isTimerBasedUpdate = false
        } else if newTime > duration {
            // 곡이 끝났을 때
            isTimerBasedUpdate = true
            currentTime = duration
            isPlaying = false
            isTimerBasedUpdate = false
        }
    }
    
    private func resetTimeTracking() {
        playStartTime = Date()
        pausedTime = currentTime
    }
    
    deinit {
        updateTimer?.invalidate()
        cancellables.forEach { $0.cancel() }
    }
    
    private func setupMediaRemote() {
        guard let controller = SimpleMediaRemoteController() else {
            print("❌ Enhanced MediaRemote를 초기화할 수 없습니다")
            return
        }
        
        self.mediaController = controller
        
        // 상태 관찰 설정
        controller.$songTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                if title != self?.songTitle {
                    self?.songTitle = title
                    self?.updateLastUpdated()
                    print("🎵 곡 제목 업데이트: \(title)")
                }
            }
            .store(in: &cancellables)
            
        controller.$artistName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artist in
                if artist != self?.artistName {
                    self?.artistName = artist
                    self?.updateLastUpdated()
                    print("👤 아티스트 업데이트: \(artist)")
                }
            }
            .store(in: &cancellables)
            
        controller.$albumName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] album in
                if album != self?.albumName {
                    self?.albumName = album
                    self?.updateLastUpdated()
                }
            }
            .store(in: &cancellables)
            
        controller.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                guard let self = self else { return }
                
                if isPlaying != self.isPlaying {
                    self.isPlaying = isPlaying
                    
                    // 재생/정지 상태 변경 시 시간 추적 재설정
                    if isPlaying {
                        // 재생 시작
                        self.resetTimeTracking()
                        print("▶️ 재생 시작: \(self.currentTime)초부터")
                    } else {
                        // 정지 시 현재 시간을 pausedTime에 저장
                        self.pausedTime = self.currentTime
                        print("⏸️ 정지: \(self.currentTime)초에서 정지")
                    }
                    
                    self.updateLastUpdated()
                    print("⏯️ 재생 상태 업데이트: \(isPlaying ? "재생" : "정지")")
                }
            }
            .store(in: &cancellables)
            
        controller.$currentTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTime in
                guard let self = self else { return }
                
                // 내부 타이머 업데이트가 아닐 때만 MediaRemote 시간 적용
                if !self.isTimerBasedUpdate {
                    let timeDiff = abs(newTime - self.currentTime)
                    
                    // 시간 차이가 1초 이상이거나 새로운 곡일 때만 동기화
                    if timeDiff > 1.0 || newTime == 0 {
                        self.currentTime = newTime
                        self.pausedTime = newTime
                        self.resetTimeTracking()
                        print("⏰ 시간 동기화: \(newTime)초 (차이: \(timeDiff)초)")
                    }
                }
                
                self.updateLastUpdated()
            }
            .store(in: &cancellables)
            
        controller.$duration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                if duration != self?.duration {
                    self?.duration = duration
                    self?.updateLastUpdated()
                    print("⏱️ 총 시간: \(duration)초")
                }
            }
            .store(in: &cancellables)
            
        controller.$bundleIdentifier
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bundleId in
                if bundleId != self?.bundleIdentifier {
                    self?.bundleIdentifier = bundleId
                    self?.updateLastUpdated()
                    print("📱 앱 업데이트: \(bundleId)")
                }
            }
            .store(in: &cancellables)
            
        controller.$playbackRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                if rate != self?.playbackRate {
                    // 재생 속도가 변경되면 시간 추적 재설정
                    self?.playbackRate = rate
                    self?.resetTimeTracking()
                    print("🎵 재생 속도: \(rate)")
                }
            }
            .store(in: &cancellables)
            
        controller.$isShuffled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shuffled in
                if shuffled != self?.isShuffled {
                    self?.isShuffled = shuffled
                }
            }
            .store(in: &cancellables)
            
        controller.$repeatMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                let newRepeatMode = RepeatMode(rawValue: mode) ?? .off
                if newRepeatMode != self?.repeatMode {
                    self?.repeatMode = newRepeatMode
                }
            }
            .store(in: &cancellables)
            
        // 앨범 아트 업데이트 - 개선된 버전
        controller.$albumArtwork
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artworkData in
                self?.updateAlbumArt(artworkData)
            }
            .store(in: &cancellables)
            
        print("✅ Enhanced MusicManager 초기화 성공")
    }
    
    private func updateAlbumArt(_ artworkData: Data?) {
        // 앨범 아트 데이터가 실제로 변경되었는지 확인
        guard artworkData != lastArtworkData else { return }
        
        lastArtworkData = artworkData
        
        if let data = artworkData, !data.isEmpty {
            // 백그라운드에서 이미지 처리
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let image = NSImage(data: data) {
                    DispatchQueue.main.async {
                        print("🖼️ 앨범 아트 업데이트 성공")
                        self?.albumArt = image
                        self?.updateLastUpdated()
                    }
                } else {
                    print("⚠️ 앨범 아트 데이터 파싱 실패")
                    DispatchQueue.main.async {
                        self?.setDefaultAlbumArt()
                    }
                }
            }
        } else {
            // 앨범 아트가 없을 때 기본 이미지 설정
            print("📭 앨범 아트 없음 - 기본 이미지 사용")
            setDefaultAlbumArt()
        }
    }
    
    private func setDefaultAlbumArt() {
        if let defaultImage = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Album Art") {
            albumArt = defaultImage
        } else {
            // 시스템 심볼이 없을 경우 빈 이미지 생성
            albumArt = NSImage(size: NSSize(width: 100, height: 100))
        }
        updateLastUpdated()
    }
    
    private func updateLastUpdated() {
        lastUpdated = Date()
    }
    
    // MARK: - Public Methods
    func play() {
        mediaController?.play()
        updateLastUpdated()
    }
    
    func pause() {
        mediaController?.pause()
        updateLastUpdated()
    }
    
    func togglePlayPause() {
        mediaController?.togglePlayPause()
        updateLastUpdated()
    }
    
    func nextTrack() {
        mediaController?.nextTrack()
        updateLastUpdated()
        
        // 곡 변경 시 시간 추적 초기화
        currentTime = 0
        pausedTime = 0
        resetTimeTracking()
        
        // 곡 변경 시 즉시 정보 업데이트 요청
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.mediaController?.updateNowPlayingInfo()
        }
    }
    
    func previousTrack() {
        mediaController?.previousTrack()
        updateLastUpdated()
        
        // 곡 변경 시 시간 추적 초기화
        currentTime = 0
        pausedTime = 0
        resetTimeTracking()
        
        // 곡 변경 시 즉시 정보 업데이트 요청
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.mediaController?.updateNowPlayingInfo()
        }
    }
    
    func seek(to time: TimeInterval) {
        mediaController?.seek(to: time)
        
        // 시크 시 시간 추적 재설정
        isTimerBasedUpdate = true
        currentTime = time
        pausedTime = time
        resetTimeTracking()
        isTimerBasedUpdate = false
        
        updateLastUpdated()
        print("🎯 시크: \(time)초로 이동")
    }
    
    func toggleShuffle() {
        mediaController?.toggleShuffle()
        updateLastUpdated()
    }
    
    func toggleRepeat() {
        mediaController?.toggleRepeat()
        updateLastUpdated()
    }
    
    func fastForward15() {
        let newTime = currentTime + 15
        seek(to: min(newTime, duration))
    }
    
    func rewind15() {
        let newTime = currentTime - 15
        seek(to: max(newTime, 0))
    }
    
    func setPlaybackRate(_ rate: Float) {
        mediaController?.setPlaybackRate(rate)
        updateLastUpdated()
    }
    
    // 강제로 정보 업데이트 (디버깅용)
    func forceUpdateInfo() {
        print("🔄 강제 정보 업데이트 요청")
        mediaController?.updateNowPlayingInfo()
    }
    
    // MARK: - Computed Properties
    var hasActiveMedia: Bool {
        return !songTitle.isEmpty && !artistName.isEmpty && duration > 0
    }
    
    var playbackProgress: Double {
        guard duration > 0 else { return 0 }
        let progress = currentTime / duration
        return min(max(progress, 0), 1.0)  // 0~1 사이로 제한
    }
    
    // 백분율로 진행률 표시
    var playbackProgressPercent: Int {
        return Int(playbackProgress * 100)
    }
    
    // 현재 재생 중인 앱 이름 반환
    var currentAppName: String {
        switch bundleIdentifier {
        case "com.apple.Music":
            return "Apple Music"
        case "com.spotify.client":
            return "Spotify"
        case "com.apple.WebKit.WebContent":
            return "Safari"
        case "com.google.Chrome":
            return "Chrome"
        case "com.apple.QuickTimePlayerX":
            return "QuickTime Player"
        case "com.apple.TV":
            return "Apple TV"
        default:
            return bundleIdentifier.isEmpty ? "Music" : bundleIdentifier.components(separatedBy: ".").last ?? "Music"
        }
    }
    
    // 포맷된 시간 문자열
    var formattedCurrentTime: String {
        return formatTime(currentTime)
    }
    
    var formattedDuration: String {
        return formatTime(duration)
    }
    
    var formattedProgress: String {
        return "\(formattedCurrentTime) / \(formattedDuration)"
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return String(format: "%d:%02d:%02d", hours, remainingMinutes, remainingSeconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
}
