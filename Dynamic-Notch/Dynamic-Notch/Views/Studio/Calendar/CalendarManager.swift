//
//  CalendarManager.swift
//  Dynamic-Notch
//
//  Created by PeterPark on 7/29/25.
//

import Foundation
import EventKit


class CalendarManager: NSObject, ObservableObject {
    static let shared = CalendarManager()
    
    //MARK: 이 EKEventStore로 캘린더, 미리암림 테이더 접근함
    private let eventStore = EKEventStore()
    
    //MARK: UI변수들
    @Published var focusDate: Date = Date()
    @Published var focusDayEvent: [EKEvent] = []
    
    //MARK: 캘린더 관리 변수 (캘린더 카테고리랑 선택사항)
    @Published var availableCalendars: [EKCalendar] = []
    @Published var selectedCalendarIDs: Set<String> = []
    
    //MARK: 권한변수들
    @Published var accessStatus: EKAuthorizationStatus = .notDetermined
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    // 1, 5, 31
    var formattedDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: focusDate)
    }
    
    // june -> jun
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: focusDate)
    }
    
    // Monday -> Mon 이렇게
    var formattedWeekend: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: focusDate)
    }
    
    private override init() {
        super.init()
        
        checkAccessStatus()
    }
    
    
    //MARK: 권한 관리 함수
    private func checkAccessStatus() {
        accessStatus = EKEventStore.authorizationStatus(for: .event) //지금 캘린더에 접근권한이 있는지 권한상태를 확인해주는 메소드ㅡ
        print("\(accessStatus)")
    }
    
    func requestCalendarAccess() async {
        eventStore.requestFullAccessToEvents { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted, error == nil {
                    print("정상적으로 처리함")
                    
                    //에러 없으면 상태 변경
                    self?.accessStatus = .fullAccess
                    self?.loadAvailableCalendars()
                    self?.loadTodayEvent()
                } else {
                    self?.accessStatus = .denied
                    self?.isError = true
                }
            }
        }
    }
    
    
    //MARK: 캘린더 데이터 로드이하는 함수
    func loadAvailableCalendars() {
        availableCalendars = eventStore.calendars(for: .event)
        
        selectedCalendarIDs = Set(availableCalendars.map { $0.calendarIdentifier })
        
        print("지금 캘린더 개수: \(availableCalendars.count)")
        
        for calendar in availableCalendars {
            print(" \(calendar.title): \(calendar.calendarIdentifier)")
        }
    }
    
    func loadTodayEvent() {
        loadEventForDate(focusDate)
    }
    
    func loadEventForDate(_ date: Date)  {
        let today = Calendar.current.startOfDay(for: date)
        
    }
    
    //MARK: 날짜 관리
    func updateFocusDate() {
        
    }
    
    func sortEventByTime() {
        
    }
    
    //MARK: 선책 관리
    func filterSelectedCalendars() {
        
    }
}
