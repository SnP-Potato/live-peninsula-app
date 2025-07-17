//
//  MusicManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/14/25.
//

// MARK MediaRemote로 현재 재생중인 음악정보을 가져오기


/// MARK

/// MediaRemote에서 가져와야 할 주요 함수들
// 1. 현재 재생 정보 가져오기
//   "MRMediaRemoteGetNowPlayingInfo"
//   역할: 현재 재생 중인 곡 제목, 아티스트, 앨범 아트 등 정보 가져오기

// 2. 재생 상태 확인
//   "MRMediaRemoteGetNowPlayingApplicationIsPlaying"
//   역할: 음악이 재생 중인지 정지 중인지 확인

//  3. 미디어 제어 명령
//   "MRMediaRemoteSendCommand"
//   역할: 재생/정지, 다음곡, 이전곡 등 제어 명령 보내기

//4. 알림 등록
//   "MRMediaRemoteRegisterForNowPlayingNotifications"
//   역할: 음악 정보가 변경될 때 알림 받기


//  ##MusicManager에 필요한 기능별 함수##

//  [1]. songTitle, artistName 업데이트용
//  "MRMediaRemoteGetNowPlayingInfo" 이 함수로 곡 정보 가져오기


//  [2]. isPlaying 업데이트용
//  "MRMediaRemoteGetNowPlayingApplicationIsPlaying" 이 함수로 재생 상태 확인

//  [3]. playPause(), nextTrack(), previousTrack() 구현용
//  "MRMediaRemoteSendCommand" 이 함수로 음악 제어

