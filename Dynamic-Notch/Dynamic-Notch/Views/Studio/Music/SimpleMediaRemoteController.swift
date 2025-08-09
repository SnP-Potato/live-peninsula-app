//
//  SimpleMediaRemoteController.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/5/25.
//

//import Foundation
//import Combine
//
//class SimpleMediaRemoteController: ObservableObject {
//    @Published var songTitle: String = ""
//    @Published var artistName: String = ""
//    @Published var albumName: String = ""
//    @Published var isPlaying: Bool = false
//    @Published var albumArtwork: Data? = nil
//    @Published var currentTime: Double = 0
//    @Published var duration: Double = 0
//    @Published var bundleIdentifier: String = ""
//    
//    // MediaRemote 함수들
//    private let MRMediaRemoteGetNowPlayingInfo: @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
//    private let MRMediaRemoteRegisterForNowPlayingNotifications: @convention(c) (DispatchQueue) -> Void
//    private let MRMediaRemoteSendCommand: @convention(c) (Int, AnyObject?) -> Void
//    private let MRMediaRemoteGetNowPlayingApplicationIsPlaying: @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
//    
//    init?() {
//        // MediaRemote 프레임워크 로드
//        guard let bundle = CFBundleCreate(
//            kCFAllocatorDefault,
//            NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")),
//              
//        let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(
//            bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString),
//        let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(
//            bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString),
//        let MRMediaRemoteSendCommandPointer = CFBundleGetFunctionPointerForName(
//            bundle, "MRMediaRemoteSendCommand" as CFString),
//        let MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer = CFBundleGetFunctionPointerForName(
//            bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString)
//        else {
//            print("❌ MediaRemote 프레임워크를 로드할 수 없습니다.")
//            return nil
//        }
//        
//        // 함수 포인터 변환
//        self.MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(
//            MRMediaRemoteGetNowPlayingInfoPointer,
//            to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self
//        )
//        self.MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(
//            MRMediaRemoteRegisterForNowPlayingNotificationsPointer,
//            to: (@convention(c) (DispatchQueue) -> Void).self
//        )
//        self.MRMediaRemoteSendCommand = unsafeBitCast(
//            MRMediaRemoteSendCommandPointer,
//            to: (@convention(c) (Int, AnyObject?) -> Void).self
//        )
//        self.MRMediaRemoteGetNowPlayingApplicationIsPlaying = unsafeBitCast(
//            MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer,
//            to: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void).self
//        )
//        
//        print("✅ MediaRemote 초기화 성공")
//        setupNotifications()
//        updateNowPlayingInfo()
//        updatePlayingState()
//    }
//    
//    private func setupNotifications() {
//        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)
//        
//        let notifications = [
//            "kMRMediaRemoteNowPlayingInfoDidChangeNotification",
//            "kMRMediaRemoteNowPlayingApplicationDidChangeNotification",
//            "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"
//        ]
//        
//        for notification in notifications {
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(updateNowPlayingInfo),
//                name: NSNotification.Name(notification),
//                object: nil
//            )
//        }
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(updatePlayingState),
//            name: NSNotification.Name("kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"),
//            object: nil
//        )
//    }
//    
//    @objc func updateNowPlayingInfo() {
//        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { [weak self] info in
//            DispatchQueue.main.async {
//                // 디버깅 로그 간소화
//                if !info.isEmpty {
//                    print("🎵 MediaRemote 정보 수신: \(info.keys.joined(separator: ", "))")
//                }
//                
//                // 제목 찾기
//                if let title = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
//                    self?.songTitle = title
//                    print("✅ 제목: '\(title)'")
//                }
//                
//                // 아티스트 찾기
//                if let artist = info["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
//                    self?.artistName = artist
//                    print(" 아티스트: '\(artist)'")
//                }
//                
//                // 앨범 찾기
//                if let album = info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String {
//                    self?.albumName = album
//                }
//                
//                // 시간 정보
//                if let time = info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double {
//                    self?.currentTime = time
//                }
//                
//                if let duration = info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double {
//                    self?.duration = duration
//                }
//                
//                // 앨범 아트
//                if let artData = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
//                    self?.albumArtwork = artData
//                }
//            }
//        }
//    }
//    
//    @objc func updatePlayingState() {
//        MRMediaRemoteGetNowPlayingApplicationIsPlaying(DispatchQueue.main) { [weak self] playing in
//            DispatchQueue.main.async {
//                self?.isPlaying = playing
//                print(" 재생 상태: \(playing ? "재생 중" : "정지")")
//            }
//        }
//    }
//    
//    // MARK: - 제어 함수들
//    func play() {
//        MRMediaRemoteSendCommand(1, nil)
//        print(" 재생 명령")
//    }
//    
//    func pause() {
//        MRMediaRemoteSendCommand(0, nil)
//        print(" 정지 명령")
//    }
//    
//    func togglePlayPause() {
//        MRMediaRemoteSendCommand(2, nil)
//        print(" 재생/정지 토글")
//    }
//    
//    func nextTrack() {
//        MRMediaRemoteSendCommand(4, nil)
//        print(" 다음 곡")
//    }
//    
//    func previousTrack() {
//        MRMediaRemoteSendCommand(5, nil)
//        print(" 이전 곡")
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//}


