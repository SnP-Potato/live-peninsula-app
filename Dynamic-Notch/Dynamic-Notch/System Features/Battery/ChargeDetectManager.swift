//
//  ChargeDetectManager.swift
//  Live Peninsula
//
//  Created by PeterPark on 9/14/25.
//

import Cocoa
import SwiftUI
import IOKit.ps
import Combine

// MARK: - 충전 상태 모델
enum ChargeStatus: Equatable {
    case disconnected
    case connected
    case charging
    case fullyCharged
    
    var displayText: String {
        switch self {
        case .disconnected: return "전원 분리됨"
        case .connected: return "전원 연결됨"
        case .charging: return "충전 중"
        case .fullyCharged: return "충전 완료"
        }
    }
    
    var iconName: String {
        switch self {
        case .disconnected: return "powerplug"
        case .connected: return "powerplug.fill"
        case .charging: return "bolt.fill"
        case .fullyCharged: return "battery.100"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .disconnected: return .gray
        case .connected: return .white
        case .charging: return .yellow
        case .fullyCharged: return .green
        }
    }
}

// MARK: - 충전 이벤트 타입
enum ChargeEvent {
    case pluggedIn
    case unplugged
    case chargingStarted
    case chargingComplete
}

class ChargeDetectManager: ObservableObject {
    static let shared = ChargeDetectManager()
    
    // MARK: - Published Properties
    @Published var currentStatus: ChargeStatus = .disconnected {
        didSet {
            print("🔋 상태 변경: \(oldValue) -> \(currentStatus)")
        }
    }
    @Published var batteryLevel: Float = 0.0 {
        didSet {
            print("🔋 배터리 레벨: \(batteryLevel)%")
        }
    }
    @Published var isHUDActive: Bool = false {
        didSet {
            print("🔋 HUD 상태: \(isHUDActive)")
        }
    }
    @Published var lastEvent: ChargeEvent?
    
    // MARK: - Private Properties
    private var powerMonitor: PowerMonitor?
    private var hudDisplayTimer: Timer?
    private var eventPublisher = PassthroughSubject<ChargeEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // 설정 가능한 HUD 표시 시간
    private let hudDisplayDuration: TimeInterval = 3.0
    
    private init() {
        print("🔋 ChargeDetectManager 초기화 시작")
        setupPowerMonitor()
        setupEventHandling()
        performInitialCheck()
        
        // 테스트용: 5초 후 강제로 HUD 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            print("🔋 테스트: 강제 HUD 표시")
            self.testShowHUD()
        }
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Methods
    
    /// HUD를 수동으로 숨기기
    func hideHUD() {
        print("🔋 HUD 수동 숨김")
        withAnimation(.easeOut(duration: 0.2)) {
            isHUDActive = false
        }
        invalidateTimer()
    }
    
    /// 현재 상태 강제 새로고침
    func refresh() {
        print("🔋 상태 강제 새로고침")
        performBatteryCheck()
    }
    
    /// 테스트용 HUD 표시
    func testShowHUD() {
        print("🔋 테스트 HUD 표시 시작")
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isHUDActive = true
            currentStatus = .charging
            batteryLevel = 75.0
        }
        
        // 5초 후 자동 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.hideHUD()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupPowerMonitor() {
        print("🔋 Power Monitor 설정 시작")
        powerMonitor = PowerMonitor { [weak self] in
            print("🔋 전원 상태 변경 감지됨")
            DispatchQueue.main.async {
                self?.handlePowerChange()
            }
        }
        
