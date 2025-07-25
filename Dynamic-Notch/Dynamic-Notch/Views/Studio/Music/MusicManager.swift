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

//import Foundation
//import SwiftUI
//import MusicKit
//
//class MusicManager: ObservedObject {
//    static let shared = MusicManager()
//    
//    @Published var songName: String = "아직없음"
//    @Published var artistName: String = "없음"
//    @Published var albumThumbnail:
//    
//    private init() {
//        self.albumThumbnail
//        self.artistName
//        self.songName
//    }
//    
//}


//
//  MusicManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/14/25.
//

//
//  MusicManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/14/25.
//

//
//  MusicManager.swift
//  Dynamic-Notch
//

import Foundation
import SwiftUI

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    
    // MARK: - Published Properties
//    @Published var songName: String = "Heat Waves"
//    @Published var artistName: String = "Glass Animals"
//    @Published var albumThumbnail: NSImage? = nil
//    @Published var hasPermission: Bool = true
//    @Published var currentPlaybackTime: TimeInterval = 45
//    @Published var totalDuration: TimeInterval = 180
//    @Published var playbackProgress: Double = 0.25
//    @Published var isPlaying: Bool = true
//    @Published var searchResults: [TestSong] = []
//    @Published var selectedSong: TestSong? = nil
    
}

