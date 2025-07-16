//
//  MusicManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/14/25.
//

import SwiftUI
import Foundation

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

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    
    //음악정보
    @Published var songTitle: String = "No Music"
    @Published var artistName: String = "NO Artist"
    @Published var isPlaying: Bool = false
    
    //UI요소들
    @Published var album: Image? = nil
    @Published var musicAppIcon: Image? = nil
    @Published var albumColor: Color = .white
    
    private var getMusicInfo: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void)?
    private var getPlayingStatus: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void)?
    private var sendMusicCommand: (@convention(c) (Int, AnyObject?) -> Void)?
    private var registerMusicNotifications: (@convention(c) (DispatchQueue) -> Void)?
    private var getCurrentMusicApp: (@convention(c) (DispatchQueue, @escaping (Any?) -> Void) -> Void)?
    private var setElapsedTime: (@convention(c) (Double) -> Void)?
    
    private var mediaRemoteBundle: CFBundle?
    
    private init() {
        connectToMusicsystem()
    }
    
    
    //진행할 단게: [1단계] 프레임워크 찾기, [2단계] 프레임워크 로드하기, [3단계] 함수별 포인트 연결
    func connectToMusicsystem() {
        
        /// [1단계] 프레임워크 찾기
        guard let frameworkURL = URL(string: "/System/Library/PrivateFrameworks/MediaRemote.framework") else {
            print("MediaRemote의 경로을 찾을 수 없음")
            return
        }
        /// [2단계] 프레임워크 로드하기& 메모리에 올리기
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, frameworkURL as CFURL) else {
            print(" MediaRemote 프레임워크를 로드할 수 없습니다")
            return
        }
        
        // 나중에 또 사용하기 해야되서 변수 따로 저장
        self.mediaRemoteBundle = bundle
        print("✅ MediaRemote 프레임워크 로드 성공")
        
        
        /// [3단계] 함수별 포인트 연결
        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) {
            //unsafeBitCast은 강제 타입변환
            //unsafeBitCast(원본, to: 바꿀타입.self)
            getMusicInfo = unsafeBitCast(functionPointer, to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)
            print("음악 정보 가져오기 성공")
        } else {
            print(" 음악 정보 가져오기 함수 연결 실패")
            return
        }
        
        // 재생확인상태
        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString) {
            getPlayingStatus = unsafeBitCast(functionPointer, to: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void).self)
            print("✅ 재생 상태 확인 함수 연결 성공")
        } else {
            print("❌ 재생 상태 확인 함수 연결 실패")
            return
        }
        
        // 4. 미디어 제어 명령 함수
        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString) {
            sendMusicCommand = unsafeBitCast(functionPointer, to: (@convention(c) (Int, AnyObject?) -> Void).self)
            print("✅ 미디어 제어 명령 함수 연결 성공")
        } else {
            print("❌ 미디어 제어 명령 함수 연결 실패")
            return
        }
        
        // 5. 알림 등록 함수
        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString) {
            registerMusicNotifications = unsafeBitCast(functionPointer, to: (@convention(c) (DispatchQueue) -> Void).self)
            print("✅ 알림 등록 함수 연결 성공")
        } else {
            print("❌ 알림 등록 함수 연결 실패")
            return
        }
        
        // 6. 현재 음악 앱 정보 가져오기 함수
        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingClient" as CFString) {
            getCurrentMusicApp = unsafeBitCast(functionPointer, to: (@convention(c) (DispatchQueue, @escaping (Any?) -> Void) -> Void).self)
            print("✅ 음악 앱 정보 가져오기 함수 연결 성공")
        } else {
            print("❌ 음악 앱 정보 가져오기 함수 연결 실패")
            return
        }
        
        // 7. 재생 위치 설정 함수
        if let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSetElapsedTime" as CFString) {
            setElapsedTime = unsafeBitCast(functionPointer, to: (@convention(c) (Double) -> Void).self)
            print("✅ 재생 위치 설정 함수 연결 성공")
        } else {
            print("❌ 재생 위치 설정 함수 연결 실패")
        }
        
        print("🎵 음악 시스템 연결 완료!")
        return
    }
    
    func playPause() {
        isPlaying.toggle()
        print("재생&정지")
    }
    
    func nextTrack() {
        
    }
    
    func previousTrack() {
        
    }
}
