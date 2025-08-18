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


// 깃허브에서 해결방안 찾음 08.09

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
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
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
        let elapsed = Date().timeIntervalSince(playStartTime) 
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
            
            
        controller.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] remoteIsPlaying in
                guard let self = self else { return }
                
                // 실제 미디어 상태와 UI 상태가 다를 때만 동기화
                if remoteIsPlaying != self.isPlaying {
                    print("🔄 실제 재생 상태와 UI 상태 동기화: UI(\(self.isPlaying)) -> 실제(\(remoteIsPlaying))")
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isPlaying = remoteIsPlaying
                    }
                    
                    // 재생/정지 상태 변경 시 시간 추적 재설정
                    if remoteIsPlaying {
                        self.resetTimeTracking()
                        print("▶️ 재생 시작: \(self.currentTime)초부터")
                    } else {
                        self.pausedTime = self.currentTime
                        print("⏸️ 정지: \(self.currentTime)초에서 정지")
                    }
                    
                    self.updateLastUpdated()
                }
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
    
    // 강제로 정보 업데이트 (디버깅용)
    func forceUpdateInfo() {
        print("🔄 강제 정보 업데이트 요청")
        mediaController?.updateNowPlayingInfo()
        mediaController?.updatePlayingState()
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