//class MusicManager: ObservableObject {
//    static let shared = MusicManager()
//    
//    //음악정보
//    @Published var songTitle: String = "No Music"
//    @Published var artistName: String = "NO Artist"
//    @Published var isPlaying: Bool = false
//    
//    //UI요소들
//    @Published var album: Image? = nil
//    @Published var musicAppIcon: Image? = nil
//    @Published var albumColor: Color = .white
//    
//    private var getMusicInfo: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void)?
//    private var getPlayingStatus: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void)?
//    private var sendMusicCommand: (@convention(c) (Int, AnyObject?) -> Void)?
//    private var registerMusicNotifications: (@convention(c) (DispatchQueue) -> Void)?
//    private var getCurrentMusicApp: (@convention(c) (DispatchQueue, @escaping (Any?) -> Void) -> Void)?
//    private var setElapsedTime: (@convention(c) (Double) -> Void)?
//    
//    private var mediaRemoteBundle: CFBundle?
//    
//    private init() {
//        connectToMusicsystem()
//        
//        // 연결 완료 후 음악 정보 테스트
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            print("🧪 음악 정보 테스트 시작")
//            
//            self.getCurrentMusicApp?(DispatchQueue.main) { client in
//                if client == nil {
//                    print("⛔️ 음악 클라이언트 없음 - 음악 정보 요청 중단")
//                    return
//                } else {
//                    self.extractMusicInfo()
//                }
//            }
//        }
//    }
//    
//    
//    //진행할 단게: [1단계] 프레임워크 찾기, [2단계] 프레임워크 로드하기, [3단계] 함수별 포인트 연결
//    func connectToMusicsystem() {
//        
//        /// [1단계] 프레임워크 찾기
//        guard let frameworkURL = URL(string: "/System/Library/PrivateFrameworks/MediaRemote.framework") else {
//            print("MediaRemote의 경로을 찾을 수 없음")
//            return
//        }
//        /// [2단계] 프레임워크 로드하기& 메모리에 올리기
//        guard let bundle = CFBundleCreate(kCFAllocatorDefault, frameworkURL as CFURL) else {
//            print(" MediaRemote 프레임워크를 로드할 수 없습니다")
//            return
//        }
//        
//        // 나중에 또 사용하기 해야되서 변수 따로 저장
//        self.mediaRemoteBundle = bundle
//        print("✅ MediaRemote 프레임워크 로드 성공")
//        
//        
//        /// [3단계] 함수별 포인트 연결
//        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) {
//            //unsafeBitCast은 강제 타입변환
//            //unsafeBitCast(원본, to: 바꿀타입.self)
//            getMusicInfo = unsafeBitCast(functionPointer, to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)
//            print("음악 정보 가져오기 성공")
//        } else {
//            print(" 음악 정보 가져오기 함수 연결 실패")
//            return
//        }
//        
//        // 재생확인상태
//        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString) {
//            getPlayingStatus = unsafeBitCast(functionPointer, to: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void).self)
//            print("✅ 재생 상태 확인 함수 연결 성공")
//        } else {
//            print("❌ 재생 상태 확인 함수 연결 실패")
//            return
//        }
//        
//        // 4. 미디어 제어 명령 함수
//        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString) {
//            sendMusicCommand = unsafeBitCast(functionPointer, to: (@convention(c) (Int, AnyObject?) -> Void).self)
//            print("✅ 미디어 제어 명령 함수 연결 성공")
//        } else {
//            print("❌ 미디어 제어 명령 함수 연결 실패")
//            return
//        }
//        
//        // 5. 알림 등록 함수
//        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString) {
//            registerMusicNotifications = unsafeBitCast(functionPointer, to: (@convention(c) (DispatchQueue) -> Void).self)
//            print("✅ 알림 등록 함수 연결 성공")
//        } else {
//            print("❌ 알림 등록 함수 연결 실패")
//            return
//        }
//        
//        // 6. 현재 음악 앱 정보 가져오기 함수
//        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingClient" as CFString) {
//            getCurrentMusicApp = unsafeBitCast(functionPointer, to: (@convention(c) (DispatchQueue, @escaping (Any?) -> Void) -> Void).self)
//            print("✅ 음악 앱 정보 가져오기 함수 연결 성공")
//        } else {
//            print("❌ 음악 앱 정보 가져오기 함수 연결 실패")
//            return
//        }
//        
//        // 7. 재생 위치 설정 함수
//        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSetElapsedTime" as CFString) {
//            setElapsedTime = unsafeBitCast(functionPointer, to: (@convention(c) (Double) -> Void).self)
//            print("✅ 재생 위치 설정 함수 연결 성공")
//        } else {
//            print("❌ 재생 위치 설정 함수 연결 실패")
//        }
//        
//        print("🎵 음악 시스템 연결 완료!")
//        if let getCurrentMusicApp = getCurrentMusicApp {
//            getCurrentMusicApp(DispatchQueue.main) { client in
//                if let client = client {
//                    print("🎯 현재 연결된 미디어 클라이언트 있음: \(client)")
//                } else {
//                    print("❌ 현재 재생 중인 미디어 클라이언트를 찾을 수 없습니다")
//                }
//            }
//        } else {
//            print("❌ getCurrentMusicApp 함수 포인터가 연결되지 않음")
//        }
//    }
//    
//    /// MediaRemote에서 제공하는 데이터 키들
//    //"kMRMediaRemoteNowPlayingInfoTitle"     // 곡 제목
//    //"kMRMediaRemoteNowPlayingInfoArtist"    // 아티스트
//    //"kMRMediaRemoteNowPlayingInfoAlbum"     // 앨범명
//    //"kMRMediaRemoteNowPlayingInfoArtworkData" // 앨범 아트
//    //"kMRMediaRemoteNowPlayingInfoDuration"  // 총 시간
//    //"kMRMediaRemoteNowPlayingInfoElapsedTime" // 현재 재생 시간
//    func extractMusicInfo() {
//        guard let getMusicInfo = getMusicInfo else {
//            print("❌ getMusicInfo 함수 포인터가 연결되지 않음")
//            return
//        }
//        
//        print("🎵 음악 정보 요청 중...")
//        
//        getMusicInfo(DispatchQueue.main) { musicData in
//            print("📦 받은 데이터: \(musicData)")
//            
//            // 빈 데이터 체크
//            if musicData.isEmpty {
//                print("❌ 음악 데이터가 비어있음 - 음악이 재생되지 않고 있을 가능성")
//                return
//            }
//            
//            // 데이터 파싱 시작
//            print("🔍 데이터 파싱 중...")
//            
//            // 1. 곡 제목 추출
//            if let title = musicData["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
//                DispatchQueue.main.async {
//                    self.songTitle = title
//                    print("🎼 곡 제목: \(title)")
//                }
//            } else {
//                print("❌ 곡 제목을 찾을 수 없음")
//            }
//            
//            // 2. 아티스트 추출
//            if let artist = musicData["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
//                DispatchQueue.main.async {
//                    self.artistName = artist
//                    print("👨‍🎤 아티스트: \(artist)")
//                }
//            } else {
//                print("❌ 아티스트를 찾을 수 없음")
//            }
//            
//            // 3. 앨범명 추출 (선택적)
//            if let album = musicData["kMRMediaRemoteNowPlayingInfoAlbum"] as? String {
//                print("💿 앨범: \(album)")
//            }
//            
//            // 4. 재생 시간 정보 (선택적)
//            if let duration = musicData["kMRMediaRemoteNowPlayingInfoDuration"] as? Double {
//                print("⏱️ 총 시간: \(duration)초")
//            }
//            
//            if let elapsedTime = musicData["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double {
//                print("⏰ 현재 시간: \(elapsedTime)초")
//            }
//            
//            // 5. 앨범 아트 (나중에 구현)
//            if let artworkData = musicData["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
//                print("🖼️ 앨범 아트 데이터 있음 (크기: \(artworkData.count) bytes)")
//                // TODO: 나중에 Image로 변환
//            }
//            
//            print("✅ 음악 정보 파싱 완료!")
//        }
//    }
//
//
//
//func playPause() {
//    isPlaying.toggle()
//    print("재생&정지")
//}
//
//func nextTrack() {
//    
//}
//
//func previousTrack() {
//    
//}
//}