        guard powerMonitor?.startMonitoring() == true else {
            print("❌ Power Monitor 시작 실패")
            return
        }
        print("✅ Power Monitor 시작 성공")
    }
    
    private func setupEventHandling() {
        print("🔋 이벤트 핸들링 설정")
        eventPublisher
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] event in
                print("🔋 이벤트 처리: \(event)")
                self?.processChargeEvent(event)
            }
            .store(in: &cancellables)
    }
    
    private func performInitialCheck() {
        print("🔋 초기 배터리 상태 확인")
        performBatteryCheck()
    }
    
    private func handlePowerChange() {
        let previousStatus = currentStatus
        performBatteryCheck()
        
        // 상태 변화가 있을 때만 이벤트 발생
        if previousStatus != currentStatus {
            print("🔋 상태 변화 감지: \(previousStatus) -> \(currentStatus)")
            detectAndEmitEvent(from: previousStatus, to: currentStatus)
        }
    }
    
    private func performBatteryCheck() {
        guard let powerInfo = PowerInfo.current() else {
            print("❌ 전원 정보 가져오기 실패")
            updateStatus(.disconnected, batteryLevel: 0.0)
            return
        }
        
        print("🔋 전원 정보: 외부전원=\(powerInfo.isExternalPowerConnected), 충전중=\(powerInfo.isCharging), 배터리=\(powerInfo.batteryPercentage)%")
        
        let newStatus = determineStatus(from: powerInfo)
        updateStatus(newStatus, batteryLevel: powerInfo.batteryPercentage)
    }
    
    private func determineStatus(from powerInfo: PowerInfo) -> ChargeStatus {
        if !powerInfo.isExternalPowerConnected {
            return .disconnected
        }
        
        if powerInfo.batteryPercentage >= 100.0 {
            return .fullyCharged
        }
        
        if powerInfo.isCharging {
            return .charging
        }
        
        return .connected
    }
    
    private func updateStatus(_ newStatus: ChargeStatus, batteryLevel: Float) {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentStatus = newStatus
            self.batteryLevel = batteryLevel
        }
    }
    
    private func detectAndEmitEvent(from previous: ChargeStatus, to current: ChargeStatus) {
        let event: ChargeEvent?
        
        switch (previous, current) {
        case (.disconnected, .connected), (.disconnected, .charging):
            event = .pluggedIn
        case (_, .disconnected):
            event = .unplugged
        case (.connected, .charging), (.fullyCharged, .charging):
            event = .chargingStarted
        case (.charging, .fullyCharged):
            event = .chargingComplete
        default:
            event = nil
        }
        
        if let event = event {
            print("🔋 이벤트 발생: \(event)")
            eventPublisher.send(event)
        } else {
            print("🔋 이벤트 없음: \(previous) -> \(current)")
        }
    }
    
    private func processChargeEvent(_ event: ChargeEvent) {
        lastEvent = event
        
        switch event {
        case .pluggedIn, .chargingStarted, .chargingComplete:
            print("🔋 HUD 표시 이벤트: \(event)")
            showHUD()
        case .unplugged:
            print("🔋 HUD 숨김 이벤트: \(event)")
            hideHUD()
        }
    }
    
    private func showHUD() {
        print("🔋 HUD 표시 시작")
        invalidateTimer()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isHUDActive = true
        }
        
        // 자동 숨김 타이머 설정
        hudDisplayTimer = Timer.scheduledTimer(withTimeInterval: hudDisplayDuration, repeats: false) { [weak self] _ in
            print("🔋 자동 HUD 숨김 (타이머)")
            self?.hideHUD()
        }
    }
    
    private func invalidateTimer() {
        hudDisplayTimer?.invalidate()
        hudDisplayTimer = nil
    }
    
    private func cleanup() {
        powerMonitor?.stopMonitoring()
        powerMonitor = nil
        invalidateTimer()
        cancellables.removeAll()
        print("🔋 ChargeDetectManager 정리 완료")
    }
}

// MARK: - Power Monitor (내부 클래스) - 수정된 버전
private class PowerMonitor {
    private var callback: IOPowerSourceCallbackType?
    private var runLoopSource: Unmanaged<CFRunLoopSource>?
    private let changeHandler: () -> Void
    
    init(changeHandler: @escaping () -> Void) {
        self.changeHandler = changeHandler
    }
    
    func startMonitoring() -> Bool {
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        callback = { context in
            guard let context = context else {
                print("❌ Power Monitor 콜백 context 없음")
                return
            }
            let monitor = Unmanaged<PowerMonitor>.fromOpaque(context).takeUnretainedValue()
            monitor.changeHandler()
        }
        
        guard let source = IOPSNotificationCreateRunLoopSource(callback!, context)?.takeRetainedValue() else {
            print("❌ Power Monitor RunLoop 소스 생성 실패")
            return false
        }
        
        runLoopSource = Unmanaged<CFRunLoopSource>.passRetained(source)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
        print("✅ Power Monitor RunLoop 소스 등록 성공")
        return true
    }
    