//
//  SimpleMediaRemoteController.swift
//  Dynamic-Notch
//
//  Enhanced version based on Stack Overflow research
//

//import Foundation
//import Combine
//
//class SimpleMediaRemoteController: ObservableObject {
//    @Published var songTitle: String = ""
//    @Published var artistName: String = ""
//    @Published var albumName: String = ""
//    @Published var isPlaying: Bool = false
//    @Published var albumArtwork: Data? = nil
//    @Published var currentTime: Double = 0
//    @Published var duration: Double = 0
//    @Published var bundleIdentifier: String = ""
//    @Published var playbackRate: Double = 1.0
//    @Published var isShuffled: Bool = false
//    @Published var repeatMode: Int = 0
//    
//    // MediaRemote 함수들
//    private let MRMediaRemoteGetNowPlayingInfo: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void)?
//    private let MRMediaRemoteRegisterForNowPlayingNotifications: (@convention(c) (DispatchQueue) -> Void)?
//    private let MRMediaRemoteSendCommand: (@convention(c) (UInt32, [String: Any]?) -> Bool)?
//    private let MRMediaRemoteGetNowPlayingApplicationIsPlaying: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void)?
//    private let MRMediaRemoteGetNowPlayingClient: (@convention(c) (DispatchQueue, @escaping (AnyObject?) -> Void) -> Void)?
//    private let MRMediaRemoteSetElapsedTime: (@convention(c) (TimeInterval) -> Bool)?
//    
//    // 노티피케이션 이름들
//    private let kMRMediaRemoteNowPlayingInfoDidChangeNotification = "kMRMediaRemoteNowPlayingInfoDidChangeNotification"
//    private let kMRMediaRemoteNowPlayingApplicationDidChangeNotification = "kMRMediaRemoteNowPlayingApplicationDidChangeNotification"
//    private let kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification = "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"
//    
//    // MRCommand 정의 (Stack Overflow에서 참조한 값들)
//    private enum MRCommand: UInt32 {
//        case play = 0
//        case pause = 1
//        case togglePlayPause = 2
//        case stop = 3
//        case nextTrack = 4
//        case previousTrack = 5
//        case advanceShuffleMode = 6
//        case advanceRepeatMode = 7
//        case beginFastForward = 8
//        case endFastForward = 9
//        case beginRewind = 10
//        case endRewind = 11
//        case rewind15Seconds = 12
//        case fastForward15Seconds = 13
//        case rewind30Seconds = 14
//        case fastForward30Seconds = 15
//        case toggleRecord = 16
//        case skipForward = 17
//        case skipBackward = 18
//        case changePlaybackRate = 19
//        case rateTrack = 20
//        case likeTrack = 21
//        case dislikeTrack = 22
//        case bookmarkTrack = 23
//        case seekToPlaybackPosition = 45
//        case changeShuffleMode = 46
//        case changeRepeatMode = 47
//    }
//    
//    init?() {
//        // MediaRemote 프레임워크 로드
//        guard let bundle = CFBundleCreate(
//            kCFAllocatorDefault,
//            NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")
//        ) else {
//            print("❌ MediaRemote 프레임워크를 찾을 수 없습니다.")
//            return nil
//        }
//        
//        // 함수 포인터들 가져오기 - static 함수 사용
//        self.MRMediaRemoteGetNowPlayingInfo = Self.loadFunction(
//            from: bundle,
//            name: "MRMediaRemoteGetNowPlayingInfo",
//            type: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self
//        )
//        
//        self.MRMediaRemoteRegisterForNowPlayingNotifications = Self.loadFunction(
//            from: bundle,
//            name: "MRMediaRemoteRegisterForNowPlayingNotifications",
//            type: (@convention(c) (DispatchQueue) -> Void).self
//        )
//        
//        self.MRMediaRemoteSendCommand = Self.loadFunction(
//            from: bundle,
//            name: "MRMediaRemoteSendCommand",
//            type: (@convention(c) (UInt32, [String: Any]?) -> Bool).self
//        )
//        
//        self.MRMediaRemoteGetNowPlayingApplicationIsPlaying = Self.loadFunction(
//            from: bundle,
//            name: "MRMediaRemoteGetNowPlayingApplicationIsPlaying",
//            type: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void).self
//        )
//        
//        self.MRMediaRemoteGetNowPlayingClient = Self.loadFunction(
//            from: bundle,
//            name: "MRMediaRemoteGetNowPlayingClient",
//            type: (@convention(c) (DispatchQueue, @escaping (AnyObject?) -> Void) -> Void).self
//        )
//        
//        self.MRMediaRemoteSetElapsedTime = Self.loadFunction(
//            from: bundle,
//            name: "MRMediaRemoteSetElapsedTime",
//            type: (@convention(c) (TimeInterval) -> Bool).self
//        )
//        
//        // 필수 함수들이 로드되었는지 확인
//        guard MRMediaRemoteGetNowPlayingInfo != nil,
//              MRMediaRemoteRegisterForNowPlayingNotifications != nil,
//              MRMediaRemoteSendCommand != nil else {
//            print("❌ 필수 MediaRemote 함수들을 로드할 수 없습니다.")
//            return nil
//        }
//        
//        print("✅ MediaRemote 초기화 성공")
//        setupNotifications()
//        updateNowPlayingInfo()
//        updatePlayingState()
//        updateNowPlayingClient()
//    }
//    
//    // 제네릭 함수 로더 - static으로 변경
//    private static func loadFunction<T>(from bundle: CFBundle, name: String, type: T.Type) -> T? {
//        guard let functionPointer = CFBundleGetFunctionPointerForName(bundle, name as CFString) else {
//            print("❌ \(name) 함수를 찾을 수 없습니다.")
//            return nil
//        }
//        return unsafeBitCast(functionPointer, to: type)
//    }
//    
//    private func setupNotifications() {
//        MRMediaRemoteRegisterForNowPlayingNotifications?(DispatchQueue.main)
//        
//        let notifications = [
//            kMRMediaRemoteNowPlayingInfoDidChangeNotification,
//            kMRMediaRemoteNowPlayingApplicationDidChangeNotification,
//            kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification
//        ]
//        
//        for notification in notifications {
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(handleNotification(_:)),
//                name: NSNotification.Name(notification),
//                object: nil
//            )
//        }
//    }
//    
//    @objc private func handleNotification(_ notification: Notification) {
//        print("🔔 노티피케이션 수신: \(notification.name.rawValue)")
//        
//        switch notification.name.rawValue {
//        case kMRMediaRemoteNowPlayingInfoDidChangeNotification:
//            updateNowPlayingInfo()
//            // 재생 정보가 변경될 때도 재생 상태 확인
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//                self?.updatePlayingState()
//            }
//        case kMRMediaRemoteNowPlayingApplicationDidChangeNotification:
//            updateNowPlayingInfo()
//            updateNowPlayingClient()
//            updatePlayingState()
//        case kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification:
//            updatePlayingState()
//        default:
//            break
//        }
//    }
//    
//    @objc func updateNowPlayingInfo() {
//        MRMediaRemoteGetNowPlayingInfo?(DispatchQueue.main) { [weak self] info in
//            DispatchQueue.main.async {
//                self?.processNowPlayingInfo(info)
//            }
//        }
//    }
//    
//    private func processNowPlayingInfo(_ info: [String: Any]) {
//        if !info.isEmpty {
//            print("🎵 MediaRemote 정보 수신: \(info.keys.joined(separator: ", "))")
//            
//            // 받은 정보의 값들을 로그로 확인
//            if let rate = info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double {
//                print("📊 재생 속도: \(rate)")
//            }
//            if let time = info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double {
//                print("⏱️ 경과 시간: \(time)")
//            }
//            if let duration = info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double {
//                print("⏱️ 총 시간: \(duration)")
//            }
//        }
//        
//        // 제목
//        if let title = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
//            self.songTitle = title
//        }
//        
//        // 아티스트
//        if let artist = info["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
//            self.artistName = artist
//        }
//        
//        // 앨범
//        if let album = info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String {
//            self.albumName = album
//        }
//        
//        // 시간 정보
//        let previousTime = self.currentTime
//        if let time = info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double {
//            self.currentTime = time
//        }
//        
//        if let duration = info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double {
//            self.duration = duration
//        }
//        
//        // 재생 상태 추론 - 여러 방법 조합
//        var inferredIsPlaying = false
//        
//        // 방법 1: 재생 속도로 판단
//        if let rate = info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double {
//            self.playbackRate = rate
//            if rate > 0 {
//                inferredIsPlaying = true
//                print("✅ 재생 속도로 재생 중 판단: \(rate)")
//            }
//        }
//        
//        // 방법 2: 시간이 증가하고 있는지 확인 (이전 시간과 비교)
//        if !inferredIsPlaying && self.currentTime > previousTime && self.currentTime > 0 {
//            inferredIsPlaying = true
//            print("✅ 시간 증가로 재생 중 판단: \(previousTime) -> \(self.currentTime)")
//        }
//        
//        // 방법 3: 곡 제목이 있고 시간이 0보다 크면 재생 중으로 가정
//        if !inferredIsPlaying && !self.songTitle.isEmpty && self.currentTime > 0 && self.duration > 0 {
//            inferredIsPlaying = true
//            print("✅ 곡 정보와 시간으로 재생 중 판단")
//        }
//        
//        // 상태 업데이트
//        if self.isPlaying != inferredIsPlaying {
//            print("🔄 재생 상태 변경: \(self.isPlaying) -> \(inferredIsPlaying)")
//            self.isPlaying = inferredIsPlaying
//        }
//        
//        // 셔플 모드
//        if let shuffleMode = info["kMRMediaRemoteNowPlayingInfoShuffleMode"] as? Int {
//            self.isShuffled = shuffleMode != 0
//        }
//        
//        // 반복 모드
//        if let repeatMode = info["kMRMediaRemoteNowPlayingInfoRepeatMode"] as? Int {
//            self.repeatMode = repeatMode
//        }
//        
//        // 앨범 아트
//        if let artData = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
//            self.albumArtwork = artData
//        }
//    }
//    
//    @objc func updatePlayingState() {
//        // MRMediaRemoteGetNowPlayingApplicationIsPlaying이 제대로 작동하지 않으므로
//        // 대신 nowPlayingInfo를 통해 상태를 추론하도록 변경
//        print("🔄 재생 상태 업데이트 시도 (nowPlayingInfo 방식)")
//        updateNowPlayingInfo()
//    }
//    
//    private func updateNowPlayingClient() {
//        MRMediaRemoteGetNowPlayingClient?(DispatchQueue.main) { [weak self] client in
//            DispatchQueue.main.async {
//                // 클라이언트에서 번들 식별자 추출 시도
//                if let client = client {
//                    // 클라이언트 객체에서 번들 식별자를 가져오는 방법은 비공개 API이므로
//                    // 안전하게 처리해야 함
//                    let description = String(describing: client)
//                    if let range = description.range(of: "bundleIdentifier: ") {
//                        let startIndex = range.upperBound
//                        if let endRange = description[startIndex...].range(of: ",") {
//                            let bundleId = String(description[startIndex..<endRange.lowerBound])
//                            self?.bundleIdentifier = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    // MARK: - 제어 함수들
//    func play() {
//        let success = MRMediaRemoteSendCommand?(MRCommand.play.rawValue, nil) ?? false
//        print("▶️ 재생 명령 \(success ? "성공" : "실패")")
//        
//        // 명령 후 상태 업데이트
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//            self?.updatePlayingState()
//        }
//    }
//    
//    func pause() {
//        let success = MRMediaRemoteSendCommand?(MRCommand.pause.rawValue, nil) ?? false
//        print("⏸️ 정지 명령 \(success ? "성공" : "실패")")
//        
//        // 명령 후 상태 업데이트
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//            self?.updatePlayingState()
//        }
//    }
//    
//    func togglePlayPause() {
//        let success = MRMediaRemoteSendCommand?(MRCommand.togglePlayPause.rawValue, nil) ?? false
//        print("⏯️ 재생/정지 토글 \(success ? "성공" : "실패")")
//        
//        // 토글 후 상태 업데이트 - 약간 더 긴 지연
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
//            self?.updatePlayingState()
//            self?.updateNowPlayingInfo()
//        }
//    }
//    
//    func nextTrack() {
//        _ = MRMediaRemoteSendCommand?(MRCommand.nextTrack.rawValue, nil)
//        print("⏭️ 다음 곡")
//    }
//    
//    func previousTrack() {
//        _ = MRMediaRemoteSendCommand?(MRCommand.previousTrack.rawValue, nil)
//        print("⏮️ 이전 곡")
//    }
//    
//    func seek(to time: TimeInterval) {
//        _ = MRMediaRemoteSetElapsedTime?(time)
//        print("🕒 시간 탐색: \(time)초")
//    }
//    
//    func toggleShuffle() {
//        _ = MRMediaRemoteSendCommand?(MRCommand.advanceShuffleMode.rawValue, nil)
//        print("🔀 셔플 토글")
//    }
//    
//    func toggleRepeat() {
//        _ = MRMediaRemoteSendCommand?(MRCommand.advanceRepeatMode.rawValue, nil)
//        print("🔁 반복 토글")
//    }
//    
//    func fastForward15() {
//        _ = MRMediaRemoteSendCommand?(MRCommand.fastForward15Seconds.rawValue, nil)
//        print("⏩ 15초 앞으로")
//    }
//    
//    func rewind15() {
//        _ = MRMediaRemoteSendCommand?(MRCommand.rewind15Seconds.rawValue, nil)
//        print("⏪ 15초 뒤로")
//    }
//    
//    func setPlaybackRate(_ rate: Float) {
//        let options = ["kMRMediaRemoteOptionPlaybackRate": rate]
//        _ = MRMediaRemoteSendCommand?(MRCommand.changePlaybackRate.rawValue, options)
//        print("🎵 재생 속도 변경: \(rate)")
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//}