//
//  MusicManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/14/25.
//

//
//  MusicManager.swift - 권한 요청 강화 버전
//  Dynamic-Notch
//

import AppKit
import Combine
import SwiftUI

class MusicManager: ObservableObject {
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var debounceToggle: DispatchWorkItem?
    
    @Published var songTitle: String = "No Music Playing"
    @Published var artistName: String = "Unknown Artist"
    @Published var albumArt: NSImage = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Music")!
    @Published var isPlaying = false
    @Published var musicToggledManually: Bool = false
    @Published var album: String = "Unknown Album"
    @Published var lastUpdated: Date = .init()
    @Published var isPlayerIdle: Bool = true
    @Published var bundleIdentifier: String? = nil
    @Published var songDuration: TimeInterval = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var timestampDate: Date = .init()
    @Published var playbackRate: Double = 0
    
    private let mediaRemoteBundle: CFBundle
    private let MRMediaRemoteGetNowPlayingInfo: @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private let MRMediaRemoteRegisterForNowPlayingNotifications: @convention(c) (DispatchQueue) -> Void
    private let MRMediaRemoteGetNowPlayingApplicationIsPlaying: @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
    
    var nowPlaying: NowPlaying
    
    // MARK: - Initialization
    
    init?() {
        self.nowPlaying = NowPlaying.sharedInstance()
        
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")),
              let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString),
              let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString),
              let MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString)
        else {
            print("Failed to load MediaRemote.framework or get function pointers")
            return nil
        }
        
        self.mediaRemoteBundle = bundle
        self.MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)
        self.MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: (@convention(c) (DispatchQueue) -> Void).self)
        self.MRMediaRemoteGetNowPlayingApplicationIsPlaying = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer, to: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void).self)
        
        setupNowPlayingObserver()
        fetchNowPlayingInfo()
        
        if nowPlaying.playing {
            fetchNowPlayingInfo()
        }
    }
    
    deinit {
        debounceToggle?.cancel()
        cancellables.removeAll()
    }
    
    // MARK: - Setup Methods
    
    private func setupNowPlayingObserver() {
        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)
        
        // NowPlaying 클래스의 알림 관찰
        NotificationCenter.default.publisher(for: NSNotification.Name("NowPlayingInfo"))
            .sink { [weak self] _ in
                self?.updateFromNowPlaying()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("NowPlayingState"))
            .sink { [weak self] _ in
                self?.updatePlayingState()
            }
            .store(in: &cancellables)
        
        // MediaRemote 알림 관찰
        observeNotification(name: "kMRMediaRemoteNowPlayingInfoDidChangeNotification") { [weak self] in
            self?.fetchNowPlayingInfo()
        }
        
        observeNotification(name: "kMRMediaRemoteNowPlayingApplicationDidChangeNotification") { [weak self] in
            self?.updateApp()
        }
    }
    
    private func observeNotification(name: String, handler: @escaping () -> Void) {
        NotificationCenter.default.publisher(for: NSNotification.Name(name))
            .sink { _ in handler() }
            .store(in: &cancellables)
    }
    
    // MARK: - Update Methods
    
    private func updateFromNowPlaying() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let title = self.nowPlaying.title, !title.isEmpty {
                self.songTitle = title
            }
            
            if let artist = self.nowPlaying.artist, !artist.isEmpty {
                self.artistName = artist
            }
            
            if let album = self.nowPlaying.album, !album.isEmpty {
                self.album = album
            }
            
            if let bundleId = self.nowPlaying.appBundleIdentifier {
                self.bundleIdentifier = bundleId
            }
            
            if let icon = self.nowPlaying.appIcon {
                self.albumArt = icon
            }
        }
    }
    
    private func updatePlayingState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let wasPlaying = self.isPlaying
            self.isPlaying = self.nowPlaying.playing
            
            if wasPlaying != self.isPlaying {
                if !self.isPlaying {
                    self.lastUpdated = Date()
                }
                self.updateIdleState()
            }
        }
    }
    
    @objc func updateApp() {
        bundleIdentifier = nowPlaying.appBundleIdentifier ?? "com.apple.Music"
    }
    
    @objc func fetchNowPlayingInfo() {
        if musicToggledManually { return }
        
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { [weak self] information in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.processNowPlayingInfo(information)
            }
        }
        
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(DispatchQueue.main) { [weak self] isPlaying in
            DispatchQueue.main.async {
                self?.musicIsPaused(state: isPlaying, setIdle: true)
            }
        }
    }
    
    private func processNowPlayingInfo(_ information: [String: Any]) {
        if let title = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String, !title.isEmpty {
            self.songTitle = title
        }
        
        if let artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String, !artist.isEmpty {
            self.artistName = artist
        }
        
        if let album = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String, !album.isEmpty {
            self.album = album
        }
        
        if let duration = information["kMRMediaRemoteNowPlayingInfoDuration"] as? TimeInterval {
            self.songDuration = duration
        }
        
        if let elapsedTime = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? TimeInterval {
            self.elapsedTime = elapsedTime
        }
        
        if let timestampDate = information["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date {
            self.timestampDate = timestampDate
        }
        
        if let playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double {
            self.playbackRate = playbackRate
        }
        
        if let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data,
           let artworkImage = NSImage(data: artworkData) {
            self.albumArt = artworkImage
        } else if let appIcon = AppIconAsNSImage(for: bundleIdentifier ?? "") {
            self.albumArt = appIcon
        }
    }
    
    func musicIsPaused(state: Bool, bypass: Bool = false, setIdle: Bool = false) {
        if musicToggledManually && !bypass { return }
        
        _ = isPlaying
        
        withAnimation(.smooth) {
            self.isPlaying = state
            
            if !state {
                self.lastUpdated = Date()
            }
            
            if setIdle {
                updateIdleState()
            }
        }
    }
    
    private func updateIdleState() {
        debounceToggle?.cancel()
        
        if isPlaying {
            isPlayerIdle = false
        } else {
            debounceToggle = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if self.lastUpdated.timeIntervalSinceNow < -3.0 { // 3초 대기
                    withAnimation {
                        self.isPlayerIdle = !self.isPlaying
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: debounceToggle!)
        }
    }
    
    // MARK: - Control Methods
    
    func togglePlayPause() {
        // PlaybackManager를 통한 제어 로직 구현
        print("Toggle Play/Pause")
    }
    
    func nextTrack() {
        print("Next Track")
    }
    
    func previousTrack() {
        print("Previous Track")
    }
    
    func seekTrack(to time: TimeInterval) {
        print("Seek to: \(time)")
    }
    
    func openMusicApp() {
        guard let bundleID = bundleIdentifier else {
            print("Error: bundleIdentifier is nil")
            return
        }
        
        let workspace = NSWorkspace.shared
        if workspace.launchApplication(withBundleIdentifier: bundleID, options: [], additionalEventParamDescriptor: nil, launchIdentifier: nil) {
            print("Launched app with bundle ID: \(bundleID)")
        } else {
            print("Failed to launch app with bundle ID: \(bundleID)")
        }
    }
}

// Helper function for app icons
func AppIconAsNSImage(for bundleID: String) -> NSImage? {
    let workspace = NSWorkspace.shared
    
    if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleID) {
        let appIcon = workspace.icon(forFile: appURL.path)
        return appIcon
    }
    return nil
}