    func stopMonitoring() {
        if let source = runLoopSource?.takeUnretainedValue() {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
        runLoopSource?.release()
        runLoopSource = nil
        callback = nil
        print("🔋 Power Monitor 정지됨")
    }
    
    deinit {
        stopMonitoring()
    }
}

// MARK: - Power Info (전원 정보 구조체) - 개선된 버전
private struct PowerInfo {
    let isExternalPowerConnected: Bool
    let isCharging: Bool
    let batteryPercentage: Float
    
    static func current() -> PowerInfo? {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            print("❌ IOPSCopyPowerSourcesInfo 실패")
            return nil
        }
        
        guard let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            print("❌ IOPSCopyPowerSourcesList 실패")
            return nil
        }
        
        print("🔋 전원 소스 개수: \(sources.count)")
        
        for (index, source) in sources.enumerated() {
            guard let info = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: AnyObject] else {
                print("❌ 전원 소스 \(index) 정보 없음")
                continue
            }
            
            let powerSourceType = info[kIOPSTypeKey] as? String
            
            // 내장 배터리만 체크
            if powerSourceType == kIOPSInternalBatteryType {
                let powerSourceState = info[kIOPSPowerSourceStateKey] as? String
                let isCharging = info["Is Charging"] as? Bool ?? false
                let currentCapacity = info[kIOPSCurrentCapacityKey] as? Int ?? 0
                let maxCapacity = info[kIOPSMaxCapacityKey] as? Int ?? 100
                
                // 추가 정보들 체크
                let timeToFullCharge = info["Time to Full Charge"] as? Int ?? -1
                let current = info["Current"] as? Int ?? 0  // 전류 값 (양수면 방전, 음수면 충전)
                
                print("🔋 PowerSourceState: \(powerSourceState ?? "nil")")
                print("🔋 IsCharging: \(isCharging)")
                print("🔋 Current: \(current)mA")
                print("🔋 TimeToFullCharge: \(timeToFullCharge)")
                print("🔋 Capacity: \(currentCapacity)/\(maxCapacity)")
                
                // 다중 조건으로 외부 전원 연결 상태 판단
                let isExternalConnected = isCharging ||  // 충전 중이면 확실히 연결됨
                                        (powerSourceState == kIOPSACPowerValue) ||  // AC 전원 상태
                                        (current < 0) ||  // 음수 전류는 충전 중을 의미
                                        (timeToFullCharge > 0 && timeToFullCharge != 65535) // 충전 시간이 있으면 충전 중
                
                let batteryPercent = Float(currentCapacity * 100) / Float(maxCapacity)
                
                let result = PowerInfo(
                    isExternalPowerConnected: isExternalConnected,
                    isCharging: isCharging,
                    batteryPercentage: batteryPercent
                )
                
                print("🔋 최종 결과: 외부전원=\(result.isExternalPowerConnected), 충전=\(result.isCharging), 배터리=\(result.batteryPercentage)%")
                return result
            }
        }
        
        print("❌ 내장 배터리 정보를 찾을 수 없음")
        return nil
    }
}

// MARK: - 추가 테스트 메서드
extension ChargeDetectManager {
    /// 강제로 상태를 변경하여 HUD 테스트
    func forceTestCharging() {
        print("🔋 강제 충전 상태 테스트")
        let previousStatus = currentStatus
        
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStatus = .charging
            batteryLevel = 85.0
        }
        
        detectAndEmitEvent(from: previousStatus, to: .charging)
    }
    
    /// 강제로 연결 해제 테스트
    func forceTestDisconnected() {
        print("🔋 강제 연결 해제 테스트")
        let previousStatus = currentStatus
        
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStatus = .disconnected
            batteryLevel = 85.0
        }
        
        detectAndEmitEvent(from: previousStatus, to: .disconnected)
    }
}