//
//  SimpleMediaRemoteController.swift
//  Dynamic-Notch
//
//  Enhanced with mediaremote-adapter integration
//

import Foundation
import Combine

class SimpleMediaRemoteController: ObservableObject {
    @Published var songTitle: String = ""
    @Published var artistName: String = ""
    @Published var albumName: String = ""
    @Published var isPlaying: Bool = false
    @Published var albumArtwork: Data? = nil
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var bundleIdentifier: String = ""
    @Published var playbackRate: Double = 1.0
    @Published var isShuffled: Bool = false
    @Published var repeatMode: Int = 0
    
    private var process: Process?
    private var pipe: Pipe?
    private var buffer = ""
    
    init?() {
        guard setupMediaRemoteAdapter() else {
            print("❌ MediaRemote Adapter를 설정할 수 없습니다")
            return nil
        }
        
        print("✅ MediaRemote Adapter 초기화 성공")
        updateNowPlayingInfo()
    }
    
    deinit {
        cleanup()
    }
    
    private func setupMediaRemoteAdapter() -> Bool {
        // Bundle에서 스크립트와 프레임워크 경로 찾기
        guard let scriptURL = Bundle.main.url(forResource: "mediaremote-adapter", withExtension: "pl"),
              let frameworkPath = Bundle.main.privateFrameworksPath?.appending("/MediaRemoteAdapter.framework") else {
            print("❌ mediaremote-adapter.pl 또는 프레임워크를 찾을 수 없습니다")
            return false
        }
        
        // 스트림 모드로 실행 (실시간 업데이트)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
        process.arguments = [
            scriptURL.path,
            frameworkPath,
            "stream",
            "--debounce=50" // 50ms 디바운스로 스팸 방지
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        self.process = process
        self.pipe = pipe
        
        // 출력 읽기 핸들러 설정
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let self = self else { return }
            
            if let chunk = String(data: data, encoding: .utf8) {
                self.buffer.append(chunk)
                self.processBuffer()
            }
        }
        
        // 프로세스 실행
        do {
            try process.run()
            return true
        } catch {
            print("❌ MediaRemote Adapter 실행 실패: \(error)")
            return false
        }
    }
    
