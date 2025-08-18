//
//  PlayBackManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 8/18/25.
//

import Foundation
import Combine

class PlaybackManager: ObservableObject {
    @Published var isPlaying = false
    @Published var MrMediaRemoteSendCommandFunction: @convention(c) (Int, AnyObject?) -> Void
    @Published var MrMediaRemoteSetElapsedTimeFunction: @convention(c) (Double) -> Void

    init() {
        self.isPlaying = false
        self.MrMediaRemoteSendCommandFunction = {_,_ in }
        self.MrMediaRemoteSetElapsedTimeFunction = { _ in }
        handleLoadMediaHandlerApis()
    }
    
    private func handleLoadMediaHandlerApis(){
        // Load framework
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")) else {
            print("❌ MediaRemote.framework 로드 실패")
            return
        }
        
        // Get a Swift function for MRMediaRemoteSetElapsedTime
        guard let MRMediaRemoteSetElapsedTimePointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSetElapsedTime" as CFString) else {
            print("❌ MRMediaRemoteSetElapsedTime 함수 포인터 획득 실패")
            return
        }

        typealias MRMediaRemoteSetElapsedTimeFunction = @convention(c) (Double) -> Void
        MrMediaRemoteSetElapsedTimeFunction = unsafeBitCast(MRMediaRemoteSetElapsedTimePointer, to: MRMediaRemoteSetElapsedTimeFunction.self)
        
        print("✅ MediaRemote API 로드 성공")
    }
    
    deinit {
        self.MrMediaRemoteSendCommandFunction = {_,_ in }
        self.MrMediaRemoteSetElapsedTimeFunction = { _ in }
    }
    
    func seekTrack(to time: TimeInterval) {
        print("🎯 PlaybackManager.seekTrack 호출: \(time)초")
        MrMediaRemoteSetElapsedTimeFunction(time)
        print("✅ MediaRemote seek 명령 전송 완료")
    }
}
