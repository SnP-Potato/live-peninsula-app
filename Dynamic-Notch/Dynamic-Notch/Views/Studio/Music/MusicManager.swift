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
    
    
    private init() {
        loadMediaRemoteFramwork()
    }
    
    
    func loadMediaRemoteFramwork() {
        let url = NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, url) else {
            print("MediaRemote 프레임워크를 로드할 수 없습니다")
            return
        }
        
        print("MediaRemote 프레임워크를 로드했습니다: \(bundle)")
        
        //위에서 로드했는지 못했는지 확인했고 음악정보 가져오기
        guard let functionPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else {
            print("함수 포인트 가져오기 실패")
            return
        }
        
        print("함수 포인트 가져오기 성공!")
        
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