    private func processBuffer() {
        while let range = buffer.range(of: "\n") {
            let line = String(buffer[..<range.lowerBound])
            buffer = String(buffer[range.upperBound...])
            
            if !line.isEmpty {
                processAdapterOutput(line)
            }
        }
    }
    
    private func processAdapterOutput(_ jsonLine: String) {
        guard let data = jsonLine.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let payload = object["payload"] as? [String: Any] else {
            return
        }
        
        let isDiff = object["diff"] as? Bool ?? false
        
        DispatchQueue.main.async { [weak self] in
            self?.updateFromPayload(payload, isDiff: isDiff)
        }
    }
    
    private func updateFromPayload(_ payload: [String: Any], isDiff: Bool) {
        // 제목
        if let title = payload["title"] as? String {
            self.songTitle = title
            print("🎵 제목: \(title)")
        } else if !isDiff {
            self.songTitle = ""
        }
        
        // 아티스트
        if let artist = payload["artist"] as? String {
            self.artistName = artist
            print("👤 아티스트: \(artist)")
        } else if !isDiff {
            self.artistName = ""
        }
        
        // 앨범
        if let album = payload["album"] as? String {
            self.albumName = album
        } else if !isDiff {
            self.albumName = ""
        }
        
        // 재생 상태
        if let playing = payload["playing"] as? Bool {
            if self.isPlaying != playing {
                self.isPlaying = playing
                print("⏯️ 재생 상태: \(playing ? "재생 중" : "정지")")
            }
        } else if !isDiff {
            self.isPlaying = false
        }
        
        // 시간 정보
        if let time = payload["elapsedTime"] as? Double {
            self.currentTime = time
        } else if !isDiff {
            self.currentTime = 0
        }
        
        if let duration = payload["duration"] as? Double {
            self.duration = duration
        } else if !isDiff {
            self.duration = 0
        }
        
        // 재생 속도
        if let rate = payload["playbackRate"] as? Double {
            self.playbackRate = rate
        } else if !isDiff {
            self.playbackRate = 1.0
        }
        
        // 셔플 모드
        if let shuffleMode = payload["shuffleMode"] as? Int {
            self.isShuffled = shuffleMode != 1 // 1이 off, 2가 on
        } else if !isDiff {
            self.isShuffled = false
        }
        
        // 반복 모드
        if let repeatMode = payload["repeatMode"] as? Int {
            self.repeatMode = repeatMode
        } else if !isDiff {
            self.repeatMode = 0
        }
        
        // 번들 식별자
        if let bundleId = payload["parentApplicationBundleIdentifier"] as? String ??
                           payload["bundleIdentifier"] as? String {
            self.bundleIdentifier = bundleId
        } else if !isDiff {
            self.bundleIdentifier = ""
        }
        
        // 앨범 아트
        if let artworkDataString = payload["artworkData"] as? String {
            self.albumArtwork = Data(base64Encoded: artworkDataString.trimmingCharacters(in: .whitespacesAndNewlines))
        } else if !isDiff {
            self.albumArtwork = nil
        }
    }
    
