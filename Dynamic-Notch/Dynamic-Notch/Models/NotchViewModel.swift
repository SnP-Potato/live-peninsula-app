//
//  NotchViewModel.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 3/17/25.
//

import Defaults
import Combine
import SwiftUI

class NotchViewModel: ObservableObject {
    // 노치 상태 관리
    @Published private(set) var notchStatus: NotchStatus = .off
    
    // 노치 사이즈 관리
    @Published var notchSize: CGSize = offNotchSize()
    @Published var closedNotchSize: CGSize = offNotchSize()
    
    // 현재 화면
    @Published var currentView: NotchMainFeaturesView = .home
    
    // 애니메이션 설정
    private let animation: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    
    // 화면 정보
    var screenName: String?
    
    // 취소 가능한 publishers 저장
    private var cancellables = Set<AnyCancellable>()
    
    init(screenName: String? = nil) {
        self.screenName = screenName
        self.notchSize = offNotchSize(screenName: screenName)
        self.closedNotchSize = notchSize
        
        // 노치를 자동으로 열도록 설정되어 있으면 마우스 위치 관찰 시작
        if Defaults[.autoOpenWithMouse] {
            startMouseObservation()
        }
    }
    
    // 노치 열기
    func open() {
        withAnimation(animation) {
            self.notchSize = onNotchSize
            self.notchStatus = .on
        }
    }
    
    // 노치 닫기
    func close() {
        withAnimation(.smooth) {
            self.notchSize = offNotchSize(screenName: screenName)
            self.closedNotchSize = notchSize
            self.notchStatus = .off
        }
        
        // 트레이에 파일이 있고 트레이를 보여주기 설정이 켜져 있으면 트레이 뷰로 설정
        // if !tray.isEmpty && Defaults[.tray] {
        //     currentView = .tray
        // } else {
        //     currentView = .home
        // }
    }
    
    // 호버 상태 처리
    func handleHover(isHovering: Bool) {
        if Defaults[.autoOpenWithMouse] {
            if isHovering && notchStatus == .off {
                open()
            } else if !isHovering && notchStatus == .on {
                // 자동으로 닫히는 시간이 설정되어 있으면 지연 후 닫기
                let duration = Defaults[.openNotchDuration]
                if duration > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                        // 여전히 호버 상태가 아니면 닫기
                        if !isHovering {
                            self?.close()
                        }
                    }
                } else {
                    close()
                }
            }
        }
    }
    
    // 마우스 위치 관찰 시작
    private func startMouseObservation() {
        // 여기서는 Timer를 사용해 정기적으로 마우스 위치 체크
        // 실제 구현에서는 더 효율적인 방법 사용 권장
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // 현재 마우스가 노치 영역에 있는지 확인
                let mouseLocation = NSEvent.mouseLocation
                let isInNotchArea = self.isMouseInNotchArea(location: mouseLocation)
                
                // 노치 상태 업데이트
                self.handleHover(isHovering: isInNotchArea)
            }
            .store(in: &cancellables)
    }
    
    // 마우스가 노치 영역에 있는지 확인
    private func isMouseInNotchArea(location: NSPoint) -> Bool {
        guard let screen = NSScreen.screens.first(where: { $0.localizedName == self.screenName }) ?? NSScreen.main else {
            return false
        }
        
        // 노치 영역 계산
        let notchFrame = CGRect(
            x: screen.frame.midX - (closedNotchSize.width / 2),
            y: screen.frame.maxY - closedNotchSize.height,
            width: closedNotchSize.width,
            height: closedNotchSize.height
        )
        
        // 마우스가 노치 영역에 있는지 확인
        return notchFrame.contains(location)
    }
    
    // 메모리 정리
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