    // MARK: - Public Methods
    @objc func updateNowPlayingInfo() {
        // 스트림 모드에서는 자동으로 업데이트되므로 별도 액션 불필요
        // 필요시 get 명령으로 즉시 정보를 가져올 수 있음
        executeCommand("get")
    }
    
    @objc func updatePlayingState() {
        // 스트림 모드에서 자동 업데이트
        updateNowPlayingInfo()
    }
    
    // MARK: - 제어 함수들
    func play() {
        executeCommand("send", parameters: ["0"]) // kMRPlay = 0
        print("▶️ 재생 명령")
    }
    
    func pause() {
        executeCommand("send", parameters: ["1"]) // kMRPause = 1
        print("⏸️ 정지 명령")
    }
    
    func togglePlayPause() {
        executeCommand("send", parameters: ["2"]) // kMRTogglePlayPause = 2
        print("⏯️ 재생/정지 토글")
    }
    
    func nextTrack() {
        executeCommand("send", parameters: ["4"]) // kMRNextTrack = 4
        print("⏭️ 다음 곡")
    }
    
    func previousTrack() {
        executeCommand("send", parameters: ["5"]) // kMRPreviousTrack = 5
        print("⏮️ 이전 곡")
    }
    
    func seek(to time: TimeInterval) {
        let microseconds = Int(time * 1_000_000)
        executeCommand("seek", parameters: ["\(microseconds)"])
        print("🕒 시간 탐색: \(time)초")
    }
    
    func toggleShuffle() {
        // 셔플 모드 토글 (현재 상태에 따라)
        let newMode = isShuffled ? "1" : "2" // 1 = off, 2 = on
        executeCommand("shuffle", parameters: [newMode])
        print("🔀 셔플 토글")
    }
    
    func toggleRepeat() {
        // 반복 모드 순환 (off -> all -> one -> off)
        let newMode: String
        switch repeatMode {
        case 1: newMode = "3" // off -> all
        case 3: newMode = "2" // all -> one
        default: newMode = "1" // one -> off
        }
        executeCommand("repeat", parameters: [newMode])
        print("🔁 반복 토글")
    }
    
    func fastForward15() {
        executeCommand("send", parameters: ["13"]) // kMRFastForward15Seconds = 13
        print("⏩ 15초 앞으로")
    }
    
    func rewind15() {
        executeCommand("send", parameters: ["12"]) // kMRRewind15Seconds = 12
        print("⏪ 15초 뒤로")
    }
    
    func setPlaybackRate(_ rate: Float) {
        // MediaRemote에서 재생 속도 변경은 복잡하므로 구현하지 않음
        print("🎵 재생 속도 변경은 지원되지 않습니다")
    }
    
    // MARK: - Private Methods
    private func executeCommand(_ command: String, parameters: [String] = []) {
        guard let scriptURL = Bundle.main.url(forResource: "mediaremote-adapter", withExtension: "pl"),
              let frameworkPath = Bundle.main.privateFrameworksPath?.appending("/MediaRemoteAdapter.framework") else {
            return
        }
        
        // 별도 프로세스로 명령 실행
        let commandProcess = Process()
        commandProcess.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
        
        var arguments = [scriptURL.path, frameworkPath, command]
        arguments.append(contentsOf: parameters)
        commandProcess.arguments = arguments
        
        do {
            try commandProcess.run()
            commandProcess.waitUntilExit()
        } catch {
            print("❌ 명령 실행 실패: \(command) - \(error)")
        }
    }
    
    private func cleanup() {
        pipe?.fileHandleForReading.readabilityHandler = nil
        
        if let process = process, process.isRunning {
            process.terminate()
            process.waitUntilExit()
        }
        
        process = nil
        pipe = nil
    }
}
